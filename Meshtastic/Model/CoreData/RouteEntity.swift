//
//  RouteEntity.swift
//  Meshtastic
//
//  Core Data entity for RouteEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(RouteEntity)
public class RouteEntity: NSManagedObject {

}

extension RouteEntity {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var locations: NSSet

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: LocationEntity)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: LocationEntity)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

extension RouteEntity: CoreDataEntity {
    public static var entityName: String { "RouteEntity" }
}
