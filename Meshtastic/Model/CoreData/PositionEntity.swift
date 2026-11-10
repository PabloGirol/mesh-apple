//
//  PositionEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(PositionEntity)
public class PositionEntity: NSManagedObject {

}

extension PositionEntity {
    public var altitude: Int32 {
        get { value(forKey: "altitude") as! Int32 }
        set { setValue(newValue, forKey: "altitude") }
    }
    public var heading: Int32 {
        get { value(forKey: "heading") as! Int32 }
        set { setValue(newValue, forKey: "heading") }
    }
    public var latitudeI: Int32 {
        get { value(forKey: "latitudeI") as! Int32 }
        set { setValue(newValue, forKey: "latitudeI") }
    }
    public var longitudeI: Int32 {
        get { value(forKey: "longitudeI") as! Int32 }
        set { setValue(newValue, forKey: "longitudeI") }
    }
    public var satsInView: Int32 {
        get { value(forKey: "satsInView") as! Int32 }
        set { setValue(newValue, forKey: "satsInView") }
    }
    public var seqNo: Int32 {
        get { value(forKey: "seqNo") as! Int32 }
        set { setValue(newValue, forKey: "seqNo") }
    }
    public var snr: Float {
        get { value(forKey: "snr") as! Float }
        set { setValue(newValue, forKey: "snr") }
    }
    public var speed: Int32 {
        get { value(forKey: "speed") as! Int32 }
        set { setValue(newValue, forKey: "speed") }
    }
    public var time: Date?? {
        get { value(forKey: "time") as? Date? }
        set { setValue(newValue, forKey: "time") }
    }
    public var nodePosition: NodeInfoEntity? {
        get { value(forKey: "nodePosition") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "nodePosition") }
    }
}

extension PositionEntity: CoreDataEntity {
    public static var entityName: String { "PositionEntity" }
}
