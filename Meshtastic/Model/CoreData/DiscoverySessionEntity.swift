//
//  DiscoverySessionEntity.swift
//  Meshtastic
//
//  Core Data entity for DiscoverySessionEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DiscoverySessionEntity)
public class DiscoverySessionEntity: NSManagedObject {

}

extension DiscoverySessionEntity {
    @NSManaged public var id: UUID
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date??
    @NSManaged public var selectedPresets: Data
    @NSManaged public var dwellDuration: Int32
    @NSManaged public var completed: Bool
    @NSManaged public var presetResults: NSSet
    @NSManaged public var discoveredNodes: NSSet
    @NSManaged public var discoveredBeacons: NSSet

    @objc(addPresetresultsObject:)
    @NSManaged public func addToPresetresults(_ value: DiscoveryPresetResultEntity)

    @objc(removePresetresultsObject:)
    @NSManaged public func removeFromPresetresults(_ value: DiscoveryPresetResultEntity)

    @objc(addPresetresults:)
    @NSManaged public func addToPresetresults(_ values: NSSet)

    @objc(removePresetresults:)
    @NSManaged public func removeFromPresetresults(_ values: NSSet)


    @objc(addDiscoverednodesObject:)
    @NSManaged public func addToDiscoverednodes(_ value: DiscoveredNodeEntity)

    @objc(removeDiscoverednodesObject:)
    @NSManaged public func removeFromDiscoverednodes(_ value: DiscoveredNodeEntity)

    @objc(addDiscoverednodes:)
    @NSManaged public func addToDiscoverednodes(_ values: NSSet)

    @objc(removeDiscoverednodes:)
    @NSManaged public func removeFromDiscoverednodes(_ values: NSSet)


    @objc(addDiscoveredbeaconsObject:)
    @NSManaged public func addToDiscoveredbeacons(_ value: DiscoveredBeaconEntity)

    @objc(removeDiscoveredbeaconsObject:)
    @NSManaged public func removeFromDiscoveredbeacons(_ value: DiscoveredBeaconEntity)

    @objc(addDiscoveredbeacons:)
    @NSManaged public func addToDiscoveredbeacons(_ values: NSSet)

    @objc(removeDiscoveredbeacons:)
    @NSManaged public func removeFromDiscoveredbeacons(_ values: NSSet)

}

extension DiscoverySessionEntity: CoreDataEntity {
    public static var entityName: String { "DiscoverySessionEntity" }
}
