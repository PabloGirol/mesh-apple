//
//  PositionEntity.swift
//  Meshtastic
//
//  SwiftData model for node positions.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(PositionEntity)
public class PositionEntity: NSManagedObject {

	@NSManaged public var altitude: Int32
	@NSManaged public var heading: Int32
	@NSManaged public var latest: Bool
	@NSManaged public var latitudeI: Int32
	@NSManaged public var longitudeI: Int32
	@NSManaged public var precisionBits: Int32
	@NSManaged public var rssi: Int32
	@NSManaged public var satsInView: Int32
	@NSManaged public var seqNo: Int32
	@NSManaged public var snr: Float
	@NSManaged public var speed: Int32
	@NSManaged public var time: Date?

	@NSManaged public var nodePosition: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "PositionEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.altitude = 0
		self.heading = 0
		self.latest = false
		self.latitudeI = 0
		self.longitudeI = 0
		self.precisionBits = 32
		self.rssi = 0
		self.satsInView = 0
		self.seqNo = 0
		self.snr = 0.0
		self.speed = 0
		self.time = nil
		self.nodePosition = nil
	}
}