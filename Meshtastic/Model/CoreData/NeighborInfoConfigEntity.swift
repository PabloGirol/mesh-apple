//
//  NeighborInfoConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(NeighborInfoConfigEntity)
public class NeighborInfoConfigEntity: NSManagedObject {

}

extension NeighborInfoConfigEntity {
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var transmitOverLora: Bool {
        get { value(forKey: "transmitOverLora") as! Bool }
        set { setValue(newValue, forKey: "transmitOverLora") }
    }
    public var updateInterval: Int32 {
        get { value(forKey: "updateInterval") as! Int32 }
        set { setValue(newValue, forKey: "updateInterval") }
    }
    public var neighborInfoConfigNode: NodeInfoEntity? {
        get { value(forKey: "neighborInfoConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "neighborInfoConfigNode") }
    }
}

extension NeighborInfoConfigEntity: CoreDataEntity {
    public static var entityName: String { "NeighborInfoConfigEntity" }
}
