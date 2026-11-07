//
//  LocationEntity.swift
//  Meshtastic
//
//  Core Data entity for LocationEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(LocationEntity)
public class LocationEntity: NSManagedObject {

}

extension LocationEntity {
    @NSManaged public var id: UUID
    @NSManaged public var latitudeI: Int32
    @NSManaged public var longitudeI: Int32
    @NSManaged public var altitude: Int32
    @NSManaged public var timestamp: Date
    @NSManaged public var sequence: Int32
    @NSManaged public var route: RouteEntity?
}

extension LocationEntity: CoreDataEntity {
    public static var entityName: String { "LocationEntity" }
}
