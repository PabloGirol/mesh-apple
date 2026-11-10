//
//  RouteEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(RouteEntity)
public class RouteEntity: NSManagedObject {

}

extension RouteEntity {
    public var id: UUID {
        get { value(forKey: "id") as! UUID }
        set { setValue(newValue, forKey: "id") }
    }
    public var name: String {
        get { value(forKey: "name") as! String }
        set { setValue(newValue, forKey: "name") }
    }
    public var createdAt: Date {
        get { value(forKey: "createdAt") as! Date }
        set { setValue(newValue, forKey: "createdAt") }
    }
    public var updatedAt: Date {
        get { value(forKey: "updatedAt") as! Date }
        set { setValue(newValue, forKey: "updatedAt") }
    }
    public var locations: NSSet? {
        get { value(forKey: "locations") as? NSSet }
        set { setValue(newValue, forKey: "locations") }
    }

    @objc(addLocationsObject:)
    public func addToLocations(_ value: LocationEntity) {
        mutableSetValue(forKey: "locations").add(value)
    }

    @objc(removeLocationsObject:)
    public func removeFromLocations(_ value: LocationEntity) {
        mutableSetValue(forKey: "locations").remove(value)
    }

    @objc(addLocations:)
    public func addToLocations(_ values: NSSet) {
        mutableSetValue(forKey: "locations").union(values)
    }

    @objc(removeLocations:)
    public func removeFromLocations(_ values: NSSet) {
        mutableSetValue(forKey: "locations").minus(values)
    }

}

extension RouteEntity: CoreDataEntity {
    public static var entityName: String { "RouteEntity" }
}
