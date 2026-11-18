//
//  DetectionSensorConfigEntity.swift
//  Meshtastic
//
//  SwiftData model for detection sensor configuration.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DetectionSensorConfigEntity)
public class DetectionSensorConfigEntity: NSManagedObject {

	@NSManaged public var enabled: Bool
	@NSManaged public var minimumBroadcastSecs: Int32
	@NSManaged public var monitorPin: Int32
	@NSManaged public var name: String?
	@NSManaged public var sendBell: Bool
	@NSManaged public var stateBroadcastSecs: Int32
	@NSManaged public var triggerType: Int32
	@NSManaged public var usePullup: Bool
	@NSManaged public var detectionSensorConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DetectionSensorConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.enabled = false
		self.minimumBroadcastSecs = 0
		self.monitorPin = 0
		self.name = nil
		self.sendBell = false
		self.stateBroadcastSecs = 0
		self.triggerType = 0
		self.usePullup = false
		self.detectionSensorConfigNode = nil
	}
}