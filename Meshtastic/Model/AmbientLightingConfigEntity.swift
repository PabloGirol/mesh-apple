//
//  AmbientLightingConfigEntity.swift
//  Meshtastic
//
//  SwiftData model for ambient lighting configuration.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(AmbientLightingConfigEntity)
public class AmbientLightingConfigEntity: NSManagedObject {

	@NSManaged public var blue: Int32
	@NSManaged public var current: Int32
	@NSManaged public var green: Int32
	@NSManaged public var ledState: Bool
	@NSManaged public var red: Int32
	@NSManaged public var ambientLightingConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "AmbientLightingConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.blue = 0
		self.current = 0
		self.green = 0
		self.ledState = false
		self.red = 0
		self.ambientLightingConfigNode = nil
	}
}