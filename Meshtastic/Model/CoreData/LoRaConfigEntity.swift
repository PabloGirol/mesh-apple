//
//  LoRaConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for LoRaConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(LoRaConfigEntity)
public class LoRaConfigEntity: NSManagedObject {

}

extension LoRaConfigEntity {
    @NSManaged public var bandwidth: Int32
    @NSManaged public var channelNum: Int32
    @NSManaged public var codingRate: Int32
    @NSManaged public var frequencyOffset: Float
    @NSManaged public var hopLimit: Int32
    @NSManaged public var modemPreset: Int32
    @NSManaged public var regionCode: Int32
    @NSManaged public var spreadFactor: Int32
    @NSManaged public var txEnabled: Bool
    @NSManaged public var txPower: Int32
    @NSManaged public var usePreset: Bool
    @NSManaged public var loRaConfigNode: NodeInfoEntity?
}

extension LoRaConfigEntity: CoreDataEntity {
    public static var entityName: String { "LoRaConfigEntity" }
}
