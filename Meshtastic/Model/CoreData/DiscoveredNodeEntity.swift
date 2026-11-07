//
//  DiscoveredNodeEntity.swift
//  Meshtastic
//
//  Core Data entity for DiscoveredNodeEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DiscoveredNodeEntity)
public class DiscoveredNodeEntity: NSManagedObject {

}

extension DiscoveredNodeEntity {
    @NSManaged public var nodeNum: Int64
    @NSManaged public var snr: Float
    @NSManaged public var lastHeard: Date
    @NSManaged public var hopsAway: Int32
    @NSManaged public var session: DiscoverySessionEntity?
}

extension DiscoveredNodeEntity: CoreDataEntity {
    public static var entityName: String { "DiscoveredNodeEntity" }
}
