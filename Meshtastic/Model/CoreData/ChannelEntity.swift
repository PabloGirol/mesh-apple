//
//  ChannelEntity.swift
//  Meshtastic
//
//  Core Data entity for ChannelEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(ChannelEntity)
public class ChannelEntity: NSManagedObject {

}

extension ChannelEntity {
    @NSManaged public var downlinkEnabled: Bool
    @NSManaged public var id: Int32
    @NSManaged public var index: Int32
    @NSManaged public var name: String??
    @NSManaged public var psk: Data??
    @NSManaged public var role: Int32
    @NSManaged public var uplinkEnabled: Bool
    @NSManaged public var myInfoChannel: MyInfoEntity?
}

extension ChannelEntity: CoreDataEntity {
    public static var entityName: String { "ChannelEntity" }
}
