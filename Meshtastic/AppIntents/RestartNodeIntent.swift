//
//  RestartNodeIntent.swift
//  Meshtastic
//
//  Created by Benjamin Faershtein on 8/24/24.
//

import Foundation

#if canImport(AppIntents) && compiler(>=5.9)
import AppIntents

@available(iOS 16.0, *)
struct RestartNodeIntent: AppIntent {
	static let title: LocalizedStringResource = "Restart"

	static let description: IntentDescription = "Restart to the node you are connected to"

	func perform() async throws -> some IntentResult {

		if !(await AccessoryManager.shared.isConnected) {
			throw AppIntentErrors.AppIntentError.notConnected
		}
		// Safely unwrap the connectedNode using if let
		let context = await MainActor.run { CoreDataStackImpl.shared.container.viewContext }
		if let connectedPeripheralNum = await AccessoryManager.shared.activeDeviceNum,
		   let connectedNode = getNodeInfo(id: connectedPeripheralNum, context: context),
		   let fromUser = connectedNode.user,
		   let toUser = connectedNode.user {

			// Attempt to send shutdown, throw an error if it fails
			do {
				try await AccessoryManager.shared.sendReboot(fromUser: fromUser, toUser: toUser)
			} catch {
				throw AppIntentErrors.AppIntentError.message("Failed to restart")
			}
		} else {
			throw AppIntentErrors.AppIntentError.message("Failed to retrieve connected node or required data")
		}
		return .result()
	}
}
#endif