//
//  UserEntity.swift
//  Meshtastic
//
//  Core Data entity for UserEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(UserEntity)
public class UserEntity: NSManagedObject {

}

extension UserEntity {
    @NSManaged public var hwModel: String??
    @NSManaged public var isLicensed: Bool
    @NSManaged public var longName: String??
    @NSManaged public var num: Int64
    @NSManaged public var shortName: String??
    @NSManaged public var userId: String??
    @NSManaged public var userNode: NodeInfoEntity?
    @NSManaged public var messagesFrom: NSSet
    @NSManaged public var messagesTo: NSSet

    @objc(addMessagesfromObject:)
    @NSManaged public func addToMessagesfrom(_ value: MessageEntity)

    @objc(removeMessagesfromObject:)
    @NSManaged public func removeFromMessagesfrom(_ value: MessageEntity)

    @objc(addMessagesfrom:)
    @NSManaged public func addToMessagesfrom(_ values: NSSet)

    @objc(removeMessagesfrom:)
    @NSManaged public func removeFromMessagesfrom(_ values: NSSet)


    @objc(addMessagestoObject:)
    @NSManaged public func addToMessagesto(_ value: MessageEntity)

    @objc(removeMessagestoObject:)
    @NSManaged public func removeFromMessagesto(_ value: MessageEntity)

    @objc(addMessagesto:)
    @NSManaged public func addToMessagesto(_ values: NSSet)

    @objc(removeMessagesto:)
    @NSManaged public func removeFromMessagesto(_ values: NSSet)

}

extension UserEntity: CoreDataEntity {
    public static var entityName: String { "UserEntity" }
}
