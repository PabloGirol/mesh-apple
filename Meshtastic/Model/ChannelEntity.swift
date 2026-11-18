//
//  ChannelEntity.swift
//  Meshtastic
//
//  SwiftData model for channels.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(ChannelEntity)
public class ChannelEntity: NSManagedObject {

	@NSManaged public var downlinkEnabled: Bool
	@NSManaged public var id: Int32
	@NSManaged public var index: Int32
	@NSManaged public var mute: Bool
	@NSManaged public var name: String?
	@NSManaged public var positionPrecision: Int32
	@NSManaged public var psk: Data?
	@NSManaged public var role: Int32
	@NSManaged public var uplinkEnabled: Bool

	@NSManaged public var myInfoChannel: MyInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "ChannelEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.downlinkEnabled = false
		self.id = 0
		self.index = 0
		self.mute = false
		self.name = nil
		self.positionPrecision = 32
		self.psk = nil
		self.role = 0
		self.uplinkEnabled = false
		self.myInfoChannel = nil
	}
}