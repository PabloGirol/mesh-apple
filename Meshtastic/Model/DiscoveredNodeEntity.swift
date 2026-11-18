//
//  DiscoveredNodeEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for discovered node data.
//  Converted from SwiftData for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DiscoveredNodeEntity)
public class DiscoveredNodeEntity: NSManagedObject {

	@NSManaged public var nodeNum: Int64
	@NSManaged public var shortName: String
	@NSManaged public var longName: String
	@NSManaged public var neighborType: String
	@NSManaged public var latitude: Double
	@NSManaged public var longitude: Double
	@NSManaged public var distanceFromUser: Double
	@NSManaged public var hopCount: Int32
	@NSManaged public var snr: Float
	@NSManaged public var rssi: Int32
	@NSManaged public var messageCount: Int32
	@NSManaged public var sensorPacketCount: Int32
	@NSManaged public var isInfrastructure: Bool
	@NSManaged public var presetName: String

	@NSManaged public var session: DiscoverySessionEntity?
	@NSManaged public var presetResult: DiscoveryPresetResultEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DiscoveredNodeEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.nodeNum = 0
		self.shortName = ""
		self.longName = ""
		self.neighborType = "direct"
		self.latitude = 0.0
		self.longitude = 0.0
		self.distanceFromUser = 0.0
		self.hopCount = 0
		self.snr = 0.0
		self.rssi = 0
		self.messageCount = 0
		self.sensorPacketCount = 0
		self.isInfrastructure = false
		self.presetName = ""
		self.session = nil
		self.presetResult = nil
	}

	/// FR-011: messageCount >= sensorPacketCount → person.2.fill, else thermometer.medium
	public var iconName: String {
		messageCount >= sensorPacketCount ? "person.2.fill" : "thermometer.medium"
	}

	/// A node label for display and VoiceOver, preferring the long name, then short, then the hex id.
	/// The hex fallback intentionally matches `DiscoveryMapView`'s existing `CircleText` fallback
	/// (last 4 hex digits, not `DiscoveredBeaconEntity.displayName`'s `!%08x` format) so a pin's
	/// VoiceOver title and its visible abbreviation stay consistent.
	public var displayName: String {
		if !longName.isEmpty { return longName }
		if !shortName.isEmpty { return shortName }
		return String(nodeNum.toHex().suffix(4))
	}
}