//
//  PositionConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for PositionConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(PositionConfigEntity)
public class PositionConfigEntity: NSManagedObject {

}

extension PositionConfigEntity {
    @NSManaged public var deviceGpsEnabled: Bool
    @NSManaged public var fixedPosition: Bool
    @NSManaged public var gpsAttemptTime: Int32
    @NSManaged public var gpsUpdateInterval: Int32
    @NSManaged public var positionBroadcastSeconds: Int32
    @NSManaged public var positionFlags: Int32
    @NSManaged public var smartPositionEnabled: Bool
    @NSManaged public var positionConfigNode: NodeInfoEntity?
}

extension PositionConfigEntity: CoreDataEntity {
    public static var entityName: String { "PositionConfigEntity" }
}
