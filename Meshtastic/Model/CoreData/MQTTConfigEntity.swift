//
//  MQTTConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(MQTTConfigEntity)
public class MQTTConfigEntity: NSManagedObject {

}

extension MQTTConfigEntity {
    public var address: String?? {
        get { value(forKey: "address") as? String? }
        set { setValue(newValue, forKey: "address") }
    }
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var encryptionEnabled: Bool {
        get { value(forKey: "encryptionEnabled") as! Bool }
        set { setValue(newValue, forKey: "encryptionEnabled") }
    }
    public var jsonEnabled: Bool {
        get { value(forKey: "jsonEnabled") as! Bool }
        set { setValue(newValue, forKey: "jsonEnabled") }
    }
    public var mapPositionPrecision: Int32 {
        get { value(forKey: "mapPositionPrecision") as! Int32 }
        set { setValue(newValue, forKey: "mapPositionPrecision") }
    }
    public var mapPublishIntervalSecs: Int32 {
        get { value(forKey: "mapPublishIntervalSecs") as! Int32 }
        set { setValue(newValue, forKey: "mapPublishIntervalSecs") }
    }
    public var mapReportingEnabled: Bool {
        get { value(forKey: "mapReportingEnabled") as! Bool }
        set { setValue(newValue, forKey: "mapReportingEnabled") }
    }
    public var mapReportingShouldReportLocation: Bool {
        get { value(forKey: "mapReportingShouldReportLocation") as! Bool }
        set { setValue(newValue, forKey: "mapReportingShouldReportLocation") }
    }
    public var password: String?? {
        get { value(forKey: "password") as? String? }
        set { setValue(newValue, forKey: "password") }
    }
    public var proxyToClientEnabled: Bool {
        get { value(forKey: "proxyToClientEnabled") as! Bool }
        set { setValue(newValue, forKey: "proxyToClientEnabled") }
    }
    public var root: String?? {
        get { value(forKey: "root") as? String? }
        set { setValue(newValue, forKey: "root") }
    }
    public var tlsEnabled: Bool {
        get { value(forKey: "tlsEnabled") as! Bool }
        set { setValue(newValue, forKey: "tlsEnabled") }
    }
    public var username: String?? {
        get { value(forKey: "username") as? String? }
        set { setValue(newValue, forKey: "username") }
    }
    public var mqttConfigNode: NodeInfoEntity? {
        get { value(forKey: "mqttConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "mqttConfigNode") }
    }
}

extension MQTTConfigEntity: CoreDataEntity {
    public static var entityName: String { "MQTTConfigEntity" }
}
