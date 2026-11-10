//
//  LoRaConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(LoRaConfigEntity)
public class LoRaConfigEntity: NSManagedObject {

}

extension LoRaConfigEntity {
    public var bandwidth: Int32 {
        get { value(forKey: "bandwidth") as! Int32 }
        set { setValue(newValue, forKey: "bandwidth") }
    }
    public var channelNum: Int32 {
        get { value(forKey: "channelNum") as! Int32 }
        set { setValue(newValue, forKey: "channelNum") }
    }
    public var codingRate: Int32 {
        get { value(forKey: "codingRate") as! Int32 }
        set { setValue(newValue, forKey: "codingRate") }
    }
    public var frequencyOffset: Float {
        get { value(forKey: "frequencyOffset") as! Float }
        set { setValue(newValue, forKey: "frequencyOffset") }
    }
    public var hopLimit: Int32 {
        get { value(forKey: "hopLimit") as! Int32 }
        set { setValue(newValue, forKey: "hopLimit") }
    }
    public var ignoreMqtt: Bool {
        get { value(forKey: "ignoreMqtt") as! Bool }
        set { setValue(newValue, forKey: "ignoreMqtt") }
    }
    public var modemPreset: Int32 {
        get { value(forKey: "modemPreset") as! Int32 }
        set { setValue(newValue, forKey: "modemPreset") }
    }
    public var okToMqtt: Bool {
        get { value(forKey: "okToMqtt") as! Bool }
        set { setValue(newValue, forKey: "okToMqtt") }
    }
    public var overrideDutyCycle: Bool {
        get { value(forKey: "overrideDutyCycle") as! Bool }
        set { setValue(newValue, forKey: "overrideDutyCycle") }
    }
    public var paFanDisabled: Bool {
        get { value(forKey: "paFanDisabled") as! Bool }
        set { setValue(newValue, forKey: "paFanDisabled") }
    }
    public var overrideFrequency: Float {
        get { value(forKey: "overrideFrequency") as! Float }
        set { setValue(newValue, forKey: "overrideFrequency") }
    }
    public var regionCode: Int32 {
        get { value(forKey: "regionCode") as! Int32 }
        set { setValue(newValue, forKey: "regionCode") }
    }
    public var spreadFactor: Int32 {
        get { value(forKey: "spreadFactor") as! Int32 }
        set { setValue(newValue, forKey: "spreadFactor") }
    }
    public var sx126xRxBoostedGain: Bool {
        get { value(forKey: "sx126xRxBoostedGain") as! Bool }
        set { setValue(newValue, forKey: "sx126xRxBoostedGain") }
    }
    public var txEnabled: Bool {
        get { value(forKey: "txEnabled") as! Bool }
        set { setValue(newValue, forKey: "txEnabled") }
    }
    public var txPower: Int32 {
        get { value(forKey: "txPower") as! Int32 }
        set { setValue(newValue, forKey: "txPower") }
    }
    public var usePreset: Bool {
        get { value(forKey: "usePreset") as! Bool }
        set { setValue(newValue, forKey: "usePreset") }
    }
    public var loRaConfigNode: NodeInfoEntity? {
        get { value(forKey: "loRaConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "loRaConfigNode") }
    }
}

extension LoRaConfigEntity: CoreDataEntity {
    public static var entityName: String { "LoRaConfigEntity" }
}
