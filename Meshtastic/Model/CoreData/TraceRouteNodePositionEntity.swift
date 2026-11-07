//
//  TraceRouteNodePositionEntity.swift
//  Meshtastic
//
//  Core Data entity for TraceRouteNodePositionEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(TraceRouteNodePositionEntity)
public class TraceRouteNodePositionEntity: NSManagedObject {

}

extension TraceRouteNodePositionEntity {
    @NSManaged public var nodeNum: Int64
    @NSManaged public var latitudeI: Int32
    @NSManaged public var longitudeI: Int32
}

extension TraceRouteNodePositionEntity: CoreDataEntity {
    public static var entityName: String { "TraceRouteNodePositionEntity" }
}
