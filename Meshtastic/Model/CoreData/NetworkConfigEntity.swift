//
//  NetworkConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(NetworkConfigEntity)
public class NetworkConfigEntity: NSManagedObject {

}

extension NetworkConfigEntity {
    public var addressMode: Int32 {
        get { value(forKey: "addressMode") as! Int32 }
        set { setValue(newValue, forKey: "addressMode") }
    }
    public var dns: Int32 {
        get { value(forKey: "dns") as! Int32 }
        set { setValue(newValue, forKey: "dns") }
    }
    public var enabledProtocols: Int32 {
        get { value(forKey: "enabledProtocols") as! Int32 }
        set { setValue(newValue, forKey: "enabledProtocols") }
    }
    public var ethEnabled: Bool {
        get { value(forKey: "ethEnabled") as! Bool }
        set { setValue(newValue, forKey: "ethEnabled") }
    }
    public var gateway: Int32 {
        get { value(forKey: "gateway") as! Int32 }
        set { setValue(newValue, forKey: "gateway") }
    }
    public var ip: Int32 {
        get { value(forKey: "ip") as! Int32 }
        set { setValue(newValue, forKey: "ip") }
    }
    public var ntpServer: String?? {
        get { value(forKey: "ntpServer") as? String? }
        set { setValue(newValue, forKey: "ntpServer") }
    }
    public var rsyslogServer: String?? {
        get { value(forKey: "rsyslogServer") as? String? }
        set { setValue(newValue, forKey: "rsyslogServer") }
    }
    public var subnet: Int32 {
        get { value(forKey: "subnet") as! Int32 }
        set { setValue(newValue, forKey: "subnet") }
    }
    public var wifiEnabled: Bool {
        get { value(forKey: "wifiEnabled") as! Bool }
        set { setValue(newValue, forKey: "wifiEnabled") }
    }
    public var wifiMode: Int32 {
        get { value(forKey: "wifiMode") as! Int32 }
        set { setValue(newValue, forKey: "wifiMode") }
    }
    public var wifiPsk: String?? {
        get { value(forKey: "wifiPsk") as? String? }
        set { setValue(newValue, forKey: "wifiPsk") }
    }
    public var wifiSsid: String?? {
        get { value(forKey: "wifiSsid") as? String? }
        set { setValue(newValue, forKey: "wifiSsid") }
    }
    public var networkConfigNode: NodeInfoEntity? {
        get { value(forKey: "networkConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "networkConfigNode") }
    }
}

extension NetworkConfigEntity: CoreDataEntity {
    public static var entityName: String { "NetworkConfigEntity" }
}
