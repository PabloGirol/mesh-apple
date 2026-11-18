//
//  DiscoverySessionEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for discovery sessions.
//  Converted from SwiftData for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DiscoverySessionEntity)
public class DiscoverySessionEntity: NSManagedObject {

	@NSManaged public var timestamp: Date
	@NSManaged public var presetsScanned: String
	@NSManaged public var totalUniqueNodes: Int32
	@NSManaged public var averageChannelUtilization: Double
	@NSManaged public var totalTextMessages: Int32
	@NSManaged public var totalSensorPackets: Int32
	@NSManaged public var furthestNodeDistance: Double
	@NSManaged public var completionStatus: String
	@NSManaged public var aiSummaryText: String
	@NSManaged public var homePreset: String
	@NSManaged public var userLatitude: Double
	@NSManaged public var userLongitude: Double

	@NSManaged public var presetResults: [DiscoveryPresetResultEntity]
	@NSManaged public var discoveredNodes: [DiscoveredNodeEntity]
	@NSManaged public var beacons: [DiscoveredBeaconEntity]

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DiscoverySessionEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.timestamp = Date()
		self.presetsScanned = ""
		self.totalUniqueNodes = 0
		self.averageChannelUtilization = 0.0
		self.totalTextMessages = 0
		self.totalSensorPackets = 0
		self.furthestNodeDistance = 0.0
		self.completionStatus = "inProgress"
		self.aiSummaryText = ""
		self.homePreset = ""
		self.userLatitude = 0.0
		self.userLongitude = 0.0
		self.presetResults = []
		self.discoveredNodes = []
		self.beacons = []
	}
}