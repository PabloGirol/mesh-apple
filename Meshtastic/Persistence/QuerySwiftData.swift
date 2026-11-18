//
//  QuerySwiftData.swift
//  Meshtastic
//
//  Created(c) Garth Vander Houwen 1/16/23.
//

import Foundation
import CoreData

func getNodeInfo(id: Int64, context: NSManagedObjectContext) -> NodeInfoEntity? {
    let request = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
    request.predicate = NSPredicate(format: "num == %@", NSNumber(value: id))
    request.fetchLimit = 1
    return try? context.fetch(request).first
}

func getStoreAndForwardMessageIds(seconds: Int, context: NSManagedObjectContext) -> [UInt32] {
    let time = seconds * -1
    let timeRange = Calendar.current.date(byAdding: .minute, value: time, to: Date())
    let milliseconds = Int32(timeRange?.timeIntervalSince1970 ?? 0)
    let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    request.predicate = NSPredicate(format: "messageTimestamp >= %@", NSNumber(value: milliseconds))
    let fetchedMessages = (try? context.fetch(request)) ?? []
    return fetchedMessages.map { UInt32($0.messageId) }
}

func getTraceRoute(id: Int64, context: NSManagedObjectContext) -> TraceRouteEntity? {
    let request = NSFetchRequest<TraceRouteEntity>(entityName: "TraceRouteEntity")
    request.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
    request.fetchLimit = 1
    return try? context.fetch(request).first
}

func getUser(id: Int64, context: NSManagedObjectContext) -> UserEntity {
    let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
    request.predicate = NSPredicate(format: "num == %@", NSNumber(value: id))
    request.fetchLimit = 1
    if let existing = try? context.fetch(request).first {
        return existing
    }
    let newUser = UserEntity(context: context)
    newUser.num = id
    return newUser
}

func getWaypoint(id: Int64, context: NSManagedObjectContext) -> WaypointEntity {
    let request = NSFetchRequest<WaypointEntity>(entityName: "WaypointEntity")
    request.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
    request.fetchLimit = 1
    if let existing = try? context.fetch(request).first {
        return existing
    }
    let newWaypoint = WaypointEntity(context: context)
    newWaypoint.id = id
    return newWaypoint
}