//
//  TraceRouteEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(TraceRouteEntity)
public class TraceRouteEntity: NSManagedObject {

}

extension TraceRouteEntity {
    public var id: UUID {
        get { value(forKey: "id") as! UUID }
        set { setValue(newValue, forKey: "id") }
    }
    public var targetNodeNum: Int64 {
        get { value(forKey: "targetNodeNum") as! Int64 }
        set { setValue(newValue, forKey: "targetNodeNum") }
    }
    public var startTime: Date {
        get { value(forKey: "startTime") as! Date }
        set { setValue(newValue, forKey: "startTime") }
    }
    public var completed: Bool {
        get { value(forKey: "completed") as! Bool }
        set { setValue(newValue, forKey: "completed") }
    }
    public var hops: NSSet? {
        get { value(forKey: "hops") as? NSSet }
        set { setValue(newValue, forKey: "hops") }
    }

    @objc(addHopsObject:)
    public func addToHops(_ value: TraceRouteHopEntity) {
        mutableSetValue(forKey: "hops").add(value)
    }

    @objc(removeHopsObject:)
    public func removeFromHops(_ value: TraceRouteHopEntity) {
        mutableSetValue(forKey: "hops").remove(value)
    }

    @objc(addHops:)
    public func addToHops(_ values: NSSet) {
        mutableSetValue(forKey: "hops").union(values)
    }

    @objc(removeHops:)
    public func removeFromHops(_ values: NSSet) {
        mutableSetValue(forKey: "hops").minus(values)
    }

}

extension TraceRouteEntity: CoreDataEntity {
    public static var entityName: String { "TraceRouteEntity" }
}
