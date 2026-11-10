//
//  TraceRouteNodePositionEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(TraceRouteNodePositionEntity)
public class TraceRouteNodePositionEntity: NSManagedObject {

}

extension TraceRouteNodePositionEntity {
    public var nodeNum: Int64 {
        get { value(forKey: "nodeNum") as! Int64 }
        set { setValue(newValue, forKey: "nodeNum") }
    }
    public var latitudeI: Int32 {
        get { value(forKey: "latitudeI") as! Int32 }
        set { setValue(newValue, forKey: "latitudeI") }
    }
    public var longitudeI: Int32 {
        get { value(forKey: "longitudeI") as! Int32 }
        set { setValue(newValue, forKey: "longitudeI") }
    }
}

extension TraceRouteNodePositionEntity: CoreDataEntity {
    public static var entityName: String { "TraceRouteNodePositionEntity" }
}
