//
//  TAKConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(TAKConfigEntity)
public class TAKConfigEntity: NSManagedObject {

}

extension TAKConfigEntity {
    public var role: Int32 {
        get { value(forKey: "role") as! Int32 }
        set { setValue(newValue, forKey: "role") }
    }
    public var team: Int32 {
        get { value(forKey: "team") as! Int32 }
        set { setValue(newValue, forKey: "team") }
    }
    public var takConfigNode: NodeInfoEntity? {
        get { value(forKey: "takConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "takConfigNode") }
    }
}

extension TAKConfigEntity: CoreDataEntity {
    public static var entityName: String { "TAKConfigEntity" }
}
