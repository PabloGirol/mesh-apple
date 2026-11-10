//
//  MyInfoEntityExtension.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 9/3/23.
//

import Foundation
import CoreData

extension MyInfoEntity {
	@MainActor
	var messageList: [MessageEntity] {
		let context = CoreDataStackImpl.shared.context
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		request.predicate = NSPredicate(format: "isEmoji == NO")
		request.sortDescriptors = [NSSortDescriptor(key: "messageTimestamp", ascending: true)]
		let messages = (try? context.fetch(request)) ?? []
		return messages.filter { $0.toUser == nil }
	}

	@MainActor
	func unreadMessages(context: NSManagedObjectContext) -> Int {
		// NOTE: do NOT push `toUser == nil` into the predicate — comparing an optional
		// relationship to nil crashes. Fetch the unread set and split in Swift.
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		request.predicate = NSPredicate(format: "isEmoji == NO AND read == NO")
		let messages = (try? context.fetch(request)) ?? []
		return messages.filter { $0.toUser == nil }.count
	}

	@MainActor
	var unreadMessages: Int { unreadMessages(context: CoreDataStackImpl.shared.context) }

	var hasAdmin: Bool {
		let adminChannel = channels.filter { $0.name?.lowercased() == "admin" }
		return adminChannel.count > 0
	}
}
