//
//  TelemetryConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(TelemetryConfigEntity)
public class TelemetryConfigEntity: NSManagedObject {

}

extension TelemetryConfigEntity {
    public var airQualityEnabled: Bool {
        get { value(forKey: "airQualityEnabled") as! Bool }
        set { setValue(newValue, forKey: "airQualityEnabled") }
    }
    public var airQualityInterval: Int32 {
        get { value(forKey: "airQualityInterval") as! Int32 }
        set { setValue(newValue, forKey: "airQualityInterval") }
    }
    public var deviceTelemetryEnabled: Bool {
        get { value(forKey: "deviceTelemetryEnabled") as! Bool }
        set { setValue(newValue, forKey: "deviceTelemetryEnabled") }
    }
    public var deviceUpdateInterval: Int32 {
        get { value(forKey: "deviceUpdateInterval") as! Int32 }
        set { setValue(newValue, forKey: "deviceUpdateInterval") }
    }
    public var environmentDisplayFahrenheit: Bool {
        get { value(forKey: "environmentDisplayFahrenheit") as! Bool }
        set { setValue(newValue, forKey: "environmentDisplayFahrenheit") }
    }
    public var environmentMeasurementEnabled: Bool {
        get { value(forKey: "environmentMeasurementEnabled") as! Bool }
        set { setValue(newValue, forKey: "environmentMeasurementEnabled") }
    }
    public var environmentScreenEnabled: Bool {
        get { value(forKey: "environmentScreenEnabled") as! Bool }
        set { setValue(newValue, forKey: "environmentScreenEnabled") }
    }
    public var environmentUpdateInterval: Int32 {
        get { value(forKey: "environmentUpdateInterval") as! Int32 }
        set { setValue(newValue, forKey: "environmentUpdateInterval") }
    }
    public var powerMeasurementEnabled: Bool {
        get { value(forKey: "powerMeasurementEnabled") as! Bool }
        set { setValue(newValue, forKey: "powerMeasurementEnabled") }
    }
    public var powerScreenEnabled: Bool {
        get { value(forKey: "powerScreenEnabled") as! Bool }
        set { setValue(newValue, forKey: "powerScreenEnabled") }
    }
    public var powerUpdateInterval: Int32 {
        get { value(forKey: "powerUpdateInterval") as! Int32 }
        set { setValue(newValue, forKey: "powerUpdateInterval") }
    }
    public var telemetryConfigNode: NodeInfoEntity? {
        get { value(forKey: "telemetryConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "telemetryConfigNode") }
    }
}

extension TelemetryConfigEntity: CoreDataEntity {
    public static var entityName: String { "TelemetryConfigEntity" }
}
