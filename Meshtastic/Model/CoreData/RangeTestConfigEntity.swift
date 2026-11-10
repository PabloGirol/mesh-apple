//
//  RangeTestConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(RangeTestConfigEntity)
public class RangeTestConfigEntity: NSManagedObject {

}

extension RangeTestConfigEntity {
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var save: Bool {
        get { value(forKey: "save") as! Bool }
        set { setValue(newValue, forKey: "save") }
    }
    public var sender: Int32 {
        get { value(forKey: "sender") as! Int32 }
        set { setValue(newValue, forKey: "sender") }
    }
    public var rangeTestConfigNode: NodeInfoEntity? {
        get { value(forKey: "rangeTestConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "rangeTestConfigNode") }
    }
}

extension RangeTestConfigEntity: CoreDataEntity {
    public static var entityName: String { "RangeTestConfigEntity" }
}
