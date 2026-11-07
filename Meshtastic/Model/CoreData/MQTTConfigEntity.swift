//
//  MQTTConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for MQTTConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(MQTTConfigEntity)
public class MQTTConfigEntity: NSManagedObject {

}

extension MQTTConfigEntity {
    @NSManaged public var address: String??
    @NSManaged public var enabled: Bool
    @NSManaged public var encryptionEnabled: Bool
    @NSManaged public var jsonEnabled: Bool
    @NSManaged public var password: String??
    @NSManaged public var username: String??
    @NSManaged public var mqttConfigNode: NodeInfoEntity?
}

extension MQTTConfigEntity: CoreDataEntity {
    public static var entityName: String { "MQTTConfigEntity" }
}
