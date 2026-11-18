//
//  DiscoveryPresetResultEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for discovery preset results.
//  Converted from SwiftData for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DiscoveryPresetResultEntity)
public class DiscoveryPresetResultEntity: NSManagedObject {

	@NSManaged public var presetName: String
	@NSManaged public var dwellDurationSeconds: Int32
	@NSManaged public var uniqueNodesFound: Int32
	@NSManaged public var directNeighborCount: Int32
	@NSManaged public var meshNeighborCount: Int32
	@NSManaged public var infrastructureNodeCount: Int32
	@NSManaged public var messageCount: Int32
	@NSManaged public var sensorPacketCount: Int32
	@NSManaged public var averageChannelUtilization: Double
	@NSManaged public var averageAirtimeRate: Double
	@NSManaged public var packetSuccessRate: Double
	@NSManaged public var packetFailureRate: Double
	@NSManaged public var aiSummaryText: String

	// Raw local stats (mirrors live activity data)
	@NSManaged public var numPacketsTx: Int32
	@NSManaged public var numPacketsRx: Int32
	@NSManaged public var numPacketsRxBad: Int32
	@NSManaged public var numRxDupe: Int32
	@NSManaged public var numTxRelay: Int32
	@NSManaged public var numTxRelayCanceled: Int32
	@NSManaged public var numOnlineNodes: Int32
	@NSManaged public var numTotalNodes: Int32
	@NSManaged public var uptimeSeconds: Int32

	/// Average RF noise floor (dBm) from the connected node's local-stats telemetry collected
	/// during this preset's dwell. Noise floor is frequency-specific, so this characterizes how
	/// quiet the channel was on the preset's frequency — lower (more negative) is quieter/better.
	/// 0.0 means no noise-floor data was available (noise floor readings are always negative).
	@NSManaged public var averageNoiseFloor: Double
	/// Number of local-stats samples that contributed to `averageNoiseFloor`.
	@NSManaged public var noiseFloorSampleCount: Int32

	@NSManaged public var session: DiscoverySessionEntity?
	@NSManaged public var nodes: [DiscoveredNodeEntity]
	@NSManaged public var beacons: [DiscoveredBeaconEntity]

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DiscoveryPresetResultEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.presetName = ""
		self.dwellDurationSeconds = 0
		self.uniqueNodesFound = 0
		self.directNeighborCount = 0
		self.meshNeighborCount = 0
		self.infrastructureNodeCount = 0
		self.messageCount = 0
		self.sensorPacketCount = 0
		self.averageChannelUtilization = 0.0
		self.averageAirtimeRate = 0.0
		self.packetSuccessRate = 0.0
		self.packetFailureRate = 0.0
		self.aiSummaryText = ""
		self.numPacketsTx = 0
		self.numPacketsRx = 0
		self.numPacketsRxBad = 0
		self.numRxDupe = 0
		self.numTxRelay = 0
		self.numTxRelayCanceled = 0
		self.numOnlineNodes = 0
		self.numTotalNodes = 0
		self.uptimeSeconds = 0
		self.averageNoiseFloor = 0.0
		self.noiseFloorSampleCount = 0
		self.session = nil
		self.nodes = []
		self.beacons = []
	}
}