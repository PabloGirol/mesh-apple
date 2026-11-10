//
//  DeviceConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DeviceConfigEntity)
public class DeviceConfigEntity: NSManagedObject {

}

extension DeviceConfigEntity {
    public var buttonGpio: Int32 {
        get { value(forKey: "buttonGpio") as! Int32 }
        set { setValue(newValue, forKey: "buttonGpio") }
    }
    public var buzzerGpio: Int32 {
        get { value(forKey: "buzzerGpio") as! Int32 }
        set { setValue(newValue, forKey: "buzzerGpio") }
    }
    public var debugLogEnabled: Bool {
        get { value(forKey: "debugLogEnabled") as! Bool }
        set { setValue(newValue, forKey: "debugLogEnabled") }
    }
    public var disableTripleClick: Bool {
        get { value(forKey: "disableTripleClick") as! Bool }
        set { setValue(newValue, forKey: "disableTripleClick") }
    }
    public var doubleTapAsButtonPress: Bool {
        get { value(forKey: "doubleTapAsButtonPress") as! Bool }
        set { setValue(newValue, forKey: "doubleTapAsButtonPress") }
    }
    public var isManaged: Bool {
        get { value(forKey: "isManaged") as! Bool }
        set { setValue(newValue, forKey: "isManaged") }
    }
    public var ledHeartbeatEnabled: Bool {
        get { value(forKey: "ledHeartbeatEnabled") as! Bool }
        set { setValue(newValue, forKey: "ledHeartbeatEnabled") }
    }
    public var nodeInfoBroadcastSecs: Int32 {
        get { value(forKey: "nodeInfoBroadcastSecs") as! Int32 }
        set { setValue(newValue, forKey: "nodeInfoBroadcastSecs") }
    }
    public var rebroadcastMode: Int32 {
        get { value(forKey: "rebroadcastMode") as! Int32 }
        set { setValue(newValue, forKey: "rebroadcastMode") }
    }
    public var role: Int32 {
        get { value(forKey: "role") as! Int32 }
        set { setValue(newValue, forKey: "role") }
    }
    public var serialEnabled: Bool {
        get { value(forKey: "serialEnabled") as! Bool }
        set { setValue(newValue, forKey: "serialEnabled") }
    }
    public var tripleClickAsAdHocPing: Bool {
        get { value(forKey: "tripleClickAsAdHocPing") as! Bool }
        set { setValue(newValue, forKey: "tripleClickAsAdHocPing") }
    }
    public var tzdef: String?? {
        get { value(forKey: "tzdef") as? String? }
        set { setValue(newValue, forKey: "tzdef") }
    }
    public var deviceConfigNode: NodeInfoEntity? {
        get { value(forKey: "deviceConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "deviceConfigNode") }
    }
}

extension DeviceConfigEntity: CoreDataEntity {
    public static var entityName: String { "DeviceConfigEntity" }
}
