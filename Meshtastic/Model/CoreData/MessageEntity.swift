//
//  MessageEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(MessageEntity)
public class MessageEntity: NSManagedObject {

}

extension MessageEntity {
    public var ackError: Int32 {
        get { value(forKey: "ackError") as! Int32 }
        set { setValue(newValue, forKey: "ackError") }
    }
    public var ackSNR: Float {
        get { value(forKey: "ackSNR") as! Float }
        set { setValue(newValue, forKey: "ackSNR") }
    }
    public var ackTimestamp: Int32 {
        get { value(forKey: "ackTimestamp") as! Int32 }
        set { setValue(newValue, forKey: "ackTimestamp") }
    }
    public var admin: Bool {
        get { value(forKey: "admin") as! Bool }
        set { setValue(newValue, forKey: "admin") }
    }
    public var adminDescription: String?? {
        get { value(forKey: "adminDescription") as? String? }
        set { setValue(newValue, forKey: "adminDescription") }
    }
    public var channel: Int32 {
        get { value(forKey: "channel") as! Int32 }
        set { setValue(newValue, forKey: "channel") }
    }
    public var isEmoji: Bool {
        get { value(forKey: "isEmoji") as! Bool }
        set { setValue(newValue, forKey: "isEmoji") }
    }
    public var messageId: Int64 {
        get { value(forKey: "messageId") as! Int64 }
        set { setValue(newValue, forKey: "messageId") }
    }
    public var messagePayload: String?? {
        get { value(forKey: "messagePayload") as? String? }
        set { setValue(newValue, forKey: "messagePayload") }
    }
    public var messageTimestamp: Int32 {
        get { value(forKey: "messageTimestamp") as! Int32 }
        set { setValue(newValue, forKey: "messageTimestamp") }
    }
    public var receivedACK: Bool {
        get { value(forKey: "receivedACK") as! Bool }
        set { setValue(newValue, forKey: "receivedACK") }
    }
    public var replyID: Int64 {
        get { value(forKey: "replyID") as! Int64 }
        set { setValue(newValue, forKey: "replyID") }
    }
    public var snr: Float {
        get { value(forKey: "snr") as! Float }
        set { setValue(newValue, forKey: "snr") }
    }
    public var fromUser: UserEntity? {
        get { value(forKey: "fromUser") as? UserEntity }
        set { setValue(newValue, forKey: "fromUser") }
    }
    public var toUser: UserEntity? {
        get { value(forKey: "toUser") as? UserEntity }
        set { setValue(newValue, forKey: "toUser") }
    }
}

extension MessageEntity: CoreDataEntity {
    public static var entityName: String { "MessageEntity" }
}
