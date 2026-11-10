//
//  UserEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(UserEntity)
public class UserEntity: NSManagedObject {

}

extension UserEntity {
    public var hwModel: String?? {
        get { value(forKey: "hwModel") as? String? }
        set { setValue(newValue, forKey: "hwModel") }
    }
    public var isLicensed: Bool {
        get { value(forKey: "isLicensed") as! Bool }
        set { setValue(newValue, forKey: "isLicensed") }
    }
    public var longName: String?? {
        get { value(forKey: "longName") as? String? }
        set { setValue(newValue, forKey: "longName") }
    }
    public var num: Int64 {
        get { value(forKey: "num") as! Int64 }
        set { setValue(newValue, forKey: "num") }
    }
    public var shortName: String?? {
        get { value(forKey: "shortName") as? String? }
        set { setValue(newValue, forKey: "shortName") }
    }
    public var userId: String?? {
        get { value(forKey: "userId") as? String? }
        set { setValue(newValue, forKey: "userId") }
    }
    public var userNode: NodeInfoEntity? {
        get { value(forKey: "userNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "userNode") }
    }
    public var messagesFrom: NSSet? {
        get { value(forKey: "messagesFrom") as? NSSet }
        set { setValue(newValue, forKey: "messagesFrom") }
    }
    public var messagesTo: NSSet? {
        get { value(forKey: "messagesTo") as? NSSet }
        set { setValue(newValue, forKey: "messagesTo") }
    }

    @objc(addMessagesFromObject:)
    public func addToMessagesFrom(_ value: MessageEntity) {
        mutableSetValue(forKey: "messagesFrom").add(value)
    }

    @objc(removeMessagesFromObject:)
    public func removeFromMessagesFrom(_ value: MessageEntity) {
        mutableSetValue(forKey: "messagesFrom").remove(value)
    }

    @objc(addMessagesFrom:)
    public func addToMessagesFrom(_ values: NSSet) {
        mutableSetValue(forKey: "messagesFrom").union(values)
    }

    @objc(removeMessagesFrom:)
    public func removeFromMessagesFrom(_ values: NSSet) {
        mutableSetValue(forKey: "messagesFrom").minus(values)
    }


    @objc(addMessagesToObject:)
    public func addToMessagesTo(_ value: MessageEntity) {
        mutableSetValue(forKey: "messagesTo").add(value)
    }

    @objc(removeMessagesToObject:)
    public func removeFromMessagesTo(_ value: MessageEntity) {
        mutableSetValue(forKey: "messagesTo").remove(value)
    }

    @objc(addMessagesTo:)
    public func addToMessagesTo(_ values: NSSet) {
        mutableSetValue(forKey: "messagesTo").union(values)
    }

    @objc(removeMessagesTo:)
    public func removeFromMessagesTo(_ values: NSSet) {
        mutableSetValue(forKey: "messagesTo").minus(values)
    }

}

extension UserEntity: CoreDataEntity {
    public static var entityName: String { "UserEntity" }
}
