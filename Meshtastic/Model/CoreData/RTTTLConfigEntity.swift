//
//  RTTTLConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(RTTTLConfigEntity)
public class RTTTLConfigEntity: NSManagedObject {

}

extension RTTTLConfigEntity {
    public var ringtone: String?? {
        get { value(forKey: "ringtone") as? String? }
        set { setValue(newValue, forKey: "ringtone") }
    }
    public var rtttlConfigNode: NodeInfoEntity? {
        get { value(forKey: "rtttlConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "rtttlConfigNode") }
    }
}

extension RTTTLConfigEntity: CoreDataEntity {
    public static var entityName: String { "RTTTLConfigEntity" }
}
