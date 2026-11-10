//
//  DetectionSensorConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DetectionSensorConfigEntity)
public class DetectionSensorConfigEntity: NSManagedObject {

}

extension DetectionSensorConfigEntity {
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var minimumBroadcastSecs: Int32 {
        get { value(forKey: "minimumBroadcastSecs") as! Int32 }
        set { setValue(newValue, forKey: "minimumBroadcastSecs") }
    }
    public var monitorPin: Int32 {
        get { value(forKey: "monitorPin") as! Int32 }
        set { setValue(newValue, forKey: "monitorPin") }
    }
    public var name: String?? {
        get { value(forKey: "name") as? String? }
        set { setValue(newValue, forKey: "name") }
    }
    public var sendBell: Bool {
        get { value(forKey: "sendBell") as! Bool }
        set { setValue(newValue, forKey: "sendBell") }
    }
    public var stateBroadcastSecs: Int32 {
        get { value(forKey: "stateBroadcastSecs") as! Int32 }
        set { setValue(newValue, forKey: "stateBroadcastSecs") }
    }
    public var triggerType: Int32 {
        get { value(forKey: "triggerType") as! Int32 }
        set { setValue(newValue, forKey: "triggerType") }
    }
    public var usePullup: Bool {
        get { value(forKey: "usePullup") as! Bool }
        set { setValue(newValue, forKey: "usePullup") }
    }
    public var detectionSensorConfigNode: NodeInfoEntity? {
        get { value(forKey: "detectionSensorConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "detectionSensorConfigNode") }
    }
}

extension DetectionSensorConfigEntity: CoreDataEntity {
    public static var entityName: String { "DetectionSensorConfigEntity" }
}
