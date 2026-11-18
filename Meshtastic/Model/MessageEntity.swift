//
//  MessageEntity.swift
//  Meshtastic
//
//  SwiftData model for messages.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(MessageEntity)
public class MessageEntity: NSManagedObject {

	@NSManaged public var ackError: Int32
	@NSManaged public var ackSNR: Float
	@NSManaged public var ackTimestamp: Int32
	@NSManaged public var admin: Bool
	@NSManaged public var adminDescription: String?
	@NSManaged public var channel: Int32
	@NSManaged public var isEmoji: Bool
	@NSManaged public var messageId: Int64
	@NSManaged public var messagePayload: String
	@NSManaged public var messagePayloadMarkdown: String?
	@NSManaged public var messagePayloadTranslated: String?
	@NSManaged public var messagePayloadTranslatedMarkdown: String?
	@NSManaged public var messageTimestamp: Int32
	@NSManaged public var pkiEncrypted: Bool
	@NSManaged public var portNum: Int32
	@NSManaged public var publicKey: Data?
	@NSManaged public var read: Bool
	@NSManaged public var realACK: Bool
	@NSManaged public var receivedACK: Bool
	@NSManaged public var relayNode: Int64
	@NSManaged public var relays: Int16
	@NSManaged public var replyID: Int64
	@NSManaged public var rssi: Int32
	@NSManaged public var showTranslatedMessage: Bool
	@NSManaged public var snr: Float
	@NSManaged public var xeddsaSigned: Bool

	@NSManaged public var fromUser: UserEntity?
	@NSManaged public var toUser: UserEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "MessageEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.ackError = 0
		self.ackSNR = 0.0
		self.ackTimestamp = 0
		self.admin = false
		self.adminDescription = nil
		self.channel = 0
		self.isEmoji = false
		self.messageId = 0
		self.messagePayload = ""
		self.messagePayloadMarkdown = nil
		self.messagePayloadTranslated = nil
		self.messagePayloadTranslatedMarkdown = nil
		self.messageTimestamp = 0
		self.pkiEncrypted = false
		self.portNum = 0
		self.publicKey = nil
		self.read = false
		self.realACK = false
		self.receivedACK = false
		self.relayNode = 0
		self.relays = 0
		self.replyID = 0
		self.rssi = 0
		self.showTranslatedMessage = false
		self.snr = 0.0
		self.xeddsaSigned = false
		self.fromUser = nil
		self.toUser = nil
	}
}

extension MessageEntity {
	/// Drops later occurrences of a repeated `messageId`, preserving order.
	///
	/// `messageId` is `@Attribute(.unique)`, but uniqueness is enforced per save:
	/// a sent message (main context) and its mesh echo (ingest actor) can coexist
	/// briefly before the constraint merges them. The message lists key their
	/// `ForEach` on `messageId`, and handing SwiftUI duplicate ids corrupts the
	/// List's collection-view batch update, which crashes. First occurrence wins —
	/// in the lists' chronological order that is the row the user already sees.
	static func deduplicatedByMessageId(_ messages: [MessageEntity]) -> [MessageEntity] {
		var seen = Set<Int64>()
		seen.reserveCapacity(messages.count)
		return messages.filter { seen.insert($0.messageId).inserted }
	}
}