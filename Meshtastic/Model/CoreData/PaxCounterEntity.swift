//
//  PaxCounterEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(PaxCounterEntity)
public class PaxCounterEntity: NSManagedObject {

}

extension PaxCounterEntity {
    public var time: Date {
        get { value(forKey: "time") as! Date }
        set { setValue(newValue, forKey: "time") }
    }
    public var count: Int32 {
        get { value(forKey: "count") as! Int32 }
        set { setValue(newValue, forKey: "count") }
    }
    public var snr: Float {
        get { value(forKey: "snr") as! Float }
        set { setValue(newValue, forKey: "snr") }
    }
}

extension PaxCounterEntity: CoreDataEntity {
    public static var entityName: String { "PaxCounterEntity" }
}
