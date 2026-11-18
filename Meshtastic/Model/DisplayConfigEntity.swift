//
//  DisplayConfigEntity.swift
//  Meshtastic
//
//  SwiftData model for display configuration.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DisplayConfigEntity)
public class DisplayConfigEntity: NSManagedObject {

	@NSManaged public var compassNorthTop: Bool
	@NSManaged public var compassOrientation: Int32
	@NSManaged public var displayMode: Int32
	@NSManaged public var flipScreen: Bool
	@NSManaged public var headingBold: Bool
	@NSManaged public var oledType: Int32
	@NSManaged public var screenCarouselInterval: Int32
	@NSManaged public var screenOnSeconds: Int32
	@NSManaged public var units: Int32
	@NSManaged public var use12HClock: Bool
	@NSManaged public var wakeOnTapOrMotion: Bool
	@NSManaged public var displayConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DisplayConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.compassNorthTop = false
		self.compassOrientation = 0
		self.displayMode = 0
		self.flipScreen = false
		self.headingBold = true
		self.oledType = 0
		self.screenCarouselInterval = 0
		self.screenOnSeconds = 0
		self.units = 0
		self.use12HClock = false
		self.wakeOnTapOrMotion = false
		self.displayConfigNode = nil
	}
}