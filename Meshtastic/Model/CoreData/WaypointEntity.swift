//
//  WaypointEntity.swift
//  Meshtastic
//
//  Core Data entity for WaypointEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(WaypointEntity)
public class WaypointEntity: NSManagedObject {

}

extension WaypointEntity {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String??
    @NSManaged public var latitudeI: Int32
    @NSManaged public var longitudeI: Int32
    @NSManaged public var altitude: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isShared: Bool
}

extension WaypointEntity: CoreDataEntity {
    public static var entityName: String { "WaypointEntity" }
}
