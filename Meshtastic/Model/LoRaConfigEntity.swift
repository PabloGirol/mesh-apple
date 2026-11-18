//
//  LoRaConfigEntity.swift
//  Meshtastic
//
//  SwiftData model for LoRa configuration entity.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(LoRaConfigEntity)
public class LoRaConfigEntity: NSManagedObject {

    @NSManaged public var bandwidth: Int32
    @NSManaged public var channelNum: Int32
    @NSManaged public var codingRate: Int32
    @NSManaged public var frequencyOffset: Float
    @NSManaged public var hopLimit: Int32
    @NSManaged public var ignoreMqtt: Bool
    @NSManaged public var modemPreset: Int32
    @NSManaged public var okToMqtt: Bool
    @NSManaged public var overrideDutyCycle: Bool
    @NSManaged public var paFanDisabled: Bool
    @NSManaged public var overrideFrequency: Float
    @NSManaged public var regionCode: Int32
    @NSManaged public var spreadFactor: Int32
    @NSManaged public var sx126xRxBoostedGain: Bool
    @NSManaged public var txEnabled: Bool
    @NSManaged public var txPower: Int32
    @NSManaged public var usePreset: Bool

    // Inverse relationship to NodeInfoEntity
    @NSManaged public var loRaConfigNode: NodeInfoEntity?

    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "LoRaConfigEntity", in: context)!
        self.init(entity: entity, insertInto: context)
        self.bandwidth = 0
        self.channelNum = 0
        self.codingRate = 0
        self.frequencyOffset = 0
        self.hopLimit = 0
        self.ignoreMqtt = false
        self.modemPreset = 0
        self.okToMqtt = false
        self.overrideDutyCycle = false
        self.paFanDisabled = false
        self.overrideFrequency = 0.0
        self.regionCode = 0
        self.spreadFactor = 0
        self.sx126xRxBoostedGain = false
        self.txEnabled = true
        self.txPower = 0
        self.usePreset = true
        self.loRaConfigNode = nil
    }
}