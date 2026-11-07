//
//  MessageEntity.swift
//  Meshtastic
//
//  Core Data entity for MessageEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(MessageEntity)
public class MessageEntity: NSManagedObject {

}

extension MessageEntity {
    @NSManaged public var ackError: Int32
    @NSManaged public var ackSNR: Float
    @NSManaged public var ackTimestamp: Int32
    @NSManaged public var admin: Bool
    @NSManaged public var adminDescription: String??
    @NSManaged public var channel: Int32
    @NSManaged public var isEmoji: Bool
    @NSManaged public var messageId: Int64
    @NSManaged public var messagePayload: String??
    @NSManaged public var messageTimestamp: Int32
    @NSManaged public var receivedACK: Bool
    @NSManaged public var replyID: Int64
    @NSManaged public var snr: Float
    @NSManaged public var fromUser: UserEntity?
    @NSManaged public var toUser: UserEntity?
}

extension MessageEntity: CoreDataEntity {
    public static var entityName: String { "MessageEntity" }
}
