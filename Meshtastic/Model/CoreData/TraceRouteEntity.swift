//
//  TraceRouteEntity.swift
//  Meshtastic
//
//  Core Data entity for TraceRouteEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(TraceRouteEntity)
public class TraceRouteEntity: NSManagedObject {

}

extension TraceRouteEntity {
    @NSManaged public var id: UUID
    @NSManaged public var targetNodeNum: Int64
    @NSManaged public var startTime: Date
    @NSManaged public var completed: Bool
    @NSManaged public var hops: NSSet

    @objc(addHopsObject:)
    @NSManaged public func addToHops(_ value: TraceRouteHopEntity)

    @objc(removeHopsObject:)
    @NSManaged public func removeFromHops(_ value: TraceRouteHopEntity)

    @objc(addHops:)
    @NSManaged public func addToHops(_ values: NSSet)

    @objc(removeHops:)
    @NSManaged public func removeFromHops(_ values: NSSet)

}

extension TraceRouteEntity: CoreDataEntity {
    public static var entityName: String { "TraceRouteEntity" }
}
