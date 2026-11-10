//
//  MyInfoEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(MyInfoEntity)
public class MyInfoEntity: NSManagedObject {

}

extension MyInfoEntity {
    public var bleName: String?? {
        get { value(forKey: "bleName") as? String? }
        set { setValue(newValue, forKey: "bleName") }
    }
    public var minAppVersion: Int32 {
        get { value(forKey: "minAppVersion") as! Int32 }
        set { setValue(newValue, forKey: "minAppVersion") }
    }
    public var myNodeNum: Int64 {
        get { value(forKey: "myNodeNum") as! Int64 }
        set { setValue(newValue, forKey: "myNodeNum") }
    }
    public var peripheralId: String?? {
        get { value(forKey: "peripheralId") as? String? }
        set { setValue(newValue, forKey: "peripheralId") }
    }
    public var rebootCount: Int32 {
        get { value(forKey: "rebootCount") as! Int32 }
        set { setValue(newValue, forKey: "rebootCount") }
    }
    public var myInfoNode: NodeInfoEntity? {
        get { value(forKey: "myInfoNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "myInfoNode") }
    }
    public var channels: NSSet? {
        get { value(forKey: "channels") as? NSSet }
        set { setValue(newValue, forKey: "channels") }
    }

    @objc(addChannelsObject:)
    public func addToChannels(_ value: ChannelEntity) {
        mutableSetValue(forKey: "channels").add(value)
    }

    @objc(removeChannelsObject:)
    public func removeFromChannels(_ value: ChannelEntity) {
        mutableSetValue(forKey: "channels").remove(value)
    }

    @objc(addChannels:)
    public func addToChannels(_ values: NSSet) {
        mutableSetValue(forKey: "channels").union(values)
    }

    @objc(removeChannels:)
    public func removeFromChannels(_ values: NSSet) {
        mutableSetValue(forKey: "channels").minus(values)
    }

}

extension MyInfoEntity: CoreDataEntity {
    public static var entityName: String { "MyInfoEntity" }
}
