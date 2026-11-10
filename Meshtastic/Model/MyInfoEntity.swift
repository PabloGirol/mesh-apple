//
//  MyInfoEntity.swift
//  Meshtastic
//
//  Core Data model for connected device info.
//

import Foundation
import CoreData

@objc(MyInfoEntity)
public class MyInfoEntity: NSManagedObject {

	@NSManaged public var bleName: String?
	@NSManaged public var deviceId: Data?
	@NSManaged public var minAppVersion: Int32
	@NSManaged public var myNodeNum: Int64
	@NSManaged public var peripheralId: String?
	@NSManaged public var pioEnv: String?
	@NSManaged public var rebootCount: Int32
	@NSManaged public var registered: Bool

	@NSManaged public var channels: [ChannelEntity]
	@NSManaged public var myInfoNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "MyInfoEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.minAppVersion = 0
		self.myNodeNum = 0
		self.rebootCount = 0
		self.registered = false
		self.channels = []
	}
}