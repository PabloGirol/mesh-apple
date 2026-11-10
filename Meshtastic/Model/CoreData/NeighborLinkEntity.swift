//
//  NeighborLinkEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(NeighborLinkEntity)
public class NeighborLinkEntity: NSManagedObject {

}

extension NeighborLinkEntity {
    public var id: UUID {
        get { value(forKey: "id") as! UUID }
        set { setValue(newValue, forKey: "id") }
    }
    public var localNodeNum: Int64 {
        get { value(forKey: "localNodeNum") as! Int64 }
        set { setValue(newValue, forKey: "localNodeNum") }
    }
    public var neighborNodeNum: Int64 {
        get { value(forKey: "neighborNodeNum") as! Int64 }
        set { setValue(newValue, forKey: "neighborNodeNum") }
    }
    public var snr: Float {
        get { value(forKey: "snr") as! Float }
        set { setValue(newValue, forKey: "snr") }
    }
    public var channel: Int32 {
        get { value(forKey: "channel") as! Int32 }
        set { setValue(newValue, forKey: "channel") }
    }
    public var lastHeard: Date {
        get { value(forKey: "lastHeard") as! Date }
        set { setValue(newValue, forKey: "lastHeard") }
    }
}

extension NeighborLinkEntity: CoreDataEntity {
    public static var entityName: String { "NeighborLinkEntity" }
}
