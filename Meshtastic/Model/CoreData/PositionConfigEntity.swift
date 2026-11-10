//
//  PositionConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(PositionConfigEntity)
public class PositionConfigEntity: NSManagedObject {

}

extension PositionConfigEntity {
    public var broadcastSmartMinimumDistance: Int32 {
        get { value(forKey: "broadcastSmartMinimumDistance") as! Int32 }
        set { setValue(newValue, forKey: "broadcastSmartMinimumDistance") }
    }
    public var broadcastSmartMinimumIntervalSecs: Int32 {
        get { value(forKey: "broadcastSmartMinimumIntervalSecs") as! Int32 }
        set { setValue(newValue, forKey: "broadcastSmartMinimumIntervalSecs") }
    }
    public var deviceGpsEnabled: Bool {
        get { value(forKey: "deviceGpsEnabled") as! Bool }
        set { setValue(newValue, forKey: "deviceGpsEnabled") }
    }
    public var fixedPosition: Bool {
        get { value(forKey: "fixedPosition") as! Bool }
        set { setValue(newValue, forKey: "fixedPosition") }
    }
    public var gpsAttemptTime: Int32 {
        get { value(forKey: "gpsAttemptTime") as! Int32 }
        set { setValue(newValue, forKey: "gpsAttemptTime") }
    }
    public var gpsEnGpio: Int32 {
        get { value(forKey: "gpsEnGpio") as! Int32 }
        set { setValue(newValue, forKey: "gpsEnGpio") }
    }
    public var gpsMode: Int32 {
        get { value(forKey: "gpsMode") as! Int32 }
        set { setValue(newValue, forKey: "gpsMode") }
    }
    public var gpsUpdateInterval: Int32 {
        get { value(forKey: "gpsUpdateInterval") as! Int32 }
        set { setValue(newValue, forKey: "gpsUpdateInterval") }
    }
    public var positionBroadcastSeconds: Int32 {
        get { value(forKey: "positionBroadcastSeconds") as! Int32 }
        set { setValue(newValue, forKey: "positionBroadcastSeconds") }
    }
    public var positionFlags: Int32 {
        get { value(forKey: "positionFlags") as! Int32 }
        set { setValue(newValue, forKey: "positionFlags") }
    }
    public var rxGpio: Int32 {
        get { value(forKey: "rxGpio") as! Int32 }
        set { setValue(newValue, forKey: "rxGpio") }
    }
    public var smartPositionEnabled: Bool {
        get { value(forKey: "smartPositionEnabled") as! Bool }
        set { setValue(newValue, forKey: "smartPositionEnabled") }
    }
    public var txGpio: Int32 {
        get { value(forKey: "txGpio") as! Int32 }
        set { setValue(newValue, forKey: "txGpio") }
    }
    public var positionConfigNode: NodeInfoEntity? {
        get { value(forKey: "positionConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "positionConfigNode") }
    }
}

extension PositionConfigEntity: CoreDataEntity {
    public static var entityName: String { "PositionConfigEntity" }
}
