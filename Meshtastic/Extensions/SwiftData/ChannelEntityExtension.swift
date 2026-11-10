//
//  ChannelEntityExtension.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 11/7/22.
//
import Foundation
import CoreData
import MeshtasticProtobufs

extension ChannelEntity {
	@MainActor
	var allPrivateMessages: [MessageEntity] {
		let context = CoreDataStackImpl.shared.context
		let channelIndex = self.index
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		request.predicate = NSPredicate(format: "channel == %d AND isEmoji == NO", channelIndex)
		request.sortDescriptors = [NSSortDescriptor(key: "messageTimestamp", ascending: true)]
		let messages = (try? context.fetch(request)) ?? []
		return messages.filter { $0.toUser == nil }
	}

	@MainActor
	var mostRecentPrivateMessage: MessageEntity? {
		let context = CoreDataStackImpl.shared.context
		let channelIndex = self.index
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		request.predicate = NSPredicate(format: "channel == %d AND isEmoji == NO", channelIndex)
		request.sortDescriptors = [NSSortDescriptor(key: "messageTimestamp", ascending: false)]
		request.fetchLimit = 10
		let batch = (try? context.fetch(request)) ?? []
		return batch.first { $0.toUser == nil }
	}

	@MainActor
	func unreadMessages(context: NSManagedObjectContext) -> Int {
		let channelIndex = self.index
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		request.predicate = NSPredicate(format: "channel == %d AND isEmoji == NO AND read == NO", channelIndex)
		let messages = (try? context.fetch(request)) ?? []
		return messages.filter { $0.toUser == nil }.count
	}

	@MainActor
	var unreadMessages: Int { unreadMessages(context: CoreDataStackImpl.shared.context) }

	var protoBuf: Channel {
		var channel = Channel()
		channel.index = self.index
		channel.settings.name = self.name ?? ""
		channel.settings.psk = self.psk ?? Data()
		channel.role = Channel.Role(rawValue: Int(self.role)) ?? Channel.Role.secondary
		channel.settings.moduleSettings.positionPrecision = UInt32(self.positionPrecision)
		channel.settings.moduleSettings.isMuted = self.mute
		return channel
	}

	/// Channel names reserved for module traffic (legacy remote admin, GPIO, serial, MQTT).
	/// Channels with these names carry module protocol data, so the Messages channel list
	/// hides them and the channel editor warns when one is entered.
	static let reservedModuleNames = ["admin", "gpio", "serial", "mqtt"]

	static func isReservedModuleName(_ name: String) -> Bool {
		reservedModuleNames.contains(name.lowercased())
	}
}
