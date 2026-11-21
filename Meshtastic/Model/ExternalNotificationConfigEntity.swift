//
//  ExternalNotificationConfigEntity.swift
//  Meshtastic
//
//  SwiftData model for External Notification configuration entity.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(ExternalNotificationConfigEntity)
public class ExternalNotificationConfigEntity: NSManagedObject {

    @NSManaged public var enabled: Bool
    @NSManaged public var usePWM: Bool
    @NSManaged public var alertBell: Bool
    @NSManaged public var alertBellBuzzer: Bool
    @NSManaged public var alertBellVibra: Bool
    @NSManaged public var alertMessage: Bool
    @NSManaged public var alertMessageBuzzer: Bool
    @NSManaged public var alertMessageVibra: Bool
    @NSManaged public var active: Bool
    @NSManaged public var output: Int32
    @NSManaged public var outputBuzzer: Int32
    @NSManaged public var outputVibra: Int32
    @NSManaged public var outputMilliseconds: Int32
    @NSManaged public var nagTimeout: Int32
    @NSManaged public var useI2SAsBuzzer: Bool

    // Inverse relationship to NodeInfoEntity
    @NSManaged public var externalNotificationConfigNode: NodeInfoEntity?

    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "ExternalNotificationConfigEntity", in: context)!
        self.init(entity: entity, insertInto: context)
        self.enabled = false
        self.usePWM = false
        self.alertBell = false
        self.alertBellBuzzer = false
        self.alertBellVibra = false
        self.alertMessage = false
        self.alertMessageBuzzer = false
        self.alertMessageVibra = false
        self.active = false
        self.output = 0
        self.outputBuzzer = 0
        self.outputVibra = 0
        self.outputMilliseconds = 0
        self.nagTimeout = 0
        self.useI2SAsBuzzer = false
        self.externalNotificationConfigNode = nil
    }
}
