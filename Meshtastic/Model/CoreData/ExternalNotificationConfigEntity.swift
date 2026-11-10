//
//  ExternalNotificationConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(ExternalNotificationConfigEntity)
public class ExternalNotificationConfigEntity: NSManagedObject {

}

extension ExternalNotificationConfigEntity {
    public var active: Bool {
        get { value(forKey: "active") as! Bool }
        set { setValue(newValue, forKey: "active") }
    }
    public var alertBell: Bool {
        get { value(forKey: "alertBell") as! Bool }
        set { setValue(newValue, forKey: "alertBell") }
    }
    public var alertBellBuzzer: Bool {
        get { value(forKey: "alertBellBuzzer") as! Bool }
        set { setValue(newValue, forKey: "alertBellBuzzer") }
    }
    public var alertBellVibra: Bool {
        get { value(forKey: "alertBellVibra") as! Bool }
        set { setValue(newValue, forKey: "alertBellVibra") }
    }
    public var alertMessage: Bool {
        get { value(forKey: "alertMessage") as! Bool }
        set { setValue(newValue, forKey: "alertMessage") }
    }
    public var alertMessageBuzzer: Bool {
        get { value(forKey: "alertMessageBuzzer") as! Bool }
        set { setValue(newValue, forKey: "alertMessageBuzzer") }
    }
    public var alertMessageVibra: Bool {
        get { value(forKey: "alertMessageVibra") as! Bool }
        set { setValue(newValue, forKey: "alertMessageVibra") }
    }
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var nagTimeout: Int32 {
        get { value(forKey: "nagTimeout") as! Int32 }
        set { setValue(newValue, forKey: "nagTimeout") }
    }
    public var output: Int32 {
        get { value(forKey: "output") as! Int32 }
        set { setValue(newValue, forKey: "output") }
    }
    public var outputBuzzer: Int32 {
        get { value(forKey: "outputBuzzer") as! Int32 }
        set { setValue(newValue, forKey: "outputBuzzer") }
    }
    public var outputMilliseconds: Int32 {
        get { value(forKey: "outputMilliseconds") as! Int32 }
        set { setValue(newValue, forKey: "outputMilliseconds") }
    }
    public var outputVibra: Int32 {
        get { value(forKey: "outputVibra") as! Int32 }
        set { setValue(newValue, forKey: "outputVibra") }
    }
    public var useI2SAsBuzzer: Bool {
        get { value(forKey: "useI2SAsBuzzer") as! Bool }
        set { setValue(newValue, forKey: "useI2SAsBuzzer") }
    }
    public var usePWM: Bool {
        get { value(forKey: "usePWM") as! Bool }
        set { setValue(newValue, forKey: "usePWM") }
    }
    public var externalNotificationConfigNode: NodeInfoEntity? {
        get { value(forKey: "externalNotificationConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "externalNotificationConfigNode") }
    }
}

extension ExternalNotificationConfigEntity: CoreDataEntity {
    public static var entityName: String { "ExternalNotificationConfigEntity" }
}
