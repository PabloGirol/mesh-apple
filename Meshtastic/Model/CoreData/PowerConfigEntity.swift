//
//  PowerConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(PowerConfigEntity)
public class PowerConfigEntity: NSManagedObject {

}

extension PowerConfigEntity {
    public var adcMultiplierOverride: Float {
        get { value(forKey: "adcMultiplierOverride") as! Float }
        set { setValue(newValue, forKey: "adcMultiplierOverride") }
    }
    public var deviceBatteryInaAddress: Int32 {
        get { value(forKey: "deviceBatteryInaAddress") as! Int32 }
        set { setValue(newValue, forKey: "deviceBatteryInaAddress") }
    }
    public var isPowerSaving: Bool {
        get { value(forKey: "isPowerSaving") as! Bool }
        set { setValue(newValue, forKey: "isPowerSaving") }
    }
    public var lsSecs: Int32 {
        get { value(forKey: "lsSecs") as! Int32 }
        set { setValue(newValue, forKey: "lsSecs") }
    }
    public var minWakeSecs: Int32 {
        get { value(forKey: "minWakeSecs") as! Int32 }
        set { setValue(newValue, forKey: "minWakeSecs") }
    }
    public var onBatteryShutdownAfterSecs: Int32 {
        get { value(forKey: "onBatteryShutdownAfterSecs") as! Int32 }
        set { setValue(newValue, forKey: "onBatteryShutdownAfterSecs") }
    }
    public var waitBluetoothSecs: Int32 {
        get { value(forKey: "waitBluetoothSecs") as! Int32 }
        set { setValue(newValue, forKey: "waitBluetoothSecs") }
    }
    public var powerConfigNode: NodeInfoEntity? {
        get { value(forKey: "powerConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "powerConfigNode") }
    }
}

extension PowerConfigEntity: CoreDataEntity {
    public static var entityName: String { "PowerConfigEntity" }
}
