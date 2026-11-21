//
//  BroadcastTargetEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for mesh beacon broadcast targets.
//  Converted from SwiftData @Model for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(BroadcastTargetEntity)
public class BroadcastTargetEntity: NSManagedObject {

	@NSManaged public var channelIndex: Int32
	@NSManaged public var region: Int32
	@NSManaged public var preset: Int32
	@NSManaged public var frequencySlot: Int32
	@NSManaged public var psk: Data?
	@NSManaged public var channelName: String?
	@NSManaged public var meshBeaconConfig: MeshBeaconConfigEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "BroadcastTargetEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.channelIndex = 0
		self.region = 0
		self.preset = -1
		self.frequencySlot = 0
		self.psk = nil
		self.channelName = nil
		self.meshBeaconConfig = nil
	}

	convenience init(context: NSManagedObjectContext, preset: Int32, region: Int32, channelIndex: Int32, frequencySlot: Int32) {
		let entity = NSEntityDescription.entity(forEntityName: "BroadcastTargetEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.channelIndex = channelIndex
		self.region = region
		self.preset = preset
		self.frequencySlot = frequencySlot
		self.psk = nil
		self.channelName = nil
		self.meshBeaconConfig = nil
	}
}

