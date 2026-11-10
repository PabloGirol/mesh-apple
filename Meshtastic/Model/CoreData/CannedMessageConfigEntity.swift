//
//  CannedMessageConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(CannedMessageConfigEntity)
public class CannedMessageConfigEntity: NSManagedObject {

}

extension CannedMessageConfigEntity {
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var inputbrokerEventCcw: Int32 {
        get { value(forKey: "inputbrokerEventCcw") as! Int32 }
        set { setValue(newValue, forKey: "inputbrokerEventCcw") }
    }
    public var inputbrokerEventCw: Int32 {
        get { value(forKey: "inputbrokerEventCw") as! Int32 }
        set { setValue(newValue, forKey: "inputbrokerEventCw") }
    }
    public var inputbrokerEventPress: Int32 {
        get { value(forKey: "inputbrokerEventPress") as! Int32 }
        set { setValue(newValue, forKey: "inputbrokerEventPress") }
    }
    public var inputbrokerPinA: Int32 {
        get { value(forKey: "inputbrokerPinA") as! Int32 }
        set { setValue(newValue, forKey: "inputbrokerPinA") }
    }
    public var inputbrokerPinB: Int32 {
        get { value(forKey: "inputbrokerPinB") as! Int32 }
        set { setValue(newValue, forKey: "inputbrokerPinB") }
    }
    public var inputbrokerPinPress: Int32 {
        get { value(forKey: "inputbrokerPinPress") as! Int32 }
        set { setValue(newValue, forKey: "inputbrokerPinPress") }
    }
    public var messages: String?? {
        get { value(forKey: "messages") as? String? }
        set { setValue(newValue, forKey: "messages") }
    }
    public var rotary1Enabled: Bool {
        get { value(forKey: "rotary1Enabled") as! Bool }
        set { setValue(newValue, forKey: "rotary1Enabled") }
    }
    public var sendBell: Bool {
        get { value(forKey: "sendBell") as! Bool }
        set { setValue(newValue, forKey: "sendBell") }
    }
    public var updown1Enabled: Bool {
        get { value(forKey: "updown1Enabled") as! Bool }
        set { setValue(newValue, forKey: "updown1Enabled") }
    }
    public var cannedMessagesConfigNode: NodeInfoEntity? {
        get { value(forKey: "cannedMessagesConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "cannedMessagesConfigNode") }
    }
}

extension CannedMessageConfigEntity: CoreDataEntity {
    public static var entityName: String { "CannedMessageConfigEntity" }
}
