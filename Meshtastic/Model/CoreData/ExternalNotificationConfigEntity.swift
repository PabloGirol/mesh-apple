//
//  ExternalNotificationConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for ExternalNotificationConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(ExternalNotificationConfigEntity)
public class ExternalNotificationConfigEntity: NSManagedObject {

}

extension ExternalNotificationConfigEntity {
    @NSManaged public var active: Bool
    @NSManaged public var alertBell: Bool
    @NSManaged public var alertMessage: Bool
    @NSManaged public var enabled: Bool
    @NSManaged public var output: Int32
    @NSManaged public var outputMilliseconds: Int32
    @NSManaged public var externalNotificationConfigNode: NodeInfoEntity?
}

extension ExternalNotificationConfigEntity: CoreDataEntity {
    public static var entityName: String { "ExternalNotificationConfigEntity" }
}
