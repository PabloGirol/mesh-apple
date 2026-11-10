//
//  LocationEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(LocationEntity)
public class LocationEntity: NSManagedObject {

}

extension LocationEntity {
    public var id: UUID {
        get { value(forKey: "id") as! UUID }
        set { setValue(newValue, forKey: "id") }
    }
    public var latitudeI: Int32 {
        get { value(forKey: "latitudeI") as! Int32 }
        set { setValue(newValue, forKey: "latitudeI") }
    }
    public var longitudeI: Int32 {
        get { value(forKey: "longitudeI") as! Int32 }
        set { setValue(newValue, forKey: "longitudeI") }
    }
    public var altitude: Int32 {
        get { value(forKey: "altitude") as! Int32 }
        set { setValue(newValue, forKey: "altitude") }
    }
    public var timestamp: Date {
        get { value(forKey: "timestamp") as! Date }
        set { setValue(newValue, forKey: "timestamp") }
    }
    public var sequence: Int32 {
        get { value(forKey: "sequence") as! Int32 }
        set { setValue(newValue, forKey: "sequence") }
    }
    public var route: RouteEntity? {
        get { value(forKey: "route") as? RouteEntity }
        set { setValue(newValue, forKey: "route") }
    }
}

extension LocationEntity: CoreDataEntity {
    public static var entityName: String { "LocationEntity" }
}
