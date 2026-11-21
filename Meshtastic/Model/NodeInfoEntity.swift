//
//  NodeInfoEntity.swift
//  Meshtastic
//
//  SwiftData model for the central node information entity.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(NodeInfoEntity)
public class NodeInfoEntity: NSManagedObject {

	@NSManaged public var bleName: String?
	@NSManaged public var channel: Int32
	@NSManaged public var favorite: Bool
	@NSManaged public var firstHeard: Date?
	@NSManaged public var hasBeenAdministered: Bool
	@NSManaged public var hasXeddsaSigned: Bool
	@NSManaged public var isKeyManuallyVerified: Bool
	@NSManaged public var heardOnCurrentLora: Int16
	@NSManaged public var hopsAway: Int32
	@NSManaged public var id: Int64
	@NSManaged public var ignored: Bool
	@NSManaged public var lastHeard: Date?
	@NSManaged public var nodeStatus: String?
	@NSManaged public var num: Int64
	@NSManaged public var peripheralId: String?
	@NSManaged public var powerChannelLabels: Data
	@NSManaged public var rssi: Int32
	@NSManaged public var sessionExpiration: Date?
	@NSManaged public var sessionPasskey: Data?
	@NSManaged public var snr: Float
	@NSManaged public var viaMqtt: Bool

	// Config relationships (to-one, cascade)
	@NSManaged public var ambientLightingConfig: AmbientLightingConfigEntity?
	@NSManaged public var audioConfig: AudioConfigEntity?
	@NSManaged public var bluetoothConfig: BluetoothConfigEntity?
	@NSManaged public var cannedMessageConfig: CannedMessageConfigEntity?
	@NSManaged public var detectionSensorConfig: DetectionSensorConfigEntity?
	@NSManaged public var deviceConfig: DeviceConfigEntity?
	@NSManaged public var displayConfig: DisplayConfigEntity?
	@NSManaged public var externalNotificationConfig: ExternalNotificationConfigEntity?
	@NSManaged public var loRaConfig: LoRaConfigEntity?
	@NSManaged public var meshBeaconConfig: MeshBeaconConfigEntity?
	@NSManaged public var metadata: DeviceMetadataEntity?
	@NSManaged public var mqttConfig: MQTTConfigEntity?
	@NSManaged public var neighborInfoConfig: NeighborInfoConfigEntity?
	@NSManaged public var myInfo: MyInfoEntity?
	@NSManaged public var networkConfig: NetworkConfigEntity?
	@NSManaged public var pax: [PaxCounterEntity]
	@NSManaged public var paxCounterConfig: PaxCounterConfigEntity?
	@NSManaged public var positionConfig: PositionConfigEntity?
	@NSManaged public var positions: [PositionEntity]
	@NSManaged public var latestPositionCache: PositionEntity?
	@NSManaged public var powerConfig: PowerConfigEntity?
	@NSManaged public var rangeTestConfig: RangeTestConfigEntity?
	@NSManaged public var rtttlConfig: RTTTLConfigEntity?
	@NSManaged public var securityConfig: SecurityConfigEntity?
	@NSManaged public var serialConfig: SerialConfigEntity?
	@NSManaged public var statusMessageConfig: StatusMessageConfigEntity?
	@NSManaged public var storeForwardConfig: StoreForwardConfigEntity?
	@NSManaged public var takConfig: TAKConfigEntity?
	@NSManaged public var telemetries: [TelemetryEntity]
	@NSManaged public var telemetryConfig: TelemetryConfigEntity?
	@NSManaged public var traceRoutes: [TraceRouteEntity]
	@NSManaged public var user: UserEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "NodeInfoEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.bleName = nil
		self.channel = 0
		self.favorite = false
		self.firstHeard = nil
		self.hasBeenAdministered = false
		self.hasXeddsaSigned = false
		self.isKeyManuallyVerified = false
		self.heardOnCurrentLora = -1
		self.hopsAway = 0
		self.id = 0
		self.ignored = false
		self.lastHeard = nil
		self.nodeStatus = nil
		self.num = 0
		self.peripheralId = nil
		self.powerChannelLabels = Data()
		self.rssi = 0
		self.sessionExpiration = nil
		self.sessionPasskey = nil
		self.snr = 0.0
		self.viaMqtt = false
		self.ambientLightingConfig = nil
		self.audioConfig = nil
		self.bluetoothConfig = nil
		self.cannedMessageConfig = nil
		self.detectionSensorConfig = nil
		self.deviceConfig = nil
		self.displayConfig = nil
		self.externalNotificationConfig = nil
		self.loRaConfig = nil
		self.meshBeaconConfig = nil
		self.metadata = nil
		self.mqttConfig = nil
		self.neighborInfoConfig = nil
		self.myInfo = nil
		self.networkConfig = nil
		self.pax = []
		self.paxCounterConfig = nil
		self.positionConfig = nil
		self.positions = []
		self.latestPositionCache = nil
		self.powerConfig = nil
		self.rangeTestConfig = nil
		self.rtttlConfig = nil
		self.securityConfig = nil
		self.serialConfig = nil
		self.statusMessageConfig = nil
		self.storeForwardConfig = nil
		self.takConfig = nil
		self.telemetries = []
		self.telemetryConfig = nil
		self.traceRoutes = []
		self.user = nil
	}
}

extension NodeInfoEntity {
	/// Orders nodes for the admin / configuration node picker in `Settings.swift`:
	/// favorited nodes first, then non-favorites, with each group keeping the input's
	/// relative order. This restores the favorite-on-top behavior of the legacy
	/// CoreData `@FetchRequest` sort, which was lost in the SwiftData conversion
	/// (PR #1668).
	///
	/// `nodes` is expected to already be sorted by `lastHeard` descending — as the
	/// Settings snapshot fetch provides — so the partition yields favorites (most-recent
	/// first) ahead of non-favorites (most-recent first). Deleted or detached models are
	/// screened out before their persisted properties are read because a snapshot can
	/// outlive a node-database reset. It's a `Bool`-keyed
	/// partition rather than a SwiftData `@Query` sort because `favorite` is a
	/// `Bool`, and `Bool` is not `Comparable`, so it cannot be a `SortDescriptor`
	/// key on a non-`NSObject` `@Model`.
	///
	/// Implemented as a stable O(n) partition (rather than an O(n log n) re-sort) so
	/// it is cheap to call per render, and deterministic across re-renders as long as
	/// the input order is stable.
	static func adminPickerOrder(_ nodes: [NodeInfoEntity]) -> [NodeInfoEntity] {
		let liveNodes = nodes.filter { $0.managedObjectContext != nil && !$0.isDeleted }
		return liveNodes.filter(\.favorite) + liveNodes.filter { !$0.favorite }
	}

	/// True while the node's admin session is usable for a remote admin write: a non-empty
	/// session passkey inside the firmware's 5-minute session window. Empty-passkey stamps
	/// (from the local config download and post-save mirrors) don't count.
	var hasLiveAdminSession: Bool {
		sessionPasskey?.isEmpty == false && (sessionExpiration ?? .distantPast) >= Date()
	}

	/// This node's own reported firmware version, when it has told us one. Under remote
	/// admin this is the target's version, which is not the connected radio's.
	var knownFirmwareVersion: String? {
		guard let version = metadata?.firmwareVersion, !version.isEmpty else { return nil }
		return version
	}

	/// Whether this node's own reported firmware is at least `version`. Permissive when
	/// the node has never reported one, matching the capability gates' unknown-version
	/// behavior.
	func firmwareAtLeast(_ version: String) -> Bool {
		Self.firmware(knownFirmwareVersion, isAtLeast: version)
	}

	/// The one version comparison, for callers that hold a reported version rather than
	/// the entity: the settings list works from a snapshot. A nil or empty `reported`
	/// means the node has never said, and every gate is permissive there.
	static func firmware(_ reported: String?, isAtLeast required: String) -> Bool {
		guard let reported, !reported.isEmpty else { return true }
		return required.compare(reported, options: .numeric) != .orderedDescending
	}

	/// Whether this node's own reported firmware supports the Status Message module (2.8+,
	/// the same floor as `AccessoryManager.supportsStatusMessage`).
	var firmwareSupportsStatusMessage: Bool { firmwareAtLeast("2.8.0") }

	/// The status message to render on read-only surfaces (node list card and node
	/// details). Prefers the live broadcast value (`nodeStatus`, NODE_STATUS_APP) and
	/// falls back to the admin-configured value (`statusMessageConfig`) so the local
	/// node — which knows its config before it re-broadcasts — still shows its own status.
	///
	/// Each candidate is whitespace-trimmed *before* the emptiness test so a whitespace-only
	/// broadcast doesn't suppress an otherwise-configured value. Returns `nil` when both are
	/// empty/unset/whitespace-only so callers omit the row entirely (no icon, no label, no
	/// placeholder — per the design spec). The value is untrusted free text from the mesh:
	/// surface it verbatim and never as markup.
	///
	/// Safe to read directly in the hot list-row path: `StatusMessageConfigEntity` is only
	/// ever inserted/updated and (via `.nullify`) is never deleted independently of its node,
	/// so it can't fault underneath the row the way pruned `PositionEntity` rows can — i.e. it
	/// does not belong in the `NodeListRowSummary` value-snapshot, and keeping it inline lets
	/// the row re-render reactively when `nodeStatus` changes.
	var statusMessageDisplay: String? {
		NodeInfoEntity.displayableStatus(nodeStatus) ?? NodeInfoEntity.displayableStatus(statusMessageConfig?.nodeStatus)
	}

	/// The nodes that may have a status to show, most recently heard first, for reading a few
	/// from the store rather than every node: those with a live broadcast or a configured value,
	/// the two `statusMessageDisplay` draws on. It can't tell a whitespace-only status from a
	/// real one, so read `statusMessageDisplay` on each node fetched. `num` is left out, for the
	/// connected radio, whose row is read separately.
	@MainActor
	static func statusCandidates(excluding num: Int64) -> NSFetchRequest<NodeInfoEntity> {
		let request = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
		request.predicate = NSPredicate(format: "(nodeStatus != nil OR (statusMessageConfig != nil AND statusMessageConfig.nodeStatus != '')) AND num != %@", NSNumber(value: num))
		request.sortDescriptors = [NSSortDescriptor(key: "lastHeard", ascending: false)]
		return request
	}

	/// Trims a candidate status and returns `nil` unless it contains at least one *visible*
	/// character. Plain `whitespacesAndNewlines` trimming isn't enough: an untrusted broadcast
	/// can be composed entirely of zero-width / format / control characters (U+200B, U+FEFF,
	/// U+2060, the bidi marks, …) that pass an `isEmpty` test yet render as a blank row with
	/// just the Notes icon. Treat such all-invisible strings as empty.
	private static func displayableStatus(_ raw: String?) -> String? {
		guard let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
			return nil
		}
		let hasVisible = trimmed.unicodeScalars.contains { scalar in
			switch scalar.properties.generalCategory {
			case .control, .format, .spaceSeparator, .lineSeparator, .paragraphSeparator,
				 .nonspacingMark, .enclosingMark:
				return false
			default:
				return true
			}
		}
		return hasVisible ? trimmed : nil
	}

	/// The value the status-message editor should prefill. Prefer the configured status, but when
	/// it has no *displayable* content (blank, whitespace-only, or invisible-only — the same cases
	/// `displayableStatus` rejects) fall back to the node's live broadcast if that one is
	/// displayable. Without this the cards/detail can show the live broadcast while the editor
	/// prefills an apparently-blank configured value — a user-visible mismatch. A non-displayable
	/// configured value with no displayable live fallback normalizes to "" rather than echoing the
	/// whitespace/invisible characters back into the field (which would show a non-zero byte count
	/// for an apparently-empty editor). Pure + static so it can be unit-tested directly.
	static func statusMessagePrefill(configured: String?, live: String?) -> String {
		if let configured, displayableStatus(configured) != nil {
			return configured
		}
		if let live, displayableStatus(live) != nil {
			return live
		}
		return ""
	}
}