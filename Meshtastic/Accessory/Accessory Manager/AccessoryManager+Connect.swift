//
 //  AccessoryManager+Connect.swift
 //  Meshtastic
 //
 //  Created by Jake Bordens on 7/24/25.
 //

import Foundation
import OSLog
import CoreData
import MeshtasticProtobufs
import CoreBluetooth

private let maxRetries = 2
private let retryDelay: TimeInterval = 2.0

extension AccessoryManager {
	func connect(
		to device: Device,
		withConnection: Connection? = nil,
		wantConfig: Bool = true,
		wantDatabase: Bool = true,
		versionCheck: Bool = true,
		refreshDeviceHardwareFromAPI: Bool = false,
		retries: Int? = nil
	) async throws {
		Logger.transport.info("AccessoryManager.connect(to: \(device.name, privacy: .public), withConnection: \(withConnection != nil), wantConfig: \(wantConfig), wantDatabase: \(wantDatabase), versionCheck: \(versionCheck), refreshDeviceHardwareFromAPI: \(refreshDeviceHardwareFromAPI))")
		// Prevent new connection if one is active
		if activeConnection != nil {
			throw AccessoryError.connectionFailed("Already connected to a device")
		}

		guard let transport = transportForType(device.transportType) else {
			throw AccessoryError.connectionFailed("No transport for type")
		}

		// Clear any errors and stale state from last connection
		lastConnectionError = nil
		firmwareUpdateRequired = false
		self.activeDeviceNum = nil
		self.connectedLoRaRegionCode = nil
		packetsSent = 0
		packetsReceived = 0
		packetsAtLastIngestRecycle = 0
		expectedNodeDBSize = nil

		self.allowDisconnect = true
		self.userRequestedConnectionCancellation = false

		// On a first-ever BLE connection, iOS presents the pairing PIN sheet during
		// characteristic subscription (Step 1). The user needs time to read and type a
		// 6-digit PIN, so give the connect step a long window in that case. Already-bonded
		// peripherals (and non-BLE transports) keep the fast timeout so a dead/out-of-range
		// radio still fails quickly on reconnect.
		// One-time migration: seed pairedPeripheralIds from the legacy preferredPeripheralId so
		// users upgrading to this build (empty pairedPeripheralIds) don't pay the long pairing
		// window on the first reconnect to a radio they already paired before. After this runs
		// once, the preferred-peripheral fallback is never consulted again — the remember/forget
		// lifecycle in BLEConnection becomes the sole source of truth. That way a bond the user
		// later removes (e.g. via iOS Settings > Bluetooth) self-heals back to the long pairing
		// window instead of being pinned to the fast reconnect timeout forever.
		if !UserDefaults.migratedPreferredPeripheralPairing {
			UserDefaults.migratedPreferredPeripheralPairing = true
			if let preferredUUID = UUID(uuidString: UserDefaults.preferredPeripheralId) {
				UserDefaults.rememberPairedPeripheral(preferredUUID)
			}
		}
		let knownBonded = UserDefaults.isPairedPeripheral(device.id)
		let isFirstTimeBLEBond = device.transportType == .ble && !knownBonded
		let connectStepTimeout: TimeInterval = isFirstTimeBLEBond ? 90.0 : 5.0

		// Prepare to connect
		self.connectionStepper = SequentialSteps(maxRetries: retries ?? maxRetries, retryDelay: retryDelay) {

			// Step 0
			Step { @MainActor retryAttempt in
				Logger.transport.info("🔗👟 [Connect] Starting connection to \(device.id, privacy: .public)")
				if retryAttempt > 0 {
					try await self.closeConnection() // clean-up before retries.
					self.updateState(.retrying(attempt: retryAttempt + 1, maxAttempts: retries ?? maxRetries))
				}
				self.state = .connecting
			}

			// Step 1: Connect to the transport
			Step(timeout: connectStepTimeout) { @MainActor _ in
				Logger.transport.info("🔗 [Connect] Opening transport")
				self.activeConnection = try await transport.connect(to: device)
				self.activeConnection?.connection.delegate = self
				Logger.transport.info("🔗 [Connect] Transport connected")
			}

			// Step 2: Verify connection with handshake
			Step(timeout: .seconds(30)) { @MainActor _ in
				Logger.transport.info("🤝 [Connect] Sending handshake")
				try await self.sendHandshake()
			}

			// Step 3: Get firmware version
			Step(timeout: .seconds(10.0), onFailure: .retryStep(attempts: 3)) { @MainActor _ in
				Logger.transport.info("📦 [Connect] Getting firmware version")
				try await self.getFirmwareVersion()
			}

			// Step 4: If versionCheck is true, verify minimum version
			Step(timeout: .seconds(10.0)) { @MainActor _ in
				if versionCheck {
					Logger.transport.info("✅ [Connect] Checking firmware version")
					try await self.checkFirmwareVersion()
				}
			}

			// Step 5: Get hardware model
			Step(timeout: .seconds(10.0)) { @MainActor _ in
				Logger.transport.info("🏷️ [Connect] Getting hardware model")
				try await self.getHardwareModel()
			}

			// Step 6: Get region code
			Step(timeout: .seconds(10.0)) { @MainActor _ in
				Logger.transport.info("🌍 [Connect] Getting region code")
				try await self.getRegionCode()
			}

			// Step 7: Get node database
			Step(timeout: .seconds(120)) { @MainActor _ in
				if wantDatabase {
					Logger.transport.info("📂 [Connect] Getting node database")
					try await self.getNodeDatabase()
				}
			}

			// Step 8: Get config
			Step(timeout: .seconds(30)) { @MainActor _ in
				if wantConfig {
					Logger.transport.info("⚙️ [Connect] Getting config")
					try await self.getConfig()
				}
			}

			// Step 9: Subscribe to notifications
			Step(timeout: .seconds(30)) { @MainActor _ in
				Logger.transport.info("🔔 [Connect] Subscribing to notifications")
				try await self.subscribeToNotifications()
			}

			// Step 10: Complete
			Step { @MainActor _ in
				Logger.transport.info("✅ [Connect] Connection complete")
				self.updateState(.subscribed)
			}
		}

		try await connectionStepper.execute()
	}

	// MARK: - Sequential Steps

	@resultBuilder
	struct StepsBuilder {
		static func buildBlock(_ steps: Step...) -> [Step] {
			return steps
		}
	}

	struct Step {
		typealias StepClosure = @MainActor (Int) async throws -> Void

		enum FailureBehavior {
			case retryAll
			case retryStep(attempts: Int)
			case fail
		}

		let timeout: TimeInterval?
		let onFailure: FailureBehavior
		let operation: StepClosure

		init(timeout: TimeInterval? = nil, onFailure: FailureBehavior = .retryAll, operation: @escaping StepClosure) {
			self.timeout = timeout
			self.onFailure = onFailure
			self.operation = operation
		}
	}

	actor SequentialSteps {
		var steps: [Step]
		let maxRetries: Int
		var retryDelay: TimeInterval
		var currentRetryAttempt = 0
		var currentStepIndex = 0
		var stepRetryCounts: [Int: Int] = [:]

		init(maxRetries: Int = 3, retryDelay: TimeInterval = 3.0, @StepsBuilder _ builder: () -> [Step]) {
			self.steps = builder()
			self.maxRetries = maxRetries
			self.retryDelay = retryDelay
		}

		func execute() async throws {
			while currentStepIndex < steps.count {
				let step = steps[currentStepIndex]
				var attempt = 0
				let maxStepRetries = (step.onFailure == .fail) ? 0 : maxRetries

				while attempt <= maxStepRetries {
					do {
						if let timeout = step.timeout {
							try await withTimeout(timeout) {
								try await step.operation(currentRetryAttempt)
							}
						} else {
							try await step.operation(currentRetryAttempt)
						}
						currentStepIndex += 1
						break
					} catch {
						attempt += 1
						stepRetryCounts[currentStepIndex, default: 0] += 1

						if attempt > maxStepRetries {
							Logger.transport.error("Step \(self.currentStepIndex) failed after \(maxStepRetries) retries: \(error)")
							throw error
						}

						Logger.transport.warning("Step \(self.currentStepIndex) failed (attempt \(attempt)), retrying in \(self.retryDelay)s: \(error)")
						try await Task.sleep(nanoseconds: UInt64(self.retryDelay * 1_000_000_000))
					}
				}
			}
		}

		func withTimeout<ReturnType>(_ timeout: TimeInterval, operation: @escaping () async throws -> ReturnType) async throws -> ReturnType {
			try await withThrowingTaskGroup(of: ReturnType.self) { group in
				group.addTask {
					try await operation()
				}
				group.addTask {
					try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
					throw AccessoryError.timeout
				}
				let result = try await group.next()!
				group.cancelAll()
				return result
			}
		}
	}
}