//
//  DiscoveryPresetResultEntity.swift
//  Meshtastic
//
//  Core Data entity for DiscoveryPresetResultEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DiscoveryPresetResultEntity)
public class DiscoveryPresetResultEntity: NSManagedObject {

}

extension DiscoveryPresetResultEntity {
    @NSManaged public var presetIndex: Int32
    @NSManaged public var presetName: String
    @NSManaged public var nodesHeard: Int32
    @NSManaged public var snrSum: Float
    @NSManaged public var snrCount: Int32
    @NSManaged public var session: DiscoverySessionEntity?
}

extension DiscoveryPresetResultEntity: CoreDataEntity {
    public static var entityName: String { "DiscoveryPresetResultEntity" }
}
