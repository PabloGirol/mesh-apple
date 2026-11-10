//
//  WaypointEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(WaypointEntity)
public class WaypointEntity: NSManagedObject {

}

extension WaypointEntity {
    public var id: UUID {
        get { value(forKey: "id") as! UUID }
        set { setValue(newValue, forKey: "id") }
    }
    public var name: String {
        get { value(forKey: "name") as! String }
        set { setValue(newValue, forKey: "name") }
    }
    public var descriptionText: String?? {
        get { value(forKey: "descriptionText") as? String? }
        set { setValue(newValue, forKey: "descriptionText") }
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
    public var createdAt: Date {
        get { value(forKey: "createdAt") as! Date }
        set { setValue(newValue, forKey: "createdAt") }
    }
    public var updatedAt: Date {
        get { value(forKey: "updatedAt") as! Date }
        set { setValue(newValue, forKey: "updatedAt") }
    }
    public var isShared: Bool {
        get { value(forKey: "isShared") as! Bool }
        set { setValue(newValue, forKey: "isShared") }
    }
}

extension WaypointEntity: CoreDataEntity {
    public static var entityName: String { "WaypointEntity" }
}
