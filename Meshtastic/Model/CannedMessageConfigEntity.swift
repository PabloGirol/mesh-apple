//
//  CannedMessageConfigEntity.swift
//  Meshtastic
//
//  SwiftData model for canned message configuration.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(CannedMessageConfigEntity)
public class CannedMessageConfigEntity: NSManagedObject {

	@NSManaged public var enabled: Bool
	@NSManaged public var inputbrokerEventCcw: Int32
	@NSManaged public var inputbrokerEventCw: Int32
	@NSManaged public var inputbrokerEventPress: Int32
	@NSManaged public var inputbrokerPinA: Int32
	@NSManaged public var inputbrokerPinB: Int32
	@NSManaged public var inputbrokerPinPress: Int32
	@NSManaged public var messages: String?
	@NSManaged public var rotary1Enabled: Bool
	@NSManaged public var sendBell: Bool
	@NSManaged public var updown1Enabled: Bool
	@NSManaged public var cannedMessagesConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "CannedMessageConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.enabled = false
		self.inputbrokerEventCcw = 0
		self.inputbrokerEventCw = 0
		self.inputbrokerEventPress = 0
		self.inputbrokerPinA = 0
		self.inputbrokerPinB = 0
		self.inputbrokerPinPress = 0
		self.messages = nil
		self.rotary1Enabled = false
		self.sendBell = false
		self.updown1Enabled = false
		self.cannedMessagesConfigNode = nil
	}
}