//
//  NeighborLinkEntity.swift
//  Meshtastic
//
//  Core Data entity for NeighborLinkEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(NeighborLinkEntity)
public class NeighborLinkEntity: NSManagedObject {

}

extension NeighborLinkEntity {
    @NSManaged public var id: UUID
    @NSManaged public var localNodeNum: Int64
    @NSManaged public var neighborNodeNum: Int64
    @NSManaged public var snr: Float
    @NSManaged public var channel: Int32
    @NSManaged public var lastHeard: Date
}

extension NeighborLinkEntity: CoreDataEntity {
    public static var entityName: String { "NeighborLinkEntity" }
}
