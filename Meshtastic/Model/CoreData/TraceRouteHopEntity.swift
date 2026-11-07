//
//  TraceRouteHopEntity.swift
//  Meshtastic
//
//  Core Data entity for TraceRouteHopEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(TraceRouteHopEntity)
public class TraceRouteHopEntity: NSManagedObject {

}

extension TraceRouteHopEntity {
    @NSManaged public var hopIndex: Int32
    @NSManaged public var nodeNum: Int64
    @NSManaged public var snrTowards: Float
    @NSManaged public var snrBack: Float
    @NSManaged public var traceRoute: TraceRouteEntity?
}

extension TraceRouteHopEntity: CoreDataEntity {
    public static var entityName: String { "TraceRouteHopEntity" }
}
