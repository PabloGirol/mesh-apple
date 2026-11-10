//
//  AmbientLightingConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(AmbientLightingConfigEntity)
public class AmbientLightingConfigEntity: NSManagedObject {

}

extension AmbientLightingConfigEntity {
    public var blue: Int32 {
        get { value(forKey: "blue") as! Int32 }
        set { setValue(newValue, forKey: "blue") }
    }
    public var current: Int32 {
        get { value(forKey: "current") as! Int32 }
        set { setValue(newValue, forKey: "current") }
    }
    public var green: Int32 {
        get { value(forKey: "green") as! Int32 }
        set { setValue(newValue, forKey: "green") }
    }
    public var ledState: Bool {
        get { value(forKey: "ledState") as! Bool }
        set { setValue(newValue, forKey: "ledState") }
    }
    public var red: Int32 {
        get { value(forKey: "red") as! Int32 }
        set { setValue(newValue, forKey: "red") }
    }
    public var ambientLightingConfigNode: NodeInfoEntity? {
        get { value(forKey: "ambientLightingConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "ambientLightingConfigNode") }
    }
}

extension AmbientLightingConfigEntity: CoreDataEntity {
    public static var entityName: String { "AmbientLightingConfigEntity" }
}
