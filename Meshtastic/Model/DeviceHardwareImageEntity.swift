//
//  DeviceHardwareImageEntity.swift
//  Meshtastic
//
//  SwiftData model for device hardware images.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DeviceHardwareImageEntity)
public class DeviceHardwareImageEntity: NSManagedObject {

	@NSManaged public var eTag: String?
	@NSManaged public var fileName: String?
	@NSManaged public var svgData: Data?
	@NSManaged public var device: DeviceHardwareEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DeviceHardwareImageEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.eTag = nil
		self.fileName = nil
		self.svgData = nil
		self.device = nil
	}
}