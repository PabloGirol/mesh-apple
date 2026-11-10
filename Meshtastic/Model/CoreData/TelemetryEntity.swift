//
//  TelemetryEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(TelemetryEntity)
public class TelemetryEntity: NSManagedObject {

}

extension TelemetryEntity {
    public var metricsType: Int32 {
        get { value(forKey: "metricsType") as! Int32 }
        set { setValue(newValue, forKey: "metricsType") }
    }
    public var time: Date?? {
        get { value(forKey: "time") as? Date? }
        set { setValue(newValue, forKey: "time") }
    }
    public var airUtilTx: Float?? {
        get { value(forKey: "airUtilTx") as? Float? }
        set { setValue(newValue, forKey: "airUtilTx") }
    }
    public var barometricPressure: Float?? {
        get { value(forKey: "barometricPressure") as? Float? }
        set { setValue(newValue, forKey: "barometricPressure") }
    }
    public var batteryLevel: Int32?? {
        get { value(forKey: "batteryLevel") as? Int32? }
        set { setValue(newValue, forKey: "batteryLevel") }
    }
    public var channelUtilization: Float?? {
        get { value(forKey: "channelUtilization") as? Float? }
        set { setValue(newValue, forKey: "channelUtilization") }
    }
    public var current: Float?? {
        get { value(forKey: "current") as? Float? }
        set { setValue(newValue, forKey: "current") }
    }
    public var gasResistance: Float?? {
        get { value(forKey: "gasResistance") as? Float? }
        set { setValue(newValue, forKey: "gasResistance") }
    }
    public var relativeHumidity: Float?? {
        get { value(forKey: "relativeHumidity") as? Float? }
        set { setValue(newValue, forKey: "relativeHumidity") }
    }
    public var temperature: Float?? {
        get { value(forKey: "temperature") as? Float? }
        set { setValue(newValue, forKey: "temperature") }
    }
    public var voltage: Float?? {
        get { value(forKey: "voltage") as? Float? }
        set { setValue(newValue, forKey: "voltage") }
    }
    public var nodeTelemetry: NodeInfoEntity? {
        get { value(forKey: "nodeTelemetry") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "nodeTelemetry") }
    }
}

extension TelemetryEntity: CoreDataEntity {
    public static var entityName: String { "TelemetryEntity" }
}
