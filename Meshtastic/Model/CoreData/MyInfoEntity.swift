//
//  MyInfoEntity.swift
//  Meshtastic
//
//  Core Data entity for MyInfoEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(MyInfoEntity)
public class MyInfoEntity: NSManagedObject {

}

extension MyInfoEntity {
    @NSManaged public var bleName: String??
    @NSManaged public var minAppVersion: Int32
    @NSManaged public var myNodeNum: Int64
    @NSManaged public var peripheralId: String??
    @NSManaged public var rebootCount: Int32
    @NSManaged public var myInfoNode: NodeInfoEntity?
    @NSManaged public var channels: NSSet

    @objc(addChannelsObject:)
    @NSManaged public func addToChannels(_ value: ChannelEntity)

    @objc(removeChannelsObject:)
    @NSManaged public func removeFromChannels(_ value: ChannelEntity)

    @objc(addChannels:)
    @NSManaged public func addToChannels(_ values: NSSet)

    @objc(removeChannels:)
    @NSManaged public func removeFromChannels(_ values: NSSet)

}

extension MyInfoEntity: CoreDataEntity {
    public static var entityName: String { "MyInfoEntity" }
}
