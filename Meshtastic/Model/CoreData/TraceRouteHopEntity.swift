//
//  TraceRouteHopEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(TraceRouteHopEntity)
public class TraceRouteHopEntity: NSManagedObject {

}

extension TraceRouteHopEntity {
    public var hopIndex: Int32 {
        get { value(forKey: "hopIndex") as! Int32 }
        set { setValue(newValue, forKey: "hopIndex") }
    }
    public var nodeNum: Int64 {
        get { value(forKey: "nodeNum") as! Int64 }
        set { setValue(newValue, forKey: "nodeNum") }
    }
    public var snrTowards: Float {
        get { value(forKey: "snrTowards") as! Float }
        set { setValue(newValue, forKey: "snrTowards") }
    }
    public var snrBack: Float {
        get { value(forKey: "snrBack") as! Float }
        set { setValue(newValue, forKey: "snrBack") }
    }
    public var traceRoute: TraceRouteEntity? {
        get { value(forKey: "traceRoute") as? TraceRouteEntity }
        set { setValue(newValue, forKey: "traceRoute") }
    }
}

extension TraceRouteHopEntity: CoreDataEntity {
    public static var entityName: String { "TraceRouteHopEntity" }
}
