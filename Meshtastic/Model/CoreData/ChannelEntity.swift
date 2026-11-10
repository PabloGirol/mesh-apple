//
//  ChannelEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(ChannelEntity)
public class ChannelEntity: NSManagedObject {

}

extension ChannelEntity {
    public var downlinkEnabled: Bool {
        get { value(forKey: "downlinkEnabled") as! Bool }
        set { setValue(newValue, forKey: "downlinkEnabled") }
    }
    public var id: Int32 {
        get { value(forKey: "id") as! Int32 }
        set { setValue(newValue, forKey: "id") }
    }
    public var index: Int32 {
        get { value(forKey: "index") as! Int32 }
        set { setValue(newValue, forKey: "index") }
    }
    public var name: String?? {
        get { value(forKey: "name") as? String? }
        set { setValue(newValue, forKey: "name") }
    }
    public var psk: Data?? {
        get { value(forKey: "psk") as? Data? }
        set { setValue(newValue, forKey: "psk") }
    }
    public var role: Int32 {
        get { value(forKey: "role") as! Int32 }
        set { setValue(newValue, forKey: "role") }
    }
    public var uplinkEnabled: Bool {
        get { value(forKey: "uplinkEnabled") as! Bool }
        set { setValue(newValue, forKey: "uplinkEnabled") }
    }
    public var myInfoChannel: MyInfoEntity? {
        get { value(forKey: "myInfoChannel") as? MyInfoEntity }
        set { setValue(newValue, forKey: "myInfoChannel") }
    }
}

extension ChannelEntity: CoreDataEntity {
    public static var entityName: String { "ChannelEntity" }
}
