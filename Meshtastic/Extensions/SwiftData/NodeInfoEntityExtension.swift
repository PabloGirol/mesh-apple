//
//  NodeInfoEntityExtension.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 9/3/23.
//

import Foundation
import CoreData

extension NodeInfoEntity {

	/// Returns this node's user only while both sides of the relationship are still backed by
	/// Core Data. A node detail view can outlive `clearDatabase`, which removes users before it
	/// removes nodes; reading a persisted property from that deleted user traps in Core Data.
	var liveUser: UserEntity? {
		guard managedObjectContext != nil, !isDeleted,
			let user,
			user.managedObjectContext != nil, !user.isDeleted
		else { return nil }
		return user
	}

	// MARK: - Targeted Fetch Helpers
	// These use NSFetchRequest with fetchLimit to avoid loading entire relationship arrays.

	var latestPosition: PositionEntity? {
		guard let ctx = managedObjectContext else { return nil }
		// The ingest layer keeps the cache pointed at the latest row, but the handle it hands back
		// can't be trusted on its own. A context only learns about deletes made through itself, so
		// a row the ingest actor deleted and saved still reports `managedObjectContext != nil` and
		// `isDeleted == false` here, and the first persisted-property read on it traps (the node
		// list's top crash). Confirm the row through the store instead: reading objectID
		// on the stale handle is safe, and a fetch loads the row's values, so what it returns can
		// be read even if the row is deleted afterwards.
		if let cached = latestPositionCache {
			let cachedID = cached.objectID
			if cachedID.isTemporaryID {
				// A temporary id is this context's own unsaved insert (the ingest actor reads it
				// between debounced saves). No other context can have deleted it, and a fetch by a
				// temporary id is not valid on every OS, so hand it back without the store lookup.
				if cached.managedObjectContext != nil, !cached.isDeleted {
					return cached
				}
			} else {
				let byID = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
				byID.predicate = NSPredicate(format: "self == %@", cachedID)
				byID.fetchLimit = 1
				if let row = try? ctx.fetch(byID).first {
					return row
				}
			}
		}
		// No cache (migrated / restored / seeded data) or the cached row is gone: a sorted limit-1
		// query. The next position packet warms the cache again.
		let nodeNum = self.num
		let descriptor = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
		descriptor.predicate = NSPredicate(format: "nodePosition.num == %lld", nodeNum)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 1
		return try? ctx.fetch(descriptor).first
	}

	/// `latestPosition` for many nodes at once, keyed by each node's objectID: one fetch
	/// confirms every cached position through the store, and one more covers the nodes with no
	/// cache, instead of a query or two per node. Same rules as `latestPosition`: a cached row is
	/// confirmed through the store (a fetch loads its values, so another context's delete can't
	/// trap a later read), and a context's own unsaved insert is taken as is.
	static func latestPositions(for nodes: [NodeInfoEntity], context: NSManagedObjectContext) -> [NSManagedObjectID: PositionEntity] {
		var result: [NSManagedObjectID: PositionEntity] = [:]
		var nodeForCachedID: [NSManagedObjectID: NSManagedObjectID] = [:]
		var uncachedNodeNums: [Int64: NSManagedObjectID] = [:]
		var numForNode: [NSManagedObjectID: Int64] = [:]
		for node in nodes {
			numForNode[node.objectID] = node.num
			guard let cached = node.latestPositionCache else {
				uncachedNodeNums[node.num] = node.objectID
				continue
			}
			let cachedID = cached.objectID
			if cachedID.isTemporaryID {
				if cached.managedObjectContext != nil, !cached.isDeleted { result[node.objectID] = cached }
			} else {
				nodeForCachedID[cachedID] = node.objectID
			}
		}
		if !nodeForCachedID.isEmpty {
			let cachedIDs = Array(nodeForCachedID.keys)
			let byID = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
			byID.predicate = NSPredicate(format: "self IN %@", cachedIDs)
			var found = Set<NSManagedObjectID>()
			for row in (try? context.fetch(byID)) ?? [] {
				guard let nodeID = nodeForCachedID[row.objectID] else { continue }
				result[nodeID] = row
				found.insert(row.objectID)
			}
			// A cached row that's gone falls back like a node with no cache.
			for (cachedID, nodeID) in nodeForCachedID where !found.contains(cachedID) {
				if let num = numForNode[nodeID] { uncachedNodeNums[num] = nodeID }
			}
		}
		if !uncachedNodeNums.isEmpty {
			// Each of those nodes' newest position by time, as latestPosition's own fallback picks,
			// in one fetch scoped to them.
			let nums = Array(uncachedNodeNums.keys)
			let newest = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
			newest.predicate = NSPredicate(format: "nodePosition.num IN %@", nums)
			newest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
			newest.relationshipKeyPathsForPrefetching = ["nodePosition"]
			for row in (try? context.fetch(newest)) ?? [] {
				guard let num = row.nodePosition?.num, let nodeID = uncachedNodeNums[num], result[nodeID] == nil else { continue }
				result[nodeID] = row
			}
		}
		return result
	}

	func positionCount(context: NSManagedObjectContext? = nil) -> Int {
		guard let ctx = context ?? managedObjectContext else { return 0 }
		let nodeNum = self.num
		let descriptor = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
		descriptor.predicate = NSPredicate(format: "nodePosition.num == %lld", nodeNum)
		return (try? ctx.count(for: descriptor)) ?? 0
	}

	func positionsSortedByTime(context: NSManagedObjectContext? = nil, ascending: Bool = false, limit: Int? = nil) -> [PositionEntity] {
		guard let ctx = context ?? managedObjectContext else { return [] }
		let nodeNum = self.num
		var descriptor = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
		descriptor.predicate = NSPredicate(format: "nodePosition.num == %lld", nodeNum)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: ascending)]
		if let limit {
			descriptor.fetchLimit = limit
		}
		return (try? ctx.fetch(descriptor)) ?? []
	}

	func telemetryCount(ofType metricsType: Int32, context: NSManagedObjectContext? = nil) -> Int {
		guard let ctx = context ?? managedObjectContext else { return 0 }
		let nodeNum = self.num
		let descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		return (try? ctx.count(for: descriptor)) ?? 0
	}

	func paxCount(context: NSManagedObjectContext? = nil) -> Int {
		guard let ctx = context ?? managedObjectContext else { return 0 }
		let nodeNum = self.num
		let descriptor = NSFetchRequest<PaxCounterEntity>(entityName: "PaxCounterEntity")
		descriptor.predicate = NSPredicate(format: "paxNode.num == %lld", nodeNum)
		return (try? ctx.count(for: descriptor)) ?? 0
	}

	func paxCountersSortedByTime(context: NSManagedObjectContext? = nil, ascending: Bool = false, limit: Int? = nil) -> [PaxCounterEntity] {
		guard let ctx = context ?? managedObjectContext else { return [] }
		let nodeNum = self.num
		var descriptor = NSFetchRequest<PaxCounterEntity>(entityName: "PaxCounterEntity")
		descriptor.predicate = NSPredicate(format: "paxNode.num == %lld", nodeNum)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: ascending)]
		if let limit {
			descriptor.fetchLimit = limit
		}
		return (try? ctx.fetch(descriptor)) ?? []
	}

	var latestDeviceMetrics: TelemetryEntity? {
		guard let ctx = managedObjectContext else { return nil }
		let nodeNum = self.num
		let metricsType: Int32 = 0
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 1
		return try? ctx.fetch(descriptor).first
	}

	var latestEnvironmentMetrics: TelemetryEntity? {
		guard let ctx = managedObjectContext else { return nil }
		let nodeNum = self.num
		let metricsType: Int32 = 1
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 1
		return try? ctx.fetch(descriptor).first
	}

	var latestAirQualityMetrics: TelemetryEntity? {
		guard let ctx = managedObjectContext else { return nil }
		let nodeNum = self.num
		let metricsType: Int32 = 3
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 1
		return try? ctx.fetch(descriptor).first
	}

	var hasAirQualityMetrics: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		let metricsType: Int32 = 3
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	var latestPowerMetrics: TelemetryEntity? {
		guard let ctx = managedObjectContext else { return nil }
		let nodeNum = self.num
		let metricsType: Int32 = 2
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 1
		return try? ctx.fetch(descriptor).first
	}

	var hasPositions: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		var descriptor = NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
		descriptor.predicate = NSPredicate(format: "nodePosition.num == %lld", nodeNum)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	var hasDeviceMetrics: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		let metricsType: Int32 = 0
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	var hasEnvironmentMetrics: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		let metricsType: Int32 = 1
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	func hasDataForLatestEnvironmentMetrics(attributes: [String]) -> Bool {
		guard let latest = self.latestEnvironmentMetrics else { return false }
		for attribute in attributes {
			let mirror = Mirror(reflecting: latest)
			if let child = mirror.children.first(where: { $0.label == attribute }) {
				if child.value is Any? {
					let m = Mirror(reflecting: child.value)
					if m.displayStyle == .optional && m.children.count > 0 {
						return true
					}
				} else {
					return true
				}
			}
		}
		return false
	}

	@MainActor
	var hasDetectionSensorMetrics: Bool {
		guard let ctx = managedObjectContext, let userNum = user?.num else { return false }
		let portNum: Int32 = 10
		var descriptor = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		descriptor.predicate = NSPredicate(format: "fromUser.num == %lld AND portNum == %d", userNum, portNum)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	var hasPowerMetrics: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		let metricsType: Int32 = 2
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	var latestLocalStats: TelemetryEntity? {
		guard let ctx = managedObjectContext else { return nil }
		let nodeNum = self.num
		let metricsType: Int32 = 4
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 1
		return try? ctx.fetch(descriptor).first
	}

	/// The receiving radio's most recent noise floor (dBm) from Local Stats telemetry
	/// (`DeviceMetrics.noise_floor`), or nil when it's absent, zero, or older than the
	/// online threshold (2 h). Used to compute a real link margin (`rssi - noiseFloor`)
	/// for signal-quality rating instead of guessed fixed RSSI thresholds.
	var recentNoiseFloor: Int32? {
		guard let stats = latestLocalStats,
			  let time = stats.time,
			  let noiseFloor = stats.noiseFloor,
			  noiseFloor != 0,
			  let twoHoursAgo = Calendar.current.date(byAdding: .minute, value: -120, to: Date()),
			  time.compare(twoHoursAgo) == .orderedDescending
		else { return nil }
		return noiseFloor
	}

	var hasLocalStats: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		let metricsType: Int32 = 4
		let descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		return (try? ctx.count(for: descriptor)) ?? 0 > 0
	}

	var hasTraceRoutes: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		var descriptor = NSFetchRequest<TraceRouteEntity>(entityName: "TraceRouteEntity")
		descriptor.predicate = NSPredicate(format: "node.num == %lld", nodeNum)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	var hasPax: Bool {
		guard let ctx = managedObjectContext else { return false }
		let nodeNum = self.num
		var descriptor = NSFetchRequest<PaxCounterEntity>(entityName: "PaxCounterEntity")
		descriptor.predicate = NSPredicate(format: "paxNode.num == %lld", nodeNum)
		descriptor.fetchLimit = 1
		return ((try? ctx.fetch(descriptor)) ?? []).isEmpty == false
	}

	var isStoreForwardRouter: Bool {
		return storeForwardConfig?.isRouter ?? false
	}

	/// Safely fetches telemetries of a given type using NSFetchRequest.
	/// This avoids crashes when relationship arrays contain references to deleted entities.
	func safeTelemetries(ofType metricsType: Int32) -> [TelemetryEntity] {
		guard let ctx = managedObjectContext else { return [] }
		let nodeNum = self.num
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 500
		return (try? ctx.fetch(descriptor)) ?? []
	}

	/// Safely fetches trace routes using NSFetchRequest.
	/// This avoids stale relationship arrays after reconnects or restore/import flows.
	func safeTraceRoutes() -> [TraceRouteEntity] {
		guard let ctx = managedObjectContext else { return [] }
		let nodeNum = self.num
		var descriptor = NSFetchRequest<TraceRouteEntity>(entityName: "TraceRouteEntity")
		descriptor.predicate = NSPredicate(format: "node.num == %lld", nodeNum)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 500
		return (try? ctx.fetch(descriptor)) ?? []
	}

	/// The radio has not heard this node on its current LoRa settings. MQTT nodes are left out: they
	/// never reach the radio over RF, so the radio can never report them heard.
	var isUnheardOnCurrentLora: Bool {
		heardOnCurrentLora == false && !viaMqtt
	}

	var isOnline: Bool {
		let twoHoursAgo = Calendar.current.date(byAdding: .minute, value: -120, to: Date())
		if lastHeard?.compare(twoHoursAgo!) == .orderedDescending {
			 return true
		}
		return false
	}

	/// Remote admin is PKI only; the legacy admin channel is not supported.
	var canRemoteAdmin: Bool {
		UserDefaults.enableAdministration
	}
}

func createNodeInfo(num: Int64, context: NSManagedObjectContext) -> NodeInfoEntity {

	let newNode = NodeInfoEntity(context: context)
	newNode.id = Int64(num)
	newNode.num = Int64(num)
	// Reuse an existing/pending user for this `num` rather than inserting a second one — see
	// `findOrCreateUser`. Inserting a fresh `UserEntity` whose unique `num` collides with a row
	// that already exists (saved or pending) is what trapped here (NodeInfoEntityExtension.swift /
	// UpdateSwiftData.swift SwiftData `_assertionFailure`). Routing user creation through this helper guarantees one user per `num`.
	newNode.user = findOrCreateUser(num: num, context: context)
	return newNode
}

/// Returns the `UserEntity` for `num`, creating and inserting a stub only when none exists yet.
///
/// `UserEntity.num` is unique and carries the same caveat as `NodeInfoEntity` (see
/// `findOrCreateNode`): Core Data resolves unique collisions against the **saved** store only, not
/// against un-saved inserts pending in the same context. `createNodeInfo` previously inserted a
/// fresh `UserEntity` unconditionally, so whenever a user row for `num` already existed — orphaned,
/// or pending from another packet — while the matching `NodeInfoEntity` did not, that second unique
/// insert trapped with a Core Data assertion. Routing user creation through this helper guarantees one user per `num`.
/// An existing user keeps its real fields; only a brand-new stub gets the "Meshtastic XXXX" default.
func findOrCreateUser(num: Int64, context: NSManagedObjectContext) -> UserEntity {
	let descriptor = NSFetchRequest<UserEntity>(entityName: "UserEntity")
	descriptor.predicate = NSPredicate(format: "num == %lld", num)
	descriptor.fetchLimit = 1
	if let existing = (try? context.fetch(descriptor))?.first {
		return existing
	}
	// A fetch also returns this context's unsaved inserts, so the pending scan below is a backstop, not the usual path.
	if let pending = context.insertedObjects.lazy
		.compactMap({ $0 as? UserEntity })
		.first(where: { $0.num == num }) {
		return pending
	}
	let newUser = UserEntity(context: context)
	newUser.num = Int64(num)
	// toHex() already prefixes "!", so interpolating another one produced "!!deadbeef"
	// for any node heard before its NodeInfo arrived — visible in message rows, used for
	// search matching, and exported as `userProto.id` onto the mesh.
	let userId = num.toHex()
	newUser.userId = userId
	let last4 = String(userId.suffix(4))
	newUser.longName = "Meshtastic \(last4)"
	newUser.shortName = last4
	newUser.hwModel = "UNSET"
	return newUser
}

/// Returns the `NodeInfoEntity` for `num`, creating and inserting a stub only when none exists yet.
///
/// `NodeInfoEntity.num` is unique, but the constraint is only enforced at save: two
/// pending inserts with the same `num` (a POSITION packet creating a stub before the matching
/// NodeInfo packet arrives, or two packets for a new node back-to-back before a save) trap there
/// with a Core Data assertion. Routing every node creation through this helper guarantees
/// exactly one node per `num`: the fetch finds pending inserts, and the
/// `insertedObjects` scan is the backstop.
func findOrCreateNode(num: Int64, context: NSManagedObjectContext) -> NodeInfoEntity {
	let descriptor = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
	descriptor.predicate = NSPredicate(format: "num == %lld", num)
	descriptor.fetchLimit = 1
	if let existing = (try? context.fetch(descriptor))?.first {
		return existing
	}
	// A fetch also returns this context's unsaved inserts, so the pending scan below is a backstop, not the usual path.
	if let pending = context.insertedObjects.lazy
		.compactMap({ $0 as? NodeInfoEntity })
		.first(where: { $0.num == num }) {
		return pending
	}
	return createNodeInfo(num: num, context: context)
}