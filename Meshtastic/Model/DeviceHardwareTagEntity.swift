//
//  DeviceHardwareTagEntity.swift
//  Meshtastic
//
//  SwiftData model for device hardware tags.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DeviceHardwareTagEntity)
public class DeviceHardwareTagEntity: NSManagedObject {

	@NSManaged public var tag: String
	@NSManaged public var devices: [DeviceHardwareEntity]

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DeviceHardwareTagEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.tag = ""
		self.devices = []
	}
}