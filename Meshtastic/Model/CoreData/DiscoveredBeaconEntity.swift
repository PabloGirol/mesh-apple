//
//  DiscoveredBeaconEntity.swift
//  Meshtastic
//
//  Core Data entity for DiscoveredBeaconEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DiscoveredBeaconEntity)
public class DiscoveredBeaconEntity: NSManagedObject {

}

extension DiscoveredBeaconEntity {
    @NSManaged public var channelIndex: Int32
    @NSManaged public var nodeNum: Int64
    @NSManaged public var snr: Float
    @NSManaged public var lastHeard: Date
    @NSManaged public var hopLimit: Int32
    @NSManaged public var payload: Data??
    @NSManaged public var session: DiscoverySessionEntity?
}

extension DiscoveredBeaconEntity: CoreDataEntity {
    public static var entityName: String { "DiscoveredBeaconEntity" }
}
