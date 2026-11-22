//
//  MeshPackets.swift
//  Meshtastic Apple
//
//  Created by Garth Vander Houwen on 5/27/22.
//

import CoreLocation
import Foundation
import CoreData
import MeshtasticProtobufs
import SwiftUI
import OSLog

// Simple extension to concisely pass values through a has_XXX boolean check
fileprivate extension Bool {
	func then<T>(_ value: T) -> T? {
		self ? value : nil
	}
}

/// Identifies one locally initiated automatic config refresh. The radio protocol reserves a
/// single config nonce, so this ownership stays local rather than appearing on the wire.
struct AutomaticChannelRefreshOwner: Equatable, Sendable {
	let sessionID: UUID
	let generation: UInt64
}

struct ChannelRefreshSnapshot: Equatable, Sendable {
	let id: Int32
	let index: Int32
	let uplinkEnabled: Bool
	let downlinkEnabled: Bool
	let name: String
	let role: Int32
	let psk: Data
	let positionPrecision: Int32
	let mute: Bool
}

private struct ChannelRefreshStage {
	let id = UUID()
	let owner: AutomaticChannelRefreshOwner?
	let baseline: [ChannelRefreshSnapshot]
	var channels: [Int32: StagedChannel] = [:]
}

private struct StagedChannel: Sendable {
	let id: Int32
	let index: Int32
	let uplinkEnabled: Bool
	let downlinkEnabled: Bool
	let name: String
	let role: Int32
	let psk: Data
	let positionPrecision: Int32
	let mute: Bool
}

/// Converts a ChannelEntity to a ChannelRefreshSnapshot for comparison.
private static func channelRefreshSnapshot(_ channel: ChannelEntity) -> ChannelRefreshSnapshot {
	ChannelRefreshSnapshot(
		id: channel.id,
		index: channel.index,
		uplinkEnabled: channel.uplinkEnabled,
		downlinkEnabled: channel.downlinkEnabled,
		name: channel.name ?? "",
		role: channel.role,
		psk: channel.psk ?? Data(),
		positionPrecision: channel.positionPrecision,
		mute: channel.mute
	)
}

/// Orders channel snapshots by index for consistent comparison.
private static func channelSnapshotIsOrderedBefore(_ lhs: ChannelRefreshSnapshot, _ rhs: ChannelRefreshSnapshot) -> Bool {
	lhs.index < rhs.index
}

/// Applies a StagedChannel to a ChannelEntity.
private static func applyChannelRefresh(_ staged: StagedChannel, to channel: ChannelEntity) {
	channel.id = staged.id
	channel.index = staged.index
	channel.uplinkEnabled = staged.uplinkEnabled
	channel.downlinkEnabled = staged.downlinkEnabled
	channel.name = staged.name
	channel.role = staged.role
	channel.psk = staged.psk
	channel.positionPrecision = staged.positionPrecision
	channel.mute = staged.mute
}

/// A context-bound actor replacing the former @ModelActor. Holds a private
/// NSManagedObjectContext created from the shared container so packet handlers
/// run off the main thread while still having a live Core Data context.
actor MeshPackets {
    let modelContext: NSManagedObjectContext

    init(modelContainer: NSPersistentContainer) {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = modelContainer.persistentStoreCoordinator
        context.automaticallyMergesChangesFromParent = true
        self.modelContext = context
    }

    // MARK: - Core Data Helpers

    /// Fetch entities using NSFetchRequest instead of FetchDescriptor
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
        return try modelContext.fetch(request)
    }

    /// Fetch count using NSFetchRequest
    func fetchCount<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> Int {
        return try modelContext.count(for: request)
    }

    /// Create a fetch request with predicate and sort descriptors
    func makeFetchRequest<T: NSManagedObject>(for entityType: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil, includePendingChanges: Bool = true) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let limit = fetchLimit {
            request.fetchLimit = limit
        }
        request.includesPendingChanges = includePendingChanges
        return request
    }

    /// Create a fetch request for count
    func makeCountRequest<T: NSManagedObject>(for entityType: T.Type, predicate: NSPredicate? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = predicate
        request.includesPendingChanges = false
        return request
    }

    // MARK: - Static Helpers

    /// Generate markdown links from detected addresses, phone numbers, and URLs in a message.
    static func generateMessageMarkdown(message: String) -> String {
	guard !message.isEmoji() else { return message }
	let types: NSTextCheckingResult.CheckingType = [.address, .link, .phoneNumber]
	guard let detector = try? NSDataDetector(types: types.rawValue) else {
		return message
	}
	let matches = detector.matches(in: message, options: [], range: NSRange(location: 0, length: message.utf16.count))
	guard !matches.isEmpty else { return message }

	// Find all existing markdown link ranges [text](url) so we can skip URLs inside them
	let linkPattern = try? NSRegularExpression(pattern: "\\[[^\\]]+\\]\\([^)]+\\)")
	let existingLinkRanges: [NSRange] = linkPattern?.matches(in: message, range: NSRange(location: 0, length: message.utf16.count)).map { $0.range } ?? []

	var messageWithMarkdown = message
	// Process matches in reverse order so earlier ranges stay valid
	// after inserting markdown syntax at later positions.
	for match in matches.reversed() {
		guard let range = Range(match.range, in: messageWithMarkdown) else { continue }
		let matchedText = String(messageWithMarkdown[range])

		// Skip if this match overlaps with an existing markdown link
		let matchNSRange = match.range
		let isInsideExistingLink = existingLinkRanges.contains { linkRange in
			NSIntersectionRange(linkRange, matchNSRange).length > 0
		}
		if isInsideExistingLink { continue }

		let replacement: String
		if match.resultType == .address {
			let urlEncodedAddress = matchedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
			replacement = "[\(matchedText)](http://maps.apple.com/?address=\(urlEncodedAddress))"
		} else if match.resultType == .phoneNumber {
			replacement = "[\(matchedText)](tel:\(matchedText))"
		} else if match.resultType == .link {
			let absoluteUrl = match.url?.absoluteString ?? ""
			replacement = "[\(matchedText)](\(absoluteUrl))"
		} else {
			continue
		}
		messageWithMarkdown.replaceSubrange(range, with: replacement)
	}
	return messageWithMarkdown
    }

    private struct TelemetryPruneKey: Hashable {
        let nodeNum: Int64
        let metricsType: Int32
    }

    /// Always the current shared container. Computed (not cached) so that after a data clear
    /// recreates the container, the next `recreateShared()` rebuilds the actor on the new one
    /// rather than a stale, torn-down container. Only read on the main actor (recreateShared and
    /// the initial `_shared` are both reached from @MainActor code).
    private static var _container: NSPersistentContainer {
        MainActor.assumeIsolated { CoreDataStackImpl.shared.container }
    }

    /// The current shared instance. Access via `MeshPackets.shared`.
    /// Periodically recreated to release accumulated ModelContext memory.
    nonisolated(unsafe) private static var _shared: MeshPackets = MeshPackets(modelContainer: _container)
    private static let _lock = NSLock()

    /// Staged automatic channel refreshes, keyed by node number. Deliberately static rather
    /// than actor state: `recreateShared()` swaps the shared instance to release memory, and a
    /// stage tied to the retired instance would silently orphan an in-flight refresh. Static
    /// storage makes recreation orthogonal — the successor actor stages into and commits from
    /// the same map. The lock covers the two executors that touch it: this actor (staging
    /// incoming channel frames) and the main actor (begin/commit/discard from AccessoryManager).
    nonisolated(unsafe) private static var channelRefreshStages: [Int64: ChannelRefreshStage] = [:]
    private static let channelRefreshStagesLock = NSLock()

    // Main-thread views read node/user/position entities during body evaluation, and a
    // cap eviction on this actor cascades all of them away — the invalid-entity trap
    // that tops the crash reports (Settings, node detail, node list rows). Evictions
    // wait for the app to background; while foregrounded only a doubled cap applies,
    // so a device that never backgrounds (a wall display) still stays bounded.
    nonisolated(unsafe) private static var _appIsActive = true
    private static let appActiveLock = NSLock()
    nonisolated static var appIsActive: Bool {
        get { appActiveLock.withLock { _appIsActive } }
        set { appActiveLock.withLock { _appIsActive = newValue } }
    }
    /// Background maintenance passes are numbered, and only the newest one's expiry counts.
    ///
    /// Backgrounding twice in quick succession leaves two passes in flight. With a single
    /// shared flag the older one's expiration handler would stop the newer pass, and the
    /// older one finishing would clear the newer one's expiry — each pass would be steering
    /// the other. A pass takes a number from `beginMaintenance()` and hands it back to
    /// `expireMaintenance(_:)`; a stale number is ignored, and starting a pass supersedes any
    /// earlier expiry without anyone having to clear it.
    nonisolated(unsafe) private static var _maintenanceGeneration = 0
    nonisolated(unsafe) private static var _expiredGeneration = -1

    /// Starts a maintenance pass and returns the number its expiration handler must quote.
    @discardableResult
    nonisolated static func beginMaintenance() -> Int {
        appActiveLock.withLock {
            _maintenanceGeneration += 1
            return _maintenanceGeneration
        }
    }

    /// Records that iOS is about to reclaim the assertion covering pass `generation`. Ignored
    /// if a later pass has already started, since that pass has its own grant.
    nonisolated static func expireMaintenance(_ generation: Int) {
        appActiveLock.withLock {
            if generation == _maintenanceGeneration { _expiredGeneration = generation }
        }
    }

    /// True when the pass currently running has been told its time is up. The chunked
    /// eviction checks this between chunks and stops on a committed boundary, rather than
    /// being killed mid-pass for CPU.
    nonisolated static var backgroundTimeExpired: Bool {
        appActiveLock.withLock { _expiredGeneration == _maintenanceGeneration }
    }

    static var shared: MeshPackets {
        _lock.lock()
        defer { _lock.unlock() }
        return _shared
    }

    /// Discards the current actor and creates a fresh one with a new ModelContext.
    /// Call after DB retrieval completes or periodically to release accumulated memory.
    static func recreateShared() {
        _lock.lock()
        let previous = _shared
        _shared = MeshPackets(modelContainer: _container)
        _lock.unlock()
        // Invalidate the retired instance. In-flight tasks that captured `MeshPackets.shared`
        // before the swap (a debounced save, a late packet for the previous radio) still hold
        // the old actor, whose context is bound to the old container — which points at the SAME
        // on-disk store as the new one. Letting those writes land after a device-switch
        // clearDatabase resurrects the previous radio's rows (nodes bleeding across devices)
        // and can trip reused-rowid "destroyed by ModelContext.reset" traps.
        Task { await previous.invalidate() }
        Logger.data.info("♻️ [MeshPackets] Recreated shared instance to release ModelContext memory")
    }

    // MARK: - Save Helpers

    /// Set when this instance has been replaced by `recreateShared()`. A retired instance must
    /// never persist again — see `recreateShared()`.
    private var invalidated = false

    func invalidate() {
        invalidated = true
        debounceSaveTask?.cancel()
        debounceSaveTask = nil
    }


	/// Saves any pending changes in the model context. Call once at the end of each
	/// top-level packet handler to batch all mutations from a single packet into one write.
	/// Set by any handler that touches a MessageEntity. Writes happen on this actor's context,
	/// which SwiftData does not propagate to views, so the message lists cannot observe them.
	/// One notification per save is enough for them to reload; observers debounce.
	private var pendingMessageChange = false

	func noteMessageChange() {
		pendingMessageChange = true
	}

	private func postMessageChange() {
		Task { @MainActor in
			NotificationCenter.default.post(name: .meshMessagesDidChange, object: nil)
		}
	}

	func savePendingChanges(caller: String = #function) {
		guard !invalidated else {
			Logger.data.warning("💾 [\(caller, privacy: .public)] Dropped save on retired MeshPackets instance")
			return
		}
		// Periodically enforce the global node/waypoint caps before committing, so evictions ride
		// along in this same save. Every save path funnels through here, so this one hook covers
		// nodes/waypoints created by any handler.
		savesSinceEntityCapCheck += 1
		if savesSinceEntityCapCheck >= Self.entityCapCheckInterval {
			savesSinceEntityCapCheck = 0
			enforceEntityCaps()
		}
		guard modelContext.hasChanges else { return }
		do {
			try modelContext.save()
			Logger.data.debug("💾 [\(caller, privacy: .public)] Saved pending changes")
			if pendingMessageChange {
				pendingMessageChange = false
				postMessageChange()
			}
		} catch {
			Logger.data.error("💥 [\(caller, privacy: .public)] Error saving: \(error.localizedDescription, privacy: .public)")
		}
	}

	/// Enforce the global caps on the two attacker-growable, un-capped stores. Runs inside
	/// `savePendingChanges` (throttled) so the deletes commit in the same write. Cheap in the
	/// common case: two COUNT queries, and the sorted fetch+delete only runs when actually over cap.
	/// Split into cap-parameterized helpers below so the eviction order is unit-testable with
	/// small datasets rather than needing tens of thousands of inserts.
	func enforceEntityCaps() {
		let multiplier = Self.appIsActive ? 2 : 1
		evictNodesIfOverCap(Self.maxTotalNodes * multiplier)
		evictWaypointsIfOverCap(Self.maxTotalWaypoints * multiplier)
	}

	/// Evict down to the strict caps and commit. Called on the background transition —
	/// the one moment deletes cannot race a view reading the doomed entities. The flag
	/// is re-checked here on the actor, not just at enqueue: a quick return to the
	/// foreground can beat this task's turn on the actor, and evicting then would be
	/// exactly the mid-render delete this exists to avoid.
	/// The caps and chunk size are parameters so a test can drive this exact code against a
	/// store small enough to go over cap. Production calls it with no arguments.
	func enforceEntityCapsAndSave(
		nodeCap: Int = MeshPackets.maxTotalNodes,
		waypointCap: Int = MeshPackets.maxTotalWaypoints,
		chunkSize: Int = MeshPackets.evictionChunkSize
	) async {
		guard !invalidated, !Self.appIsActive else { return }
		// One deadline for the pass, not one per collection: two three-second budgets would
		// be a six-second burst, which is the thing being bounded.
		let deadline = Date().addingTimeInterval(Self.evictionBudget)
		// At most a couple of thousand small rows; the commit below picks the deletes up.
		pruneNeighborLinks()
		await evictInChunks(until: deadline) {
			self.evictNodesIfOverCap(nodeCap, limit: chunkSize)
		}
		guard !Self.appIsActive else {
			commitEvictions()
			return
		}
		await evictInChunks(until: deadline) {
			self.evictWaypointsIfOverCap(waypointCap, limit: chunkSize)
		}
		commitEvictions()
	}

	/// Commits without going through `savePendingChanges`, whose periodic cap hook would run
	/// an unbounded `enforceEntityCaps` — deleting the whole remaining overage in one pass,
	/// immediately after the budget or the expiry stopped exactly that.
	private func commitEvictions() {
		guard !invalidated, modelContext.hasChanges else { return }
		do {
			try modelContext.save()
		} catch {
			Logger.data.error("💥 [Caps] Eviction failed to commit: \(error.localizedDescription, privacy: .public)")
		}
	}

	/// Run `step` until it reports nothing left to evict, committing and yielding between
	/// chunks.
	///
	/// The whole point is that this is interruptible. A device that drifted up to the doubled
	/// foreground cap has to delete as many as `maxTotalNodes` rows here, each cascading to a
	/// user and its positions, at the exact moment iOS starts charging the app for background
	/// CPU. In one pass that is a single uninterruptible burst; in chunks it is a series of
	/// committed steps that can stop at any boundary and resume on the next background
	/// transition, having kept everything already deleted.
	///
	/// Committing per chunk uses `modelContext.save()` rather than `savePendingChanges()`,
	/// which would re-enter `enforceEntityCaps` on its own interval and undo the chunking.
	private func evictInChunks(until deadline: Date, _ step: () -> Int) async {
		while !invalidated, !Self.appIsActive, !Self.backgroundTimeExpired {
			guard Date() < deadline else {
				Logger.data.info("🗄️ [Caps] Eviction budget spent; the rest waits for the next background transition")
				return
			}
			let removed = step()
			guard removed > 0 else { return }
			if modelContext.hasChanges {
				do {
					try modelContext.save()
				} catch {
					Logger.data.error("💥 [Caps] Eviction chunk failed to commit: \(error.localizedDescription, privacy: .public)")
					return
				}
			}
			await Task.yield()
		}
	}

	// MARK: - Watch Snapshot

	/// Value-copies every node the Watch cares about, on this actor.
	///
	/// The Watch update used to walk main-context entities while this actor's cap
	/// eviction (`evictNodesIfOverCap`) and near-duplicate position pruning deleted
	/// rows underneath them. An instance whose row another context deleted keeps
	/// passing `modelContext != nil` / `isDeleted == false` (a context never learns
	/// about another context's deletes), and the next persisted-property read traps
	/// in SwiftData's backing-data lookup — the app's largest crash. Running the
	/// snapshot here serializes it against every delete this actor performs, and
	/// only value types cross back.
	func watchNodeSnapshot(
		userLatitude: Double,
		userLongitude: Double,
		maxDistanceMeters: Double
	) -> [WatchNode] {
		// A retired instance's container may already be torn down (see recreateShared()).
		guard !invalidated else { return [] }
		let request = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
		request.predicate = NSPredicate(format: "user != nil")
		let results: [NodeInfoEntity]
		do {
			results = try modelContext.fetch(request)
		} catch {
			Logger.data.error("⌚ Watch snapshot fetch failed: \(error.localizedDescription, privacy: .public)")
			return []
		}
		let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
		// Every node's latest position in a couple of fetches, not a query per node: on a big mesh
		// the per-node reads held the main thread for seconds on every watch update.
		let positions = NodeInfoEntity.latestPositions(for: results, context: modelContext)
		return results.compactMap { node in
			positions[node.objectID].flatMap {
				WatchNode.make(from: node, position: $0, userLocation: userLocation, maxDistanceMeters: maxDistanceMeters)
			}
		}
	}

	// MARK: - Live Activity reading

	/// What the Live Activity shows for a tracked node, value-copied on this actor for the same
	/// reason as the watch snapshot: this actor deletes rows, and only value types cross back.
	/// It also sees this actor's unsaved writes, so a reading taken right after a packet isn't
	/// a debounced save behind.
	struct LiveActivityNodeReading: Sendable {
		let battery: Int32?
		/// 0 (none) to 3 (good); nil unless heard directly over LoRa, as on the node detail screen.
		let signalRating: Int?
		let lastHeard: Date?
		let hopsAway: Int32
		/// Meters from the connected radio, when both have a position.
		let distanceMeters: Double?
		let ignored: Bool
	}

	/// Why a reading is or isn't there: only a node that's really gone should end the activity,
	/// not a retired actor or a failed fetch.
	enum LiveActivityNodeLookup: Sendable {
		case found(LiveActivityNodeReading)
		/// Not in the database: deleted, evicted or cleared.
		case missing
		/// Couldn't look: this instance was retired, or the fetch failed.
		case unavailable
	}

	func liveActivityNodeReading(num: Int64, radioNum: Int64?) -> LiveActivityNodeLookup {
		guard !invalidated else { return .unavailable }
		// Fetch by the scalar number only; an optional-relationship nil check in a predicate
		// crashes on iOS 26.
		let nodeRequest = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
		nodeRequest.predicate = NSPredicate(format: "num == %lld", num)
		nodeRequest.fetchLimit = 1
		let fetched: [NodeInfoEntity]
		do {
			fetched = try modelContext.fetch(nodeRequest)
		} catch {
			Logger.data.error("🛰️ Live Activity node fetch failed: \(error.localizedDescription, privacy: .public)")
			return .unavailable
		}
		guard let node = fetched.first else { return .missing }

		var radio: NodeInfoEntity?
		if let radioNum {
			let radioRequest = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
			radioRequest.predicate = NSPredicate(format: "num == %lld", radioNum)
			radioRequest.fetchLimit = 1
			radio = try? modelContext.fetch(radioRequest).first
		}

		var signalRating: Int?
		if node.snr != 0 && !node.viaMqtt && node.hopsAway == 0 {
			let preset = (radio?.loRaConfig?.modemPreset).flatMap { ModemPresets(rawValue: Int($0)) } ?? .longFast
			signalRating = getLoRaSignalStrength(snr: node.snr, rssi: node.rssi, preset: preset, noiseFloor: radio?.recentNoiseFloor).rawValue
		}

		var distanceMeters: Double?
		if let nodeCoordinate = node.latestPosition?.nodeCoordinate,
		   let radioCoordinate = radio?.latestPosition?.nodeCoordinate {
			distanceMeters = CLLocation(latitude: nodeCoordinate.latitude, longitude: nodeCoordinate.longitude)
				.distance(from: CLLocation(latitude: radioCoordinate.latitude, longitude: radioCoordinate.longitude))
		}

		return .found(LiveActivityNodeReading(
			battery: node.latestDeviceMetrics?.batteryLevel,
			signalRating: signalRating,
			lastHeard: node.lastHeard,
			hopsAway: node.hopsAway,
			distanceMeters: distanceMeters,
			ignored: node.ignored
		))
	}

	/// Nodes: cap the total, evicting least-recently-heard first. Never evict favorites — the user
	/// explicitly kept those. Among already-persisted rows, `lastHeard` is optional; nil sorts first
	/// (ascending), so never-heard stubs go before any dated node, which is the correct "stalest
	/// first" order.
	/// `limit` bounds a single pass, for the chunked background path; nil evicts the whole
	/// overage at once, which is what the in-line `savePendingChanges` hook wants. Returns how
	/// many rows went, so a chunking caller knows when to stop.
	@discardableResult
	func evictNodesIfOverCap(_ cap: Int, limit: Int? = nil) -> Int {
		let countRequest = makeCountRequest(for: NodeInfoEntity.self)
		guard let nodeCount = try? fetchCount(countRequest), nodeCount > cap else { return 0 }
		let request = makeFetchRequest(for: NodeInfoEntity.self,
			predicate: NSPredicate(format: "favorite == NO"),
			sortDescriptors: [NSSortDescriptor(key: "lastHeard", ascending: true)])
		let overage = nodeCount - cap
		request.fetchLimit = limit.map { Swift.min($0, overage) } ?? overage
		request.includesPendingChanges = false
		guard let stale = try? fetch(request), !stale.isEmpty else { return 0 }
		TelemetryEntity.deleteAll(forNodes: stale.map(\.num), in: modelContext)
		NeighborLinkEntity.deleteAll(forNodes: stale.map(\.num), in: modelContext)
		for node in stale { modelContext.delete(node) }
		Logger.data.info("🗄️ [Caps] Evicted \(stale.count, privacy: .public) least-recently-heard node(s) (was \(nodeCount, privacy: .public), cap \(cap, privacy: .public))")
		return stale.count
	}

	/// Waypoints: cap the total, evicting oldest-last-updated first.
	@discardableResult
	func evictWaypointsIfOverCap(_ cap: Int, limit: Int? = nil) -> Int {
		let countRequest = makeCountRequest(for: WaypointEntity.self)
		guard let waypointCount = try? fetchCount(countRequest), waypointCount > cap else { return 0 }
		let request = makeFetchRequest(for: WaypointEntity.self,
			sortDescriptors: [NSSortDescriptor(key: "lastUpdated", ascending: true)])
		let overage = waypointCount - cap
		request.fetchLimit = limit.map { Swift.min($0, overage) } ?? overage
		request.includesPendingChanges = false
		guard let stale = try? fetch(request), !stale.isEmpty else { return 0 }
		for waypoint in stale { modelContext.delete(waypoint) }
		Logger.data.info("🗄️ [Caps] Evicted \(stale.count, privacy: .public) oldest waypoint(s) (was \(waypointCount, privacy: .public), cap \(cap, privacy: .public))")
		return stale.count
	}

#if DEBUG
	/// Test-only: reproduces a packet handler that creates a brand-new node stub via
	/// `findOrCreateNode` (a pending insert with a nil `lastHeard`) and then enforces the node cap in
	/// the *same* un-saved transaction, exactly as `savePendingChanges` does. The pending insert must
	/// live in this actor's own `modelContext`, so this seam exists to exercise that path — a
	/// separate context can't reproduce it. Returns after committing so callers can assert the new
	/// node survived. See `evictNodesIfOverCap`.
	func createNodeThenEvict(num: Int64, cap: Int) {
		_ = findOrCreateNode(num: num, context: modelContext)
		evictNodesIfOverCap(cap)
		try? modelContext.save()
	}
#endif

	// MARK: - Debounced Save for High-Frequency Packets

	/// Timer task for debounced saves (position/telemetry).
	private var debounceSaveTask: Task<Void, Never>?
	/// Tracks when we last flushed debounced changes to enforce a maximum delay.
	private var lastDebouncedSaveTime: Date = Date()
	/// How long to wait after the last mutation before flushing.
	private static let debounceInterval: TimeInterval = 2.0
	/// Maximum wall-clock time between flushes, even if packets keep arriving.
	private static let maxDebounceDelay: TimeInterval = 5.0
	static let maxPositionHistoryPerNode = 25_000
	static let maxTelemetryPerType = 5_000
	static let maxTotalMessages = 50_000
	/// Global caps on attacker-growable stores, so noisy mesh traffic (or a deliberate flood)
	/// can't grow local data without bound. Nodes evict least-recently-heard first; waypoints
	/// evict oldest-last-updated first. Favorite nodes are never evicted.
	static let maxTotalNodes = 10_000
	static let maxTotalWaypoints = 5_000
	/// Rows deleted per committed chunk on the background transition. Small enough that a
	/// chunk plus its cascades is a short burst, large enough that the worst case (a full
	/// `maxTotalNodes` overage) is tens of chunks rather than thousands.
	static let evictionChunkSize = 500
	/// How long one background transition may spend evicting.
	///
	/// Chunking alone does not bound CPU: `Task.yield()` hands control back immediately when
	/// nothing else is queued, so the chunks run back to back and a large backlog is still a
	/// long continuous burst — which is what the background CPU budget kills an app for. This
	/// is the actual bound. Whatever is left is already committed and the next background
	/// transition carries on, so a device over cap converges over a few backgroundings instead
	/// of paying for all of it at once. The doubled foreground cap holds the line meanwhile.
	static let evictionBudget: TimeInterval = 3.0
	private static let positionPruneInterval = 128
	private static let telemetryPruneInterval = 128
	private static let messagePruneInterval = 256
	/// Enforce the global node/waypoint caps once every N saves. A COUNT is cheap, but not worth
	/// running on literally every packet save; saves are already debounced under load.
	private static let entityCapCheckInterval = 64
	private var positionInsertsSincePrune: [Int64: Int] = [:]
	private var telemetryInsertsSincePrune: [TelemetryPruneKey: Int] = [:]
	private var messageInsertsSincePrune = 0
	private var savesSinceEntityCapCheck = 0

	/// Test seam for text-message notifications. Called instead of constructing a
	/// LocalNotificationManager inline. Defaults to the real scheduling path;
	/// tests replace it to capture what would have been scheduled.
	private var notificationScheduler: @MainActor @Sendable ([Notification]) -> Void = { notifications in
		let manager = LocalNotificationManager()
		manager.notifications = notifications
		manager.schedule()
	}

	/// Replace the notification scheduler (test seam). Actor-isolated so callers
	/// can `await` the mutation from outside the actor.
	func replaceNotificationScheduler(_ scheduler: @escaping @MainActor @Sendable ([Notification]) -> Void) {
		notificationScheduler = scheduler
	}

	/// Schedules a debounced save. Each call resets the 2-second timer. If packets
	/// keep arriving continuously, a save is forced every 5 seconds.
	/// Use for high-frequency packet types (position, telemetry) instead of `savePendingChanges`.
	func scheduleDebouncedSave() {
		guard !invalidated else { return }
		debounceSaveTask?.cancel()
		let elapsed = Date().timeIntervalSince(lastDebouncedSaveTime)
		if elapsed >= Self.maxDebounceDelay {
			savePendingChanges(caller: "debouncedFlush-maxDelay")
			lastDebouncedSaveTime = Date()
			return
		}
		debounceSaveTask = Task {
			try? await Task.sleep(nanoseconds: 2_000_000_000)
			guard !Task.isCancelled else { return }
			self.savePendingChanges(caller: "debouncedFlush")
			self.lastDebouncedSaveTime = Date()
		}
	}

	/// Immediately flushes any debounced saves. Call on disconnect or when entering background.
	func flushDebouncedSaves() {
		debounceSaveTask?.cancel()
		debounceSaveTask = nil
		savePendingChanges(caller: "flushDebouncedSaves")
		lastDebouncedSaveTime = Date()
	}

	/// Last time the channel-unread badge count was recomputed (an O(unread) scan).
	private var lastChannelUnreadRecompute: Date?
	/// Rate-limits the per-message channel-unread recompute to at most ~1/sec so a burst
	/// of incoming channel messages doesn't turn the badge update into quadratic work.
	func shouldRecomputeChannelUnread() -> Bool {
		let now = Date()
		if let last = lastChannelUnreadRecompute, now.timeIntervalSince(last) < 1.0 { return false }
		lastChannelUnreadRecompute = now
		return true
	}

	/// Last time the direct-message unread badge was recomputed. Same O(unread) scan and same
	/// burst hazard as the channel badge, so it gets the same ~1/sec rate limit — under a DM
	/// flood the badge tolerates a brief lag and resyncs on app-active and on read.
	private var lastDirectUnreadRecompute: Date?
	func shouldRecomputeDirectUnread() -> Bool {
		let now = Date()
		if let last = lastDirectUnreadRecompute, now.timeIntervalSince(last) < 1.0 { return false }
		lastDirectUnreadRecompute = now
		return true
	}

	func shouldPrunePositionHistory(for nodeNum: Int64) -> Bool {
		let nextCount = (positionInsertsSincePrune[nodeNum] ?? 0) + 1
		if nextCount >= Self.positionPruneInterval {
			positionInsertsSincePrune[nodeNum] = 0
			return true
		}
		positionInsertsSincePrune[nodeNum] = nextCount
		return false
	}

	func shouldPruneTelemetryHistory(nodeNum: Int64, metricsType: Int32) -> Bool {
		let key = TelemetryPruneKey(nodeNum: nodeNum, metricsType: metricsType)
		let nextCount = (telemetryInsertsSincePrune[key] ?? 0) + 1
		if nextCount >= Self.telemetryPruneInterval {
			telemetryInsertsSincePrune[key] = 0
			return true
		}
		telemetryInsertsSincePrune[key] = nextCount
		return false
	}

	func shouldPruneMessageHistory() -> Bool {
		messageInsertsSincePrune += 1
		if messageInsertsSincePrune >= Self.messagePruneInterval {
			messageInsertsSincePrune = 0
			return true
		}
		return false
	}

	func localConfig (config: Config, nodeNum: Int64, nodeLongName: String) {
		switch config.payloadVariant {
		case .bluetooth:
			upsertBluetoothConfigPacket(config: config.bluetooth, nodeNum: nodeNum)
		case .device:
			upsertDeviceConfigPacket(config: config.device, nodeNum: nodeNum)
		case .display:
			upsertDisplayConfigPacket(config: config.display, nodeNum: nodeNum)
		case .lora:
			upsertLoRaConfigPacket(config: config.lora, nodeNum: nodeNum)
		case .network:
			upsertNetworkConfigPacket(config: config.network, nodeNum: nodeNum)
		case .position:
			upsertPositionConfigPacket(config: config.position, nodeNum: nodeNum)
		case .power:
			upsertPowerConfigPacket(config: config.power, nodeNum: nodeNum)
		case .security:
			upsertSecurityConfigPacket(config: config.security, nodeNum: nodeNum)
		default:
#if DEBUG
			Logger.services.error("⁉️ Unknown Config variant UNHANDLED \(config.payloadVariant.debugDescription, privacy: .public)")
#endif
		}
	}

	func moduleConfig (config: ModuleConfig, nodeNum: Int64, nodeLongName: String) {
		switch config.payloadVariant {
		case .ambientLighting:
			upsertAmbientLightingModuleConfigPacket(config: config.ambientLighting, nodeNum: nodeNum)
		case .audio:
			upsertAudioModuleConfigPacket(config: config.audio, nodeNum: nodeNum)
		case .cannedMessage:
			upsertCannedMessagesModuleConfigPacket(config: config.cannedMessage, nodeNum: nodeNum)
		case .detectionSensor:
			upsertDetectionSensorModuleConfigPacket(config: config.detectionSensor, nodeNum: nodeNum)
		case .meshBeacon:
			upsertMeshBeaconModuleConfigPacket(config: config.meshBeacon, nodeNum: nodeNum)
		case .externalNotification:
			upsertExternalNotificationModuleConfigPacket(config: config.externalNotification, nodeNum: nodeNum)
		case .mqtt:
			upsertMqttModuleConfigPacket(config: config.mqtt, nodeNum: nodeNum)
		case .neighborInfo:
			upsertNeighborInfoModuleConfigPacket(config: config.neighborInfo, nodeNum: nodeNum)
		case .paxcounter:
			upsertPaxCounterModuleConfigPacket(config: config.paxcounter, nodeNum: nodeNum)
		case .rangeTest:
			upsertRangeTestModuleConfigPacket(config: config.rangeTest, nodeNum: nodeNum)
		case .serial:
			upsertSerialModuleConfigPacket(config: config.serial, nodeNum: nodeNum)
		case .telemetry:
			upsertTelemetryModuleConfigPacket(config: config.telemetry, nodeNum: nodeNum)
		case .storeForward:
			upsertStoreForwardModuleConfigPacket(config: config.storeForward, nodeNum: nodeNum)
		case .statusmessage:
			upsertStatusMessageModuleConfigPacket(config: config.statusmessage, nodeNum: nodeNum)
		case .tak:
			upsertTAKModuleConfigPacket(config: config.tak, nodeNum: nodeNum)
		case .trafficManagement:
			// Traffic management is configured on the radio only; the app keeps no copy.
			break
		default:
#if DEBUG
			Logger.services.error("⁉️ Unknown Module Config variant UNHANDLED \(config.payloadVariant.debugDescription, privacy: .public)")
#endif
		}
	}

	func myInfoPacket (myInfo: MyNodeInfo, peripheralId: String) -> NSManagedObjectID? {
		let logString = String.localizedStringWithFormat("MyInfo received: %@".localized, String(myInfo.myNodeNum))
		Logger.admin.info("ℹ️ \(logString, privacy: .public)")

		let myNodeNum = Int64(myInfo.myNodeNum)
		let request = NSFetchRequest<MyInfoEntity>(entityName: "MyInfoEntity")
		request.predicate = NSPredicate(format: "myNodeNum == %lld", myNodeNum)

		do {
			let fetchedMyInfo = try modelContext.fetch(request)
			// Not Found Insert
			if fetchedMyInfo.isEmpty {

				let myInfoEntity = MyInfoEntity(context: modelContext)
				myInfoEntity.peripheralId = peripheralId
				myInfoEntity.myNodeNum = Int64(myInfo.myNodeNum)
				myInfoEntity.rebootCount = Int32(truncatingIfNeeded: myInfo.rebootCount)
				myInfoEntity.deviceId = myInfo.deviceID
				if !myInfo.pioEnv.isEmpty {
					myInfoEntity.pioEnv = myInfo.pioEnv
				}
				Logger.data.info("💾 Saved a new myInfo for node: \(myInfo.myNodeNum.toHex(), privacy: .public)")
				savePendingChanges()
				return myInfoEntity.objectID
			} else {

				fetchedMyInfo[0].peripheralId = peripheralId
				fetchedMyInfo[0].myNodeNum = Int64(myInfo.myNodeNum)
				fetchedMyInfo[0].rebootCount = Int32(truncatingIfNeeded: myInfo.rebootCount)
				if !myInfo.pioEnv.isEmpty {
					fetchedMyInfo[0].pioEnv = myInfo.pioEnv
				}
				// Only set on insert before, so a row first written when the radio reported no device
				// id never gained one. Backups key on this. Guarded like pioEnv: an empty value never
				// clears a stored one.
				if !myInfo.deviceID.isEmpty {
					fetchedMyInfo[0].deviceId = myInfo.deviceID
				}

				Logger.data.info("💾 Updated myInfo for node: \(myInfo.myNodeNum.toHex(), privacy: .public)")
				savePendingChanges()
				return fetchedMyInfo[0].objectID
			}
		} catch {
			Logger.data.error("💥 Fetch MyInfo Error")
		}
		return nil
	}

	/// Removes the stage only when it is still the one the caller worked with — stale async
	/// work ending late cannot remove a successor's stage.
	private static func endChannelRefreshStage(for nodeNum: Int64, stageID: UUID) {
		channelRefreshStagesLock.lock()
		defer { channelRefreshStagesLock.unlock() }
		guard let stage = channelRefreshStages[nodeNum], stage.id == stageID else { return }
		channelRefreshStages.removeValue(forKey: nodeNum)
	}

	private func currentChannelSnapshot(for nodeNum: Int64) -> [ChannelRefreshSnapshot] {
		let request = NSFetchRequest<MyInfoEntity>(entityName: "MyInfoEntity")
		request.predicate = NSPredicate(format: "myNodeNum == %lld", nodeNum)
		guard let myInfo = try? modelContext.fetch(request).first else { return [] }
		return currentChannelSnapshot(from: myInfo)
	}

	private func currentChannelSnapshot(from myInfo: MyInfoEntity) -> [ChannelRefreshSnapshot] {
		myInfo.channels.map(Self.channelRefreshSnapshot).sorted(by: Self.channelSnapshotIsOrderedBefore)
	}

	private func isCompleteChannelRefresh(_ stagedChannels: [Int32: StagedChannel]) -> Bool {
		guard let primary = stagedChannels[0],
			  primary.role == Int32(Channel.Role.primary.rawValue) else { return false }
		guard Set(stagedChannels.keys) == Set(Int32(0)...Int32(7)) else { return false }
		return stagedChannels.values.allSatisfy { staged in
			staged.index >= 0 && staged.index < 8 &&
			(staged.index == 0 || staged.role != Int32(Channel.Role.primary.rawValue))
		}
	}

	func channelPacket(channel: Channel, fromNum: Int64, stageIfRefreshing: Bool = true) {
		if channel.isInitialized && (channel.hasSettings || channel.role == Channel.Role.disabled) {
			let logString = String.localizedStringWithFormat("Channel received: %d %@".localized, channel.index, String(fromNum))
			Logger.admin.info("🎛️ \(logString, privacy: .public)")

			if stageIfRefreshing {
				Self.channelRefreshStagesLock.lock()
				let isStaging = Self.channelRefreshStages[fromNum] != nil
				if isStaging {
					Self.channelRefreshStages[fromNum]?.channels[Int32(truncatingIfNeeded: channel.index)] = stagedChannel(from: channel)
				}
				Self.channelRefreshStagesLock.unlock()
				if isStaging { return }
			}

			let request = NSFetchRequest<MyInfoEntity>(entityName: "MyInfoEntity")
			request.predicate = NSPredicate(format: "myNodeNum == %lld", fromNum)

			do {
				let fetchedMyInfo = try modelContext.fetch(fetchDescriptor)
				if fetchedMyInfo.count == 1 {
					let existing = fetchedMyInfo[0].channels.first(where: { $0.index == Int32(truncatingIfNeeded: channel.index) })
					if channel.role == Channel.Role.disabled {
						if let existing {
							modelContext.delete(existing)
							savePendingChanges()
							Logger.data.info("💾 Deleted MyInfo channel \(channel.index, privacy: .public) from Channel App Packet For: \(fetchedMyInfo[0].myNodeNum, privacy: .public)")
						}
						return
					}
					let newChannel: ChannelEntity
					if let existing {
						newChannel = existing
					} else {
						newChannel = ChannelEntity(context: modelContext)
						fetchedMyInfo[0].channels.append(newChannel)
					}
					apply(stagedChannel: stagedChannel(from: channel), to: newChannel)
					savePendingChanges()
					Logger.data.info("💾 Updated MyInfo channel \(channel.index, privacy: .public) from Channel App Packet For: \(fetchedMyInfo[0].myNodeNum, privacy: .public)")
				} else if channel.role.rawValue > 0 {
					Logger.data.error("💥Trying to save a channel to a MyInfo that does not exist: \(fromNum.toHex(), privacy: .public)")
				}
			} catch {
				let nsError = error as NSError
				Logger.data.error("💥 Error Saving MyInfo Channel from ADMIN_APP \(nsError, privacy: .public)")
			}
		}
	}

	private func stagedChannel(from channel: Channel) -> StagedChannel {
		if channel.role == Channel.Role.disabled {
			return StagedChannel(
				id: Int32(truncatingIfNeeded: channel.index),
				index: Int32(truncatingIfNeeded: channel.index),
				uplinkEnabled: false,
				downlinkEnabled: false,
				name: "",
				role: Int32(Channel.Role.disabled.rawValue),
				psk: Data(),
				positionPrecision: 0,
				mute: false
			)
		}
		let positionPrecision: Int32
		let mute: Bool
		if channel.settings.hasModuleSettings {
			positionPrecision = Int32(truncatingIfNeeded: channel.settings.moduleSettings.positionPrecision)
			mute = channel.settings.moduleSettings.isMuted
		} else {
			// When moduleSettings is absent, use proto3 defaults (0/false)
			// rather than the entity default of 32, which would incorrectly
			// enable full-precision position sharing.
			positionPrecision = 0
			mute = false
		}
		return StagedChannel(
			id: Int32(truncatingIfNeeded: channel.index),
			index: Int32(truncatingIfNeeded: channel.index),
			uplinkEnabled: channel.settings.uplinkEnabled,
			downlinkEnabled: channel.settings.downlinkEnabled,
			name: channel.settings.name,
			role: Int32(channel.role.rawValue),
			psk: channel.settings.psk,
			positionPrecision: positionPrecision,
			mute: mute
		)
	}

	private func apply(stagedChannel: StagedChannel, to channel: ChannelEntity) {
		Self.applyChannelRefresh(stagedChannel, to: channel)
	}

	func deviceMetadataPacket (metadata: DeviceMetadata, fromNum: Int64, sessionPasskey: Data? = nil) {
		if metadata.isInitialized {
			let logString = String.localizedStringWithFormat("Device Metadata received from: %@".localized, fromNum.toHex())
			Logger.admin.info("🏷️ \(logString, privacy: .public)")

			let request = makeFetchRequest(for: NodeInfoEntity.self, predicate: NSPredicate(format: "num == %lld", fromNum))

			do {
				let fetchedNode = try fetch(request)
				guard fromNum > 0 else { return }
				let node = fetchedNode.first ?? findOrCreateNode(num: fromNum, context: modelContext)
				let storedMetadata = node.metadata ?? DeviceMetadataEntity(context: modelContext)
				if node.metadata == nil {
					node.metadata = storedMetadata
				}
				storedMetadata.update(from: metadata)
				if let sessionPasskey, !sessionPasskey.isEmpty {
					node.sessionPasskey = sessionPasskey
					node.sessionExpiration = Date().addingTimeInterval(300)
				}
				savePendingChanges()
				Logger.data.info("💾 Updated Device Metadata from Admin App Packet For: \(fromNum.toHex(), privacy: .public)")
			} catch {
				let nsError = error as NSError
				Logger.data.error("Error Saving MyInfo Channel from ADMIN_APP \(nsError, privacy: .public)")
			}
		}
	}

	/// After a full node database download: nodes the radio did not include are ones it no longer
	/// has, so it has no answer for them. Their stored heard-on-current-LoRa goes back to unknown,
	/// rather than keeping an answer from an earlier download.
	func markAbsentFromRadio(presentNums: Set<Int64>) {
		let request = makeFetchRequest(for: NodeInfoEntity.self, predicate: NSPredicate(format: "heardOnCurrentLora != -1"))
		guard let nodes = try? fetch(request) else { return }
		for node in nodes where !presentNums.contains(node.num) {
			node.heardOnCurrentLora = -1
		}
		savePendingChanges()
	}

	/// What to store for NodeInfo.heard_on_current_lora. -1 = unknown, 0 = false, 1 = true.
	/// The radio's own entry is left at -1: it is not something it hears.
	static func heardOnCurrentLora(_ nodeInfo: NodeInfo, reported: Bool, connectedNodeNum: Int64?) -> Int16 {
		guard reported, Int64(nodeInfo.num) != connectedNodeNum else { return -1 }
		return nodeInfo.heardOnCurrentLora ? 1 : 0
	}

	func nodeInfoPacket (nodeInfo: NodeInfo, channel: UInt32, deferSave: Bool = false, connectedNodeNum: Int64? = nil,
	                     reportsHeardOnCurrentLora: Bool = false) -> NSManagedObjectID? {
		// This path handles the connected device's local node-DB dump during wantConfig
		// (FromRadio.nodeInfo), not packets that crossed the mesh — log it as admin/setup.
		// Over-the-air NodeInfo arrives via upsertNodeInfoPacket and stays on .mesh.
		let logString = String.localizedStringWithFormat("📟 [NodeInfo] received for: %@".localized, String(nodeInfo.num))
		Logger.admin.info("📟 \(logString, privacy: .public)")

		guard nodeInfo.num > 0 else { return nil }

		let nodeNum = Int64(nodeInfo.num)
		let request = makeFetchRequest(for: NodeInfoEntity.self, predicate: NSPredicate(format: "num == %lld", nodeNum))

		do {
			let fetchedNode = try fetch(request)
			// Not Found Insert
			if fetchedNode.isEmpty && nodeInfo.num > 0 {

				// findOrCreateNode (not a bare insert): NodeInfoEntity.num is @Attribute(.unique), and a
				// still-pending stub node created by an earlier POSITION packet for this num would
				// otherwise collide on the unique num and trap on save.
				let newNode = findOrCreateNode(num: Int64(nodeInfo.num), context: modelContext)
					newNode.id = Int64(nodeInfo.num)
					newNode.num = Int64(nodeInfo.num)
					newNode.channel = Int32(truncatingIfNeeded: nodeInfo.channel)
					newNode.favorite = nodeInfo.isFavorite
					newNode.ignored = nodeInfo.isIgnored
					// Left out when the radio doesn't know how far away the node is; reading it anyway gives 0, which means direct.
					if nodeInfo.hasHopsAway {
						newNode.hopsAway = Int32(truncatingIfNeeded: nodeInfo.hopsAway)
					}
					newNode.viaMqtt = nodeInfo.viaMqtt
					newNode.hasXeddsaSigned = nodeInfo.hasXeddsaSigned_p
					// Was missing here while the update path below set it, so a node seen for the
					// first time — every node on a fresh install or after a database reset — lost
					// the radio's verification until some later NodeInfo happened to update it.
					newNode.isKeyManuallyVerified = nodeInfo.isKeyManuallyVerified
					newNode.heardOnCurrentLora = Self.heardOnCurrentLora(nodeInfo, reported: reportsHeardOnCurrentLora, connectedNodeNum: connectedNodeNum)

					if nodeInfo.hasDeviceMetrics {
						let telemetry = TelemetryEntity(context: modelContext)
						telemetry.batteryLevel = NSNumber(value: Int32(truncatingIfNeeded: nodeInfo.deviceMetrics.batteryLevel))
						telemetry.voltage = NSNumber(value: nodeInfo.deviceMetrics.voltage)
						telemetry.channelUtilization = NSNumber(value: nodeInfo.deviceMetrics.channelUtilization)
						telemetry.airUtilTx = NSNumber(value: nodeInfo.deviceMetrics.airUtilTx)
						telemetry.nodeNum = newNode.num
					}
					if nodeInfo.lastHeard > 0 {
						newNode.firstHeard = Date(timeIntervalSince1970: TimeInterval(Int64(nodeInfo.lastHeard)))
						newNode.lastHeard = Date(timeIntervalSince1970: TimeInterval(Int64(nodeInfo.lastHeard)))
					} else {
						newNode.firstHeard = Date()
						newNode.lastHeard = Date()
					}
					newNode.snr = nodeInfo.snr
					if nodeInfo.hasUser {

						// findOrCreateNode already attached a find-or-create user for this num; reuse it
						// (or find-or-create) instead of a bare insert whose duplicate unique num would trap.
						let newUser = newNode.user ?? findOrCreateUser(num: Int64(nodeInfo.num), context: modelContext)
						newUser.userId = nodeInfo.num.toHex()
						newUser.num = Int64(nodeInfo.num)
						newUser.longName = nodeInfo.user.longName
						newUser.shortName = nodeInfo.user.shortName
						newUser.hwModel = String(describing: nodeInfo.user.hwModel).uppercased()
						newUser.hwModelId = Int32(nodeInfo.user.hwModel.rawValue)
						let hwModelValue = Int64(newUser.hwModelId)
						let hwRequest = makeFetchRequest(for: DeviceHardwareEntity.self, predicate: NSPredicate(format: "hwModel == %lld", hwModelValue))
						if let hardware = try? fetch(hwRequest) {
							newUser.hwDisplayName = HardwareCatalogResolver.presentation(for: hwModelValue, in: hardware)?.displayName
						}
						newUser.isLicensed = nodeInfo.user.isLicensed
						newUser.role = Int32(nodeInfo.user.role.rawValue)
						if !nodeInfo.user.publicKey.isEmpty {
							newUser.pkiEncrypted = true
							newUser.publicKey = nodeInfo.user.publicKey
						}
						/// For nodes that have the optional isUnmessagable boolean use that, otherwise excluded roles that are unmessagable by default
						if nodeInfo.user.hasIsUnmessagable {
							newUser.unmessagable = nodeInfo.user.isUnmessagable
						} else {
							let roles = [2, 4, 5, 6, 7, 10, 11]
							let containsRole = roles.contains(Int(newUser.role))
							if containsRole {
								newUser.unmessagable = true
							} else {
								newUser.unmessagable = false
							}}
						newNode.user = newUser
					} else if nodeInfo.num > Constants.minimumNodeNum {
						do {
							let newUser = try createUser(num: Int64(nodeInfo.num), context: modelContext)
							newNode.user = newUser
						} catch PersistenceError.invalidInput(let message) {
							Logger.data.error("Error Creating a new UserEntity (Invalid Input) from node number: \(nodeInfo.num, privacy: .public) Error:  \(message, privacy: .public)")
						} catch {
							Logger.data.error("Error Creating a new UserEntity from node number: \(nodeInfo.num, privacy: .public) Error:  \(error.localizedDescription, privacy: .public)")
						}
					}

					if nodeInfo.position.hasValidCoordinates {
						let position = PositionEntity(context: modelContext)
						position.latest = true
						position.seqNo = Int32(truncatingIfNeeded: nodeInfo.position.seqNumber)
						position.latitudeI = nodeInfo.position.latitudeI
						position.longitudeI = nodeInfo.position.longitudeI
						position.altitude = nodeInfo.position.altitude
						position.satsInView = Int32(truncatingIfNeeded: nodeInfo.position.satsInView)
						position.speed = Int32(truncatingIfNeeded: nodeInfo.position.groundSpeed)
						position.heading = nodeInfo.position.groundTrackDegrees ?? 0
						position.time = Date(timeIntervalSince1970: TimeInterval(Int64(nodeInfo.position.time)))
						position.nodePosition = newNode
						newNode.latestPositionCache = position
					}

					// Look for a MyInfo
					let myInfoNodeNum = Int64(nodeInfo.num)
					let myInfoRequest = makeFetchRequest(for: MyInfoEntity.self, predicate: NSPredicate(format: "myNodeNum == %lld", myInfoNodeNum))

					do {
						let fetchedMyInfo = try fetch(myInfoRequest)
						if fetchedMyInfo.count > 0 {
							newNode.myInfo = fetchedMyInfo[0]
						}
						if !deferSave {
							savePendingChanges()
							Logger.data.debug("💾 Saved a new Node Info For: \(String(nodeInfo.num), privacy: .public)")
						} else {
							// Deferred (node-DB dump): batch writes, but still persist at least
							// every maxDebounceDelay so a long dump isn't one giant save.
							scheduleDebouncedSave()
						}
						return newNode.objectID
					} catch {
						Logger.data.error("Fetch MyInfo Error")
					}
				} else if nodeInfo.num > 0 {

					fetchedNode[0].id = Int64(nodeInfo.num)
					fetchedNode[0].num = Int64(nodeInfo.num)
					if nodeInfo.lastHeard > 0 {
						let candidate = Date(timeIntervalSince1970: TimeInterval(nodeInfo.lastHeard))
						if fetchedNode[0].lastHeard == nil || candidate > fetchedNode[0].lastHeard! {
							fetchedNode[0].lastHeard = candidate
						}
					}
					fetchedNode[0].snr = nodeInfo.snr
					fetchedNode[0].channel = Int32(truncatingIfNeeded: nodeInfo.channel)
					fetchedNode[0].favorite = nodeInfo.isFavorite
					fetchedNode[0].ignored = nodeInfo.isIgnored
					if nodeInfo.hasHopsAway {
						fetchedNode[0].hopsAway = Int32(truncatingIfNeeded: nodeInfo.hopsAway)
					}
					fetchedNode[0].viaMqtt = nodeInfo.viaMqtt
					// Both trust flags come from the radio's node db, which is where they live: the
					// firmware sets has_xeddsa_signed when it verifies a signature and
					// is_key_manually_verified on a contact exchange, and persists both across its
					// own cleanups. So the dump is taken verbatim, the same as favorite and ignored
					// above. Latching either one would let the app go on showing a node as signed or
					// verified after the radio had stopped saying so — claiming a trust level the
					// radio that does the actual verifying no longer holds.
					fetchedNode[0].hasXeddsaSigned = nodeInfo.hasXeddsaSigned_p
					fetchedNode[0].isKeyManuallyVerified = nodeInfo.isKeyManuallyVerified
					fetchedNode[0].heardOnCurrentLora = Self.heardOnCurrentLora(nodeInfo, reported: reportsHeardOnCurrentLora, connectedNodeNum: connectedNodeNum)

					if nodeInfo.hasUser {
						if fetchedNode[0].user == nil {
							// findOrCreateUser (not a bare insert): a user row for this unique num may already
							// exist (orphaned or pending), so a bare insert would trap on save.
							let newUserEntity = findOrCreateUser(num: Int64(nodeInfo.num), context: modelContext)
							fetchedNode[0].user = newUserEntity
						}
						if let connectedNodeNum, nodeNum == connectedNodeNum {
							// The connected radio reporting its own user over the direct link is
							// ground truth — a 2.8 upgrade or factory reset regenerates its keypair,
							// and first-wins would flag the radio's own new key as a mismatch.
							fetchedNode[0].user?.acceptOwnRadioPublicKey(nodeInfo.user.publicKey)
						} else {
							// First-wins on the public key, consistent with the NodeInfo/User paths in UpdateSwiftData
							// (previously a `== nil` guard here silently ignored mismatches). See `applyInboundPublicKey`.
							fetchedNode[0].user?.applyInboundPublicKey(nodeInfo.user.publicKey, nodeNum: Int64(nodeInfo.num))
						}
						fetchedNode[0].user?.userId = nodeInfo.num.toHex()
						fetchedNode[0].user?.num = Int64(nodeInfo.num)
						fetchedNode[0].user?.numString = String(nodeInfo.num)
						fetchedNode[0].user?.longName = nodeInfo.user.longName
						fetchedNode[0].user?.shortName = nodeInfo.user.shortName
						fetchedNode[0].user?.isLicensed = nodeInfo.user.isLicensed
						fetchedNode[0].user?.role = Int32(nodeInfo.user.role.rawValue)
						fetchedNode[0].user?.hwModel = String(describing: nodeInfo.user.hwModel).uppercased()
						fetchedNode[0].user?.hwModelId = Int32(nodeInfo.user.hwModel.rawValue)
						/// For nodes that have the optional isUnmessagable boolean use that, otherwise excluded roles that are unmessagable by default
						if nodeInfo.user.hasIsUnmessagable {
							fetchedNode[0].user?.unmessagable = nodeInfo.user.isUnmessagable
						} else {
							let roles = [-1, 2, 4, 5, 6, 7, 10, 11]
							let containsRole = roles.contains(Int(fetchedNode[0].user?.role ?? -1))
							if containsRole {
								fetchedNode[0].user?.unmessagable = true
							} else {
								fetchedNode[0].user?.unmessagable = false
							}
						}
						if let user = fetchedNode.first?.user {
							let hwModelValue2 = Int64(user.hwModelId)
							let hwRequest2 = makeFetchRequest(for: DeviceHardwareEntity.self, predicate: NSPredicate(format: "hwModel == %lld", hwModelValue2))
							if let hardware = try? fetch(hwRequest2) {
								user.hwDisplayName = HardwareCatalogResolver.presentation(for: hwModelValue2, in: hardware)?.displayName
							}
						}
					} else {
						if fetchedNode[0].user == nil && nodeInfo.num > Constants.minimumNodeNum {
							do {
								let newUser = try createUser(num: Int64(nodeInfo.num), context: modelContext)
								fetchedNode[0].user = newUser
							} catch PersistenceError.invalidInput(let message) {
								Logger.data.error("Error Creating a new UserEntity on an existing node (Invalid Input) from node number: \(nodeInfo.num, privacy: .public) Error:  \(message, privacy: .public)")
							} catch {
								Logger.data.error("Error Creating a new UserEntity on an existing node from node number: \(nodeInfo.num, privacy: .public) Error:  \(error.localizedDescription, privacy: .public)")
							}
						}
					}

					if nodeInfo.hasDeviceMetrics {

						let newTelemetry = TelemetryEntity(context: modelContext)
						newTelemetry.batteryLevel = NSNumber(value: Int32(truncatingIfNeeded: nodeInfo.deviceMetrics.batteryLevel))
						newTelemetry.voltage = NSNumber(value: nodeInfo.deviceMetrics.voltage)
						newTelemetry.channelUtilization = NSNumber(value: nodeInfo.deviceMetrics.channelUtilization)
						newTelemetry.airUtilTx = NSNumber(value: nodeInfo.deviceMetrics.airUtilTx)
						newTelemetry.nodeNum = fetchedNode[0].num
					}

					if nodeInfo.hasPosition {

						if nodeInfo.position.hasValidCoordinates {

							let position = PositionEntity(context: modelContext)
							position.latitudeI = nodeInfo.position.latitudeI
							position.longitudeI = nodeInfo.position.longitudeI
							position.altitude = nodeInfo.position.altitude
							position.satsInView = Int32(truncatingIfNeeded: nodeInfo.position.satsInView)
							position.time = Date(timeIntervalSince1970: TimeInterval(Int64(nodeInfo.position.time)))
							position.nodePosition = fetchedNode[0]
						}

					}

					// Look for a MyInfo
					let myInfoNodeNum2 = Int64(nodeInfo.num)
					let myInfoRequest2 = makeFetchRequest(for: MyInfoEntity.self, predicate: NSPredicate(format: "myNodeNum == %lld", myInfoNodeNum2))

					do {
						let fetchedMyInfo = try fetch(myInfoRequest2)
						if fetchedMyInfo.count > 0 {
							fetchedNode[0].myInfo = fetchedMyInfo[0]
						}
						if !deferSave {
							savePendingChanges()
							Logger.data.debug("💾 [Node Info] saved for \(nodeInfo.num.toHex(), privacy: .public)")
						} else {
							scheduleDebouncedSave()
						}
						return fetchedNode[0].objectID
					} catch {
						Logger.data.error("💥 Fetch MyInfo Error")
					}
				}
		} catch {
			Logger.data.error("💥 Fetch NodeInfoEntity Error")
		}
		return nil
	}

	func adminAppPacket (packet: MeshPacket, connectedNodeNum: Int64? = nil) {
		if let adminMessage = try? AdminMessage(serializedBytes: packet.decoded.payload) {
			// A response is only applied when it answers a request this app sent to that node.
			// Anything else would be stored as the node's settings and sent back on Save.
			switch adminMessage.payloadVariant {
			case .getChannelResponse, .getOwnerResponse, .getConfigResponse, .getModuleConfigResponse,
				 .getCannedMessageModuleMessagesResponse, .getDeviceMetadataResponse, .getRingtoneResponse,
				 .getDeviceConnectionStatusResponse, .getNodeRemoteHardwarePinsResponse, .getUiConfigResponse:
				guard AdminRequestTracker.consumeResponse(packet, connectedNodeNum: connectedNodeNum) else {
					Logger.admin.warning("🚫 Dropped admin response from \(packet.from.toHex(), privacy: .public) that does not answer a request we sent")
					return
				}
			default:
				break
			}
			// The session key from a reply to a request we sent. One with no key leaves the
			// stored session alone.
			let responsePasskey: Data? = adminMessage.sessionPasskey.isEmpty ? nil : adminMessage.sessionPasskey

			if adminMessage.payloadVariant == AdminMessage.OneOf_PayloadVariant.getCannedMessageModuleMessagesResponse(adminMessage.getCannedMessageModuleMessagesResponse) {

				if let cmmc = try? CannedMessageModuleConfig(serializedBytes: packet.decoded.payload) {
					let logString = String.localizedStringWithFormat("Canned Messages Messages Received For: %@".localized, packet.from.toHex())
					Logger.admin.info("🥫 \(logString, privacy: .public)")

					let packetFrom = Int64(packet.from)
					let request = makeFetchRequest(for: NodeInfoEntity.self, predicate: NSPredicate(format: "num == %lld", packetFrom))

					do {
						let fetchedNode = try fetch(request)
						if fetchedNode.count == 1 {
							let messages =  String(cmmc.textFormatString())
								.replacingOccurrences(of: "11: ", with: "")
								.replacingOccurrences(of: "\"", with: "")
								.trimmingCharacters(in: .whitespacesAndNewlines)
								.components(separatedBy: "\n").first ?? ""
							fetchedNode[0].cannedMessageConfig?.messages = messages
							savePendingChanges()
							Logger.data.info("💾 Updated Canned Messages Messages For: \(fetchedNode.first?.num.toHex() ?? "Unknown".localized, privacy: .public)")
						}
					} catch {
						Logger.data.error("💥 Error Deserializing ADMIN_APP packet.")
					}
				}
			} else if adminMessage.payloadVariant == AdminMessage.OneOf_PayloadVariant.getChannelResponse(adminMessage.getChannelResponse) {
				channelPacket(channel: adminMessage.getChannelResponse, fromNum: Int64(packet.from))
			} else if adminMessage.payloadVariant == AdminMessage.OneOf_PayloadVariant.getDeviceMetadataResponse(adminMessage.getDeviceMetadataResponse) {
				deviceMetadataPacket(metadata: adminMessage.getDeviceMetadataResponse, fromNum: Int64(packet.from), sessionPasskey: responsePasskey)
			} else if adminMessage.payloadVariant == AdminMessage.OneOf_PayloadVariant.getConfigResponse(adminMessage.getConfigResponse) {
				let config = adminMessage.getConfigResponse
				if config.payloadVariant == Config.OneOf_PayloadVariant.bluetooth(config.bluetooth) {
					upsertBluetoothConfigPacket(config: config.bluetooth, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if config.payloadVariant == Config.OneOf_PayloadVariant.device(config.device) {
					upsertDeviceConfigPacket(config: config.device, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if config.payloadVariant == Config.OneOf_PayloadVariant.display(config.display) {
					self.upsertDisplayConfigPacket(config: config.display, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if config.payloadVariant == Config.OneOf_PayloadVariant.lora(config.lora) {
					self.upsertLoRaConfigPacket(config: config.lora, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if config.payloadVariant == Config.OneOf_PayloadVariant.network(config.network) {
					self.upsertNetworkConfigPacket(config: config.network, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if config.payloadVariant == Config.OneOf_PayloadVariant.position(config.position) {
					self.upsertPositionConfigPacket(config: config.position, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if config.payloadVariant == Config.OneOf_PayloadVariant.power(config.power) {
					self.upsertPowerConfigPacket(config: config.power, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if config.payloadVariant == Config.OneOf_PayloadVariant.security(config.security) {
					self.upsertSecurityConfigPacket(config: config.security, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				}
			} else if adminMessage.payloadVariant == AdminMessage.OneOf_PayloadVariant.getModuleConfigResponse(adminMessage.getModuleConfigResponse) {
				let moduleConfig = adminMessage.getModuleConfigResponse
				if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.ambientLighting(moduleConfig.ambientLighting) {
					self.upsertAmbientLightingModuleConfigPacket(config: moduleConfig.ambientLighting, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.audio(moduleConfig.audio) {
					self.upsertAudioModuleConfigPacket(config: moduleConfig.audio, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.cannedMessage(moduleConfig.cannedMessage) {
					self.upsertCannedMessagesModuleConfigPacket(config: moduleConfig.cannedMessage, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.detectionSensor(moduleConfig.detectionSensor) {
					self.upsertDetectionSensorModuleConfigPacket(config: moduleConfig.detectionSensor, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.externalNotification(moduleConfig.externalNotification) {
					self.upsertExternalNotificationModuleConfigPacket(config: moduleConfig.externalNotification, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.mqtt(moduleConfig.mqtt) {
					self.upsertMqttModuleConfigPacket(config: moduleConfig.mqtt, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.rangeTest(moduleConfig.rangeTest) {
					self.upsertRangeTestModuleConfigPacket(config: moduleConfig.rangeTest, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.serial(moduleConfig.serial) {
					self.upsertSerialModuleConfigPacket(config: moduleConfig.serial, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.storeForward(moduleConfig.storeForward) {
					self.upsertStoreForwardModuleConfigPacket(config: moduleConfig.storeForward, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.telemetry(moduleConfig.telemetry) {
					self.upsertTelemetryModuleConfigPacket(config: moduleConfig.telemetry, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.tak(moduleConfig.tak) {
					self.upsertTAKModuleConfigPacket(config: moduleConfig.tak, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.statusmessage(moduleConfig.statusmessage) {
					self.upsertStatusMessageModuleConfigPacket(config: moduleConfig.statusmessage, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				} else if moduleConfig.payloadVariant == ModuleConfig.OneOf_PayloadVariant.meshBeacon(moduleConfig.meshBeacon) {
					self.upsertMeshBeaconModuleConfigPacket(config: moduleConfig.meshBeacon, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				}
			} else if adminMessage.payloadVariant == AdminMessage.OneOf_PayloadVariant.getRingtoneResponse(adminMessage.getRingtoneResponse) {
				if let rt = try? RTTTLConfig(serializedBytes: packet.decoded.payload) {
					self.upsertRtttlConfigPacket(ringtone: rt.ringtone, nodeNum: Int64(packet.from), sessionPasskey: responsePasskey)
				}
			} else {
				Logger.admin.error("🕸️ MESH PACKET received Admin App UNHANDLED \((try? packet.decoded.jsonString()) ?? "JSON Decode Failure", privacy: .public)")
			}
			// An admin *response* carrying a session passkey is proof an admin request we
			// sent to this node succeeded, so remember that it has been administered.
			// Responses that answer no request were dropped above, so an unsolicited or
			// forwarded admin message never unlocks the remote-admin UI. Runs after the
			// handlers above so a node first heard via a metadata response exists by now.
			if responsePasskey != nil {
				switch adminMessage.payloadVariant {
				case .getChannelResponse, .getOwnerResponse, .getConfigResponse, .getModuleConfigResponse,
					 .getCannedMessageModuleMessagesResponse, .getDeviceMetadataResponse, .getRingtoneResponse,
					 .getDeviceConnectionStatusResponse, .getNodeRemoteHardwarePinsResponse, .getUiConfigResponse:
					markNodeAdministered(num: Int64(packet.from))
				default:
					break
				}
			}
			// Save an ack for the admin message log for each admin message response received as we stopped sending acks if there is also a response to reduce airtime.
			self.adminResponseAck(packet: packet)
		}
	}

	private func adminResponseAck (packet: MeshPacket) {
		let requestID = Int64(packet.decoded.requestID)
		let request = makeFetchRequest(for: MessageEntity.self, predicate: NSPredicate(format: "messageId == %lld", requestID))
		do {
			let fetchedMessage = try fetch(request)
			if fetchedMessage.count > 0 {
				fetchedMessage[0].ackTimestamp = Int32(Date().timeIntervalSince1970)
				fetchedMessage[0].ackError = Int32(RoutingError.none.rawValue)
				fetchedMessage[0].receivedACK = true
				fetchedMessage[0].realACK = true
				fetchedMessage[0].relayNode = Int64(packet.relayNode)
				fetchedMessage[0].ackSNR = packet.rxSnr

				noteMessageChange()
				savePendingChanges()
			}
		} catch {
			Logger.data.error("Failed to fetch admin message by requestID: \(error.localizedDescription, privacy: .public)")
		}
	}

	func paxCounterPacket (packet: MeshPacket) {
		let paxDetail = (try? Paxcount(serializedBytes: packet.decoded.payload)).map { " — \($0.wifi) wifi \($0.ble) ble" } ?? ""
		Logger.mesh.info("[PAX Counter] packet received from \(packet.from.toHex(), privacy: .public)\(paxDetail, privacy: .public)")

		let packetFrom = Int64(packet.from)
		let request = makeFetchRequest(for: NodeInfoEntity.self, predicate: NSPredicate(format: "num == %lld", packetFrom))
		request.fetchLimit = 1

		do {
			let fetchedNode = try fetch(request)

			if let paxMessage = try? Paxcount(serializedBytes: packet.decoded.payload) {
				// Create the sending node when unheard, same as deviceMetadataPacket and
				// telemetryPacket — an unlinked reading would persist as an orphan row.
				let node = fetchedNode.first ?? findOrCreateNode(num: packetFrom, context: modelContext)

				let newPax = PaxCounterEntity(context: modelContext)
				newPax.ble = Int32(truncatingIfNeeded: paxMessage.ble)
				newPax.wifi = Int32(truncatingIfNeeded: paxMessage.wifi)
				newPax.uptime = Int32(truncatingIfNeeded: paxMessage.uptime)
				newPax.time = Date()
				newPax.paxNode = node
				scheduleDebouncedSave()
			}
		} catch {

		}
	}

	func routingPacket (packet: MeshPacket, connectedNodeNum: Int64) {
		if let routingMessage = try? Routing(serializedBytes: packet.decoded.payload) {

			let routingError = RoutingError(rawValue: routingMessage.errorReason.rawValue)

			let routingErrorString = routingError?.display ?? "Unknown".localized
			let logString = String.localizedStringWithFormat("Routing received for RequestID: %@ Ack Status: %@".localized, String(packet.decoded.requestID), routingErrorString)
			Logger.mesh.info("🕸️ \(logString, privacy: .public)")

			let requestID = Int64(packet.decoded.requestID)
			let request = makeFetchRequest(for: MessageEntity.self, predicate: NSPredicate(format: "messageId == %lld", requestID))

			do {
				let fetchedMessage = try fetch(request)
				if fetchedMessage.count > 0 {
					if fetchedMessage[0].toUser != nil {
						// Real ACK from DM Recipient
						if packet.to != packet.from {
							fetchedMessage[0].realACK = true
						}
					}
					fetchedMessage[0].relayNode = Int64(packet.relayNode)
					fetchedMessage[0].ackError = Int32(routingMessage.errorReason.rawValue)
					if routingMessage.errorReason == Routing.Error.none {
						fetchedMessage[0].receivedACK = true
						fetchedMessage[0].relays += 1
					}

					fetchedMessage[0].ackSNR = packet.rxSnr
					if packet.rxTime > 0 {
						fetchedMessage[0].ackTimestamp = Int32(truncatingIfNeeded: packet.rxTime)
					} else {
						fetchedMessage[0].ackTimestamp = Int32(Date().timeIntervalSince1970)
					}

				} else {
					return
				}
				noteMessageChange()
				scheduleDebouncedSave()
				Logger.data.debug("💾 ACK buffered for Message: \(packet.decoded.requestID, privacy: .public)")
			} catch {
				let nsError = error as NSError
				Logger.data.error("Error Saving ACK for message: \(packet.id, privacy: .public) Error: \(nsError, privacy: .public)")
			}
		}
	}

	/// Compact, human-readable summary of a Telemetry packet for the mesh log line, e.g.
	/// " — device 87% 4.05V ch 12.3% air 3.1%" or " — env 23.5°C 45% 1013hPa". Reads the salient
	/// metrics per variant (not raw JSON); returns "" for unhandled variants.
	private func telemetryLogDetails(_ telemetry: Telemetry) -> String {
		var parts: [String] = []
		switch telemetry.variant {
		case .deviceMetrics(let m)?:
			parts.append("device")
			if m.hasBatteryLevel { parts.append("\(m.batteryLevel)%") }
			if m.hasVoltage { parts.append(String(format: "%.2fV", m.voltage)) }
			if m.hasChannelUtilization { parts.append(String(format: "ch %.1f%%", m.channelUtilization)) }
			if m.hasAirUtilTx { parts.append(String(format: "air %.1f%%", m.airUtilTx)) }
		case .environmentMetrics(let m)?:
			parts.append("env")
			if m.hasTemperature { parts.append(String(format: "%.1f°C", m.temperature)) }
			if m.hasRelativeHumidity { parts.append(String(format: "%.0f%%", m.relativeHumidity)) }
			if m.hasBarometricPressure { parts.append(String(format: "%.0fhPa", m.barometricPressure)) }
		case .powerMetrics(let m)?:
			parts.append("power")
			if m.hasCh1Voltage { parts.append(String(format: "ch1 %.2fV", m.ch1Voltage)) }
			if m.hasCh2Voltage { parts.append(String(format: "ch2 %.2fV", m.ch2Voltage)) }
			if m.hasCh3Voltage { parts.append(String(format: "ch3 %.2fV", m.ch3Voltage)) }
		case .localStats(let m)?:
			parts.append("stats")
			parts.append("\(m.numOnlineNodes)/\(m.numTotalNodes) nodes")
		case .airQualityMetrics(let m)?:
			parts.append("aqi")
			if m.hasPm25Standard { parts.append("PM2.5 \(m.pm25Standard)") }
			if m.hasPm10Standard { parts.append("PM1.0 \(m.pm10Standard)") }
			if m.hasPm100Standard { parts.append("PM10 \(m.pm100Standard)") }
		default:
			return ""
		}
		return " — " + parts.joined(separator: " ")
	}

	/// First non-zero proto epoch (seconds since 1970) from `candidates`, as a `Date`; falls back to
	/// now when none are set. Remote nodes without an RTC/GPS report 0, which would otherwise store as
	/// 1970 and be hidden by the node detail's "latest" sort and the 7-day chart window — so callers
	/// pass the sensor's self-reported time first, then `packet.rxTime`, to anchor on the best clock
	/// available.
	private func resolveTimestamp(_ candidates: UInt32...) -> Date {
		for seconds in candidates where seconds > 0 {
			return Date(timeIntervalSince1970: TimeInterval(seconds))
		}
		return Date()
	}

	func telemetryPacket(packet: MeshPacket, connectedNode: Int64) {
		if let telemetryMessage = try? Telemetry(serializedBytes: packet.decoded.payload) {
			let handledVariants: [Telemetry.OneOf_Variant] = [
				.deviceMetrics(telemetryMessage.deviceMetrics),
				.environmentMetrics(telemetryMessage.environmentMetrics),
				.localStats(telemetryMessage.localStats),
				.powerMetrics(telemetryMessage.powerMetrics),
				.airQualityMetrics(telemetryMessage.airQualityMetrics)
			]
			if !handledVariants.contains(where: { $0 == telemetryMessage.variant }) {
				/// Other unhandled telemetry packets
				return
			}
			// Mesh-category audit (spec 012): telemetry received over the air from a
			// remote node is genuine mesh traffic and belongs in the Packet Stream,
			// consistent with text/position/nodeinfo. The connected node's own
			// localStats (from == connectedNode) is local, not OTA, so it stays on
			// .data/.statistics below and out of the Mesh category.
			if connectedNode != Int64(packet.from) {
				Logger.mesh.info("📈 [Telemetry] packet received from \(packet.from.toHex(), privacy: .public)\(self.telemetryLogDetails(telemetryMessage), privacy: .public)")
			}
			let packetFrom = Int64(packet.from)
			// packet.from == 0 is not a real node, so there is nothing to attribute telemetry to.
			guard packetFrom > 0 else { return }
			// Telemetry is genuine RF contact with packet.from. Like deviceMetadataPacket /
			// textMessageAppPacket, ensure a NodeInfoEntity exists before storing so telemetry that
			// arrives before the node's NodeInfo / nodeDB entry is not dropped as an orphan row
			// (no node to show it under) that the UI can never query. `num` is @Attribute(.unique), so this
			// returns the existing node or a minimal stub that a later NodeInfo packet enriches.
			let node = findOrCreateNode(num: packetFrom, context: modelContext)
			let telemetry = TelemetryEntity(context: modelContext)
			/// Currently only Device Metrics and Environment Telemetry are supported in the app
			if telemetryMessage.variant == Telemetry.OneOf_Variant.deviceMetrics(telemetryMessage.deviceMetrics) {
				// Device Metrics
				Logger.data.debug("📈 [Telemetry] Device Metrics Received for Node: \(packet.from.toHex(), privacy: .public)")
				telemetry.airUtilTx = telemetryMessage.deviceMetrics.hasAirUtilTx.then(NSNumber(value: telemetryMessage.deviceMetrics.airUtilTx))
				telemetry.channelUtilization = telemetryMessage.deviceMetrics.hasChannelUtilization.then(NSNumber(value: telemetryMessage.deviceMetrics.channelUtilization))
				telemetry.batteryLevel = telemetryMessage.deviceMetrics.hasBatteryLevel.then(NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.deviceMetrics.batteryLevel)))
				telemetry.voltage = telemetryMessage.deviceMetrics.hasVoltage.then(NSNumber(value: telemetryMessage.deviceMetrics.voltage))
				telemetry.uptimeSeconds = telemetryMessage.deviceMetrics.hasUptimeSeconds.then(NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.deviceMetrics.uptimeSeconds)))
				telemetry.metricsType = 0
				Logger.statistics.debug("📈 [Mesh Statistics] Channel Utilization: \(telemetryMessage.deviceMetrics.channelUtilization, privacy: .public) Airtime: \(telemetryMessage.deviceMetrics.airUtilTx, privacy: .public) for Node: \(packet.from.toHex(), privacy: .public)")
			} else if telemetryMessage.variant == Telemetry.OneOf_Variant.environmentMetrics(telemetryMessage.environmentMetrics) {
				// Environment Metrics
				Logger.data.debug("📈 [Telemetry] Environment Metrics Received for Node: \(packet.from.toHex(), privacy: .public)")
				telemetry.barometricPressure = telemetryMessage.environmentMetrics.hasBarometricPressure.then(NSNumber(value: telemetryMessage.environmentMetrics.barometricPressure))
				telemetry.iaq = telemetryMessage.environmentMetrics.hasIaq.then(NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.environmentMetrics.iaq)))
				telemetry.gasResistance = telemetryMessage.environmentMetrics.hasGasResistance.then(NSNumber(value: telemetryMessage.environmentMetrics.gasResistance))
				telemetry.relativeHumidity = telemetryMessage.environmentMetrics.hasRelativeHumidity.then(NSNumber(value: telemetryMessage.environmentMetrics.relativeHumidity))
				telemetry.temperature = telemetryMessage.environmentMetrics.hasTemperature.then(NSNumber(value: telemetryMessage.environmentMetrics.temperature))
				telemetry.current = telemetryMessage.environmentMetrics.hasCurrent.then(NSNumber(value: telemetryMessage.environmentMetrics.current))
				telemetry.voltage = telemetryMessage.environmentMetrics.hasVoltage.then(NSNumber(value: telemetryMessage.environmentMetrics.voltage))
				telemetry.weight = telemetryMessage.environmentMetrics.hasWeight.then(NSNumber(value: telemetryMessage.environmentMetrics.weight))
				telemetry.distance = telemetryMessage.environmentMetrics.hasDistance.then(NSNumber(value: telemetryMessage.environmentMetrics.distance))
				telemetry.windSpeed = telemetryMessage.environmentMetrics.hasWindSpeed.then(NSNumber(value: telemetryMessage.environmentMetrics.windSpeed))
				telemetry.windGust = telemetryMessage.environmentMetrics.hasWindGust.then(NSNumber(value: telemetryMessage.environmentMetrics.windGust))
				telemetry.windLull = telemetryMessage.environmentMetrics.hasWindLull.then(NSNumber(value: telemetryMessage.environmentMetrics.windLull))
				telemetry.windDirection = telemetryMessage.environmentMetrics.hasWindDirection.then(NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.environmentMetrics.windDirection)))
				telemetry.irLux = telemetryMessage.environmentMetrics.hasIrLux.then(NSNumber(value: telemetryMessage.environmentMetrics.irLux))
				telemetry.lux = telemetryMessage.environmentMetrics.hasLux.then(NSNumber(value: telemetryMessage.environmentMetrics.lux))
				telemetry.whiteLux = telemetryMessage.environmentMetrics.hasWhiteLux.then(NSNumber(value: telemetryMessage.environmentMetrics.whiteLux))
				telemetry.uvLux = telemetryMessage.environmentMetrics.hasUvLux.then(NSNumber(value: telemetryMessage.environmentMetrics.uvLux))
				telemetry.radiation = telemetryMessage.environmentMetrics.hasRadiation.then(NSNumber(value: telemetryMessage.environmentMetrics.radiation))
				telemetry.rainfall1H = telemetryMessage.environmentMetrics.hasRainfall1H.then(NSNumber(value: telemetryMessage.environmentMetrics.rainfall1H))
				telemetry.rainfall24H = telemetryMessage.environmentMetrics.hasRainfall24H.then(NSNumber(value: telemetryMessage.environmentMetrics.rainfall24H))
				telemetry.soilTemperature = telemetryMessage.environmentMetrics.hasSoilTemperature.then(NSNumber(value: telemetryMessage.environmentMetrics.soilTemperature))
				telemetry.soilMoisture = telemetryMessage.environmentMetrics.hasSoilMoisture.then(NSNumber(value: telemetryMessage.environmentMetrics.soilMoisture))
				telemetry.metricsType = 1
			} else if telemetryMessage.variant == Telemetry.OneOf_Variant.localStats(telemetryMessage.localStats) {
				// Local Stats, for the Mesh Status widget and Live Activity
				telemetry.uptimeSeconds = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.uptimeSeconds))
				telemetry.channelUtilization = NSNumber(value: telemetryMessage.localStats.channelUtilization)
				telemetry.airUtilTx = NSNumber(value: telemetryMessage.localStats.airUtilTx)
				telemetry.numPacketsTx = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numPacketsTx))
				telemetry.numPacketsRx = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numPacketsRx))
				telemetry.numPacketsRxBad = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numPacketsRxBad))
				telemetry.numRxDupe = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numRxDupe))
				telemetry.numTxRelay = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numTxRelay))
				telemetry.numTxRelayCanceled = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numTxRelayCanceled))
				telemetry.numOnlineNodes = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numOnlineNodes))
				telemetry.numTotalNodes = NSNumber(value: Int32(truncatingIfNeeded: telemetryMessage.localStats.numTotalNodes))
				// `noise_floor` is a plain proto3 scalar (not `optional`), so it has no
				// presence tracking — firmware that doesn't report it is indistinguishable
				// from a literal 0. Real LoRa noise floors are always strongly negative, so
				// we treat 0 as "not available" (nil). If true nil-vs-0 is ever needed, make
				// the field `optional` upstream and use `hasNoiseFloor`.
				telemetry.noiseFloor = telemetryMessage.localStats.noiseFloor != 0 ? NSNumber(value: telemetryMessage.localStats.noiseFloor) : nil
				telemetry.metricsType = 4
				Logger.statistics.debug("📈 [Mesh Statistics] Channel Utilization: \(telemetryMessage.localStats.channelUtilization, privacy: .public) Airtime: \(telemetryMessage.localStats.airUtilTx, privacy: .public) Packets Sent: \(telemetryMessage.localStats.numPacketsTx, privacy: .public) Packets Received: \(telemetryMessage.localStats.numPacketsRx, privacy: .public) Bad Packets Received: \(telemetryMessage.localStats.numPacketsRxBad, privacy: .public) Noise Floor: \(telemetryMessage.localStats.noiseFloor, privacy: .public) Nodes Online: \(telemetryMessage.localStats.numOnlineNodes, privacy: .public) of \(telemetryMessage.localStats.numTotalNodes, privacy: .public) nodes for Node: \(packet.from.toHex(), privacy: .public)")
			} else if telemetryMessage.variant == Telemetry.OneOf_Variant.powerMetrics(telemetryMessage.powerMetrics) {
				Logger.data.debug("📈 [Telemetry] Power Metrics Received for Node: \(packet.from.toHex(), privacy: .public)")
				telemetry.powerCh1Voltage = telemetryMessage.powerMetrics.hasCh1Voltage.then(NSNumber(value: telemetryMessage.powerMetrics.ch1Voltage))
				telemetry.powerCh1Current = telemetryMessage.powerMetrics.hasCh1Current.then(NSNumber(value: telemetryMessage.powerMetrics.ch1Current))
				telemetry.powerCh2Voltage = telemetryMessage.powerMetrics.hasCh2Voltage.then(NSNumber(value: telemetryMessage.powerMetrics.ch2Voltage))
				telemetry.powerCh2Current = telemetryMessage.powerMetrics.hasCh2Current.then(NSNumber(value: telemetryMessage.powerMetrics.ch2Current))
				telemetry.powerCh3Voltage = telemetryMessage.powerMetrics.hasCh3Voltage.then(NSNumber(value: telemetryMessage.powerMetrics.ch3Voltage))
				telemetry.powerCh3Current = telemetryMessage.powerMetrics.hasCh3Current.then(NSNumber(value: telemetryMessage.powerMetrics.ch3Current))
				telemetry.metricsType = 2
			} else if telemetryMessage.variant == Telemetry.OneOf_Variant.airQualityMetrics(telemetryMessage.airQualityMetrics) {
				// Air Quality Metrics — particulate matter (µg/m³). Issue #2040 / design#54.
				Logger.data.debug("📈 [Telemetry] Air Quality Metrics Received for Node: \(packet.from.toHex(), privacy: .public)")
				telemetry.pm10Standard = telemetryMessage.airQualityMetrics.hasPm10Standard.then(NSNumber(value: telemetryMessage.airQualityMetrics.pm10Standard))
				telemetry.pm25Standard = telemetryMessage.airQualityMetrics.hasPm25Standard.then(NSNumber(value: telemetryMessage.airQualityMetrics.pm25Standard))
				telemetry.pm100Standard = telemetryMessage.airQualityMetrics.hasPm100Standard.then(NSNumber(value: telemetryMessage.airQualityMetrics.pm100Standard))
				telemetry.pm10Environmental = telemetryMessage.airQualityMetrics.hasPm10Environmental.then(NSNumber(value: telemetryMessage.airQualityMetrics.pm10Environmental))
				telemetry.pm25Environmental = telemetryMessage.airQualityMetrics.hasPm25Environmental.then(NSNumber(value: telemetryMessage.airQualityMetrics.pm25Environmental))
				telemetry.pm100Environmental = telemetryMessage.airQualityMetrics.hasPm100Environmental.then(NSNumber(value: telemetryMessage.airQualityMetrics.pm100Environmental))
				telemetry.metricsType = 3
			}
			telemetry.snr = NSNumber(value: packet.rxSnr)
			telemetry.rssi = NSNumber(value: packet.rxRssi)
			// Prefer the sensor's self-reported time, then our receive time, then now — so a remote
			// node reporting time == 0 (no RTC/GPS) never stores as 1970 and gets hidden by the node
			// detail's "latest" sort and the 7-day chart window.
			telemetry.time = resolveTimestamp(telemetryMessage.time, packet.rxTime) as NSDate
			// Link by node number, not through `nodeTelemetry`: setting the relationship makes
			// SwiftData load every telemetry row this node has to update its inverse array.
			telemetry.nodeNum = packetFrom

			// Keep telemetry bounded as a soft cap during bursts; counting
			// and sorting every telemetry packet does not scale on large meshes.
			let metricsType = telemetry.metricsType
			let nodeNum = packetFrom
			if shouldPruneTelemetryHistory(nodeNum: nodeNum, metricsType: metricsType) {
				let countRequest = makeCountRequest(for: TelemetryEntity.self, predicate: TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType))
				let currentCount = (try? fetchCount(countRequest)) ?? 0
				if currentCount > MeshPackets.maxTelemetryPerType {
					let excess = currentCount - MeshPackets.maxTelemetryPerType
					var pruneRequest = makeFetchRequest(for: TelemetryEntity.self, predicate: TelemetryEntity.predicate(forNode: nodeNum, metricsType: metricsType), sortDescriptors: [NSSortDescriptor(key: "time", ascending: true)], fetchLimit: excess)
					let toDelete = (try? fetch(pruneRequest)) ?? []
					for old in toDelete {
						modelContext.delete(old)
					}
				}
			}

			// lastHeard for remote nodes is set centrally in updateAnyPacketFrom, which guards out our
			// own connected node — refresh that one here. It also only updates nodes that already
			// existed when it ran, so a node we just minted from this telemetry packet would have a
			// nil lastHeard (reads as never-heard until the next packet); backfill that case too.
			if connectedNode == Int64(packet.from) || node.lastHeard == nil {
				node.lastHeard = resolveTimestamp(packet.rxTime)
			}
			scheduleDebouncedSave()
			Logger.data.debug("📈 [TelemetryEntity] of type \(MetricsTypes(rawValue: Int(telemetry.metricsType))?.name ?? "Unknown Metrics Type", privacy: .public) buffered for Node: \(packet.from.toHex(), privacy: .public)")
			if telemetry.metricsType == 0 {
				// Connected Device Metrics
				// ------------------------
				// Low Battery notification
				if connectedNode == Int64(packet.from) {
					// The Live Activity shows the radio's battery; hand it over as a plain
					// value, since the broker only rebuilds on other events.
					if let liveActivityBattery = telemetry.batteryLevel?.int32Value {
						// The radio it came from travels with it, so a radio switch before
						// the hop can't pin this reading on the new radio.
						let batteryRadioNum = connectedNode
						Task { @MainActor in
							MeshLiveActivityManager.shared.radioBatteryDidUpdate(liveActivityBattery, radioNum: batteryRadioNum)
						}
					}
					let batteryLevel = telemetry.batteryLevel?.int32Value ?? 0
					if UserDefaults.lowBatteryNotifications && batteryLevel > 0 && batteryLevel < 4 {
						// Only when the notification will actually fire: snapshot plain values from the
						// SwiftData-backed telemetry/relationships before the MainActor hop, so the
						// deferred Task can't read these context-bound models after they've been
						// invalidated (the same pattern the text-message path follows). Gating first also
						// avoids faulting the user relationship and running the formatter on every packet.
						let notificationID = "notification.lowbattery.\(packet.from)"
						let shortName = node.user?.shortName ?? "UNK"
						let batteryText = telemetry.batteryLevel?.stringValue ?? Constants.nilValueIndicator
						let nodeNum = node.num
						Task {@MainActor in
							let manager = LocalNotificationManager()
							manager.notifications = [
								Notification(
									id: notificationID,
									title: "Critically Low Battery!",
									subtitle: "AKA \(shortName)",
									content: "Time to charge your radio, there is \(batteryText)% battery remaining.",
									target: "nodes",
									path: "meshtastic:///nodes?nodenum=\(nodeNum)"
								)
							]
							manager.schedule()
						}
					}
				}
			} else if telemetry.metricsType == 4 {
				// Hand the connected radio's LocalStats to the widget snapshot as
				// plain values — the broker runs on the main actor and must not
				// hold this context-bound entity across the hop. Guarded to the
				// connected node like the device-metrics branch above: relayed
				// LocalStats from other nodes are not our radio's counters.
				if connectedNode == Int64(packet.from) {
					let statsNodeNum = connectedNode
					let widgetStats = LocalStatsSnapshot(
						statsAt: telemetry.time ?? Date(),
						uptimeSeconds: telemetry.uptimeSeconds?.int32Value,
						channelUtilization: telemetry.channelUtilization?.floatValue,
						airUtilTx: telemetry.airUtilTx?.floatValue,
						packetsSent: telemetry.numPacketsTx,
						packetsReceived: telemetry.numPacketsRx,
						packetsReceivedBad: telemetry.numPacketsRxBad,
						packetsReceivedDupe: telemetry.numRxDupe,
						packetsRelayed: telemetry.numTxRelay,
						packetsRelayCanceled: telemetry.numTxRelayCanceled,
						nodesOnline: telemetry.numOnlineNodes,
						nodesTotal: telemetry.numTotalNodes
					)
					Task { @MainActor in
						WidgetDataBroker.shared.updateLocalStats(widgetStats, nodeNum: statsNodeNum)
					}
				}
			}
		} else {
			Logger.data.error("💥 Error Decoding Telemetry payload for Node \(packet.from.toHex(), privacy: .public)")
		}
	}

	/// Builds the notification body for a received tapback/reaction, or returns `nil` when the
	/// reacted-to message isn't known locally (a "phantom" tapback). The reaction is still stored
	/// as it is today — we just don't surface a notification for something there's nothing to show
	/// for, matching Android's guard (`MeshDataHandlerImpl.rememberReaction`).
	///
	/// Made `static` and context-injected (rather than reading `self.modelContext`) so the
	/// phantom-tapback guard and body formatting can be exercised directly in unit tests.
	static func reactionNotificationBody(replyID: Int64, emoji: String?, senderName: String, context: NSManagedObjectContext) -> String? {
		guard replyID > 0 else { return nil }
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		request.predicate = NSPredicate(format: "messageId == %lld", replyID)
		request.fetchLimit = 1
		guard let original = try? context.fetch(request).first else { return nil }
		let originalText = original.messagePayload ?? ""
		let reactionEmoji = (emoji?.isEmpty == false) ? emoji! : "❤️"
		// Mirrors how iMessage phrases a tapback notification ("Name liked …").
		return String.localizedStringWithFormat(
			"%1$@ reacted %2$@ to \"%3$@\"".localized,
			senderName, reactionEmoji, originalText
		)
	}

	/// Builds a message/reaction local notification from a (context-bound) `MessageEntity`,
	/// synchronously, so callers can hand the resulting value to a deferred `@MainActor` Task
	/// without capturing the entity itself. Collapses the DM/channel × regular/reaction variants
	/// that differ only in `content`, deep-link `path`, and `userNum`.
	///
	/// `replyMessageId` is the message that tapback/reply notification actions should target. It
	/// defaults to `message.messageId`, but for a reaction notification the caller passes the
	/// original (reacted-to) message id so actions act on that message rather than the reaction
	/// packet (which `messageId` — used for notification cancellation — must keep referencing).
	private func makeMessageNotification(
		message: MessageEntity,
		content: String,
		path: String,
		userNum: Int64?,
		critical: Bool,
		replyMessageId: Int64? = nil
	) -> Notification {
		var notification = Notification(
			id: ("notification.id.\(message.messageId)"),
			title: "\(message.fromUser?.longName ?? "Unknown".localized)",
			subtitle: "AKA \(message.fromUser?.shortName ?? "?")",
			content: content,
			target: "messages",
			path: path,
			messageId: message.messageId,
			replyMessageId: replyMessageId ?? message.messageId,
			channel: message.channel,
			userNum: userNum,
			critical: critical
		)
		#if os(iOS) && !targetEnvironment(macCatalyst)
		notification.senderIntent = CarPlayIntentDonation.incomingMessageIntent(from: message)
		#endif
		return notification
	}

	func textMessageAppPacket(
		packet: MeshPacket,
		wantRangeTestPackets: Bool,
		critical: Bool = false,
		connectedNode: Int64,
		storeForward: Bool = false,
		appState: AppState?
	) async {
		var messageText = String(bytes: packet.decoded.payload, encoding: .utf8)
		let rangeTestRegex = try! NSRegularExpression(pattern: "seq \\d+")
		let rangeTest = (messageText?.range(of: "seq ") != nil) && (messageText?.contains(rangeTestRegex) ?? false)

		if !wantRangeTestPackets && rangeTest {
			return
		}
		var storeForwardBroadcast = false
		// The identity of the message being replayed. A router gives each replay a fresh
		// outer packet id and carries the original in `original_id`, so that is what the
		// message is stored and deduped under. Zero means a router that still reuses the
		// outer id, where the outer id is the identity.
		var storeForwardOriginalId: UInt32 = 0
		if storeForward {
				if let storeAndForwardMessage = try? StoreAndForward(serializedBytes: packet.decoded.payload) {
					messageText = String(bytes: storeAndForwardMessage.text, encoding: .utf8)
					if storeAndForwardMessage.rr == .routerTextBroadcast {
						storeForwardBroadcast = true
					}
					if storeAndForwardMessage.rr == .routerTextBroadcast || storeAndForwardMessage.rr == .routerTextDirect {
						storeForwardOriginalId = storeAndForwardMessage.originalID
					}
				}
			}

			if messageText?.count ?? 0 > 0 {
				// Detection-sensor and alert events ride the text-message port; label them
				// distinctly in the stream.
				let messageLabel: String
				switch packet.decoded.portnum {
				case .detectionSensorApp: messageLabel = "🔔 [Detection Sensor]"
				case .alertApp:           messageLabel = "🔔 [Alert]"
				default:                  messageLabel = "💬 [Text Message]"
				}
				// A store-and-forward router broadcast is addressed to the local node yet is a channel
				// broadcast everywhere else (toUser == nil, shield shown), so classify it as a broadcast
				// here too rather than treating it as a DM.
				let isBroadcastMessage = packet.to == Constants.maximumNodeNum || storeForwardBroadcast
				// Show channel/broadcast text in the stream; redact direct-message content (only
				// mark it "(DM)") so private 1:1 text isn't persisted to the unified log.
				let messageDetail: String
				if isBroadcastMessage {
					let preview = (messageText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
					messageDetail = preview.count > 100 ? String(preview.prefix(100)) + "…" : preview
				} else {
					messageDetail = "(DM)"
				}
				Logger.mesh.info("\(messageLabel, privacy: .public) packet received from \(packet.from.toHex(), privacy: .public) — \(messageDetail, privacy: .public)")
				let toNum = Int64(packet.to)
				let fromNum = Int64(packet.from)
				let userRequest = makeFetchRequest(for: UserEntity.self, predicate: NSPredicate(format: "num == %lld OR num == %lld", toNum, fromNum))
				do {
					let fetchedUsers = try fetch(userRequest)

					// Dedupe: if we already have a row with this messageId, skip re-ingestion.
					// messageId is @Attribute(.unique), so without this guard the radio echo
					// upserts onto the row sendMessage() wrote, resetting read/ACK state and
					// triggering a phantom notification. Mirrors Android's
					// findPacketsWithId(dataPacket.id) guard in rememberDataPacket.
					// A replay stores under the message it replays, so a second replay — and a
					// replay of something already received live — lands on this row instead of
					// inserting another one.
					let packetId = Int64(storeForwardOriginalId != 0 ? storeForwardOriginalId : packet.id)
					let existingRequest = makeFetchRequest(for: MessageEntity.self, predicate: NSPredicate(format: "messageId == %lld", packetId))
					existingRequest.fetchLimit = 1
					if let existing = try? fetch(existingRequest), !existing.isEmpty {
						Logger.data.debug("Skipping duplicate text message, messageId \(packetId, privacy: .public) already stored")
						return
					}

					// Self-originated: the radio echoes our own transmissions back to the phone.
					// Android marks these read = fromLocal; we go further and also suppress the
					// notification (Android's handlePacketNotification has no fromLocal guard and
					// relies on dedupe alone, but that still fires for S&F replays of our own
					// messages that were never locally stored).
					let isFromSelf = Int64(packet.from) == connectedNode

					let newMessage = MessageEntity(context: modelContext)
					newMessage.messageId = packetId
					if packet.rxTime > 0 {
						newMessage.messageTimestamp = Int32(bitPattern: packet.rxTime)
					} else {
						newMessage.messageTimestamp = Int32(Date().timeIntervalSince1970)
					}
					if packet.relayNode != 0 {
						newMessage.relayNode = Int64(packet.relayNode)
					}
					newMessage.receivedACK = false
					newMessage.snr = packet.rxSnr
					newMessage.rssi = packet.rxRssi
					newMessage.isEmoji = packet.decoded.emoji == 1
					newMessage.channel = Int32(truncatingIfNeeded: packet.channel)
					newMessage.portNum = Int32(packet.decoded.portnum.rawValue)
					/// Radio-verified XEdDSA signature for this received broadcast. Firmware only sets this on
					/// broadcasts, but gate on the broadcast classification too so the "verified" shield can
					/// never appear on a DM even if a stray/spoofed packet carries the flag. `isBroadcastMessage`
					/// (computed above) also covers store-and-forward router broadcasts, which are addressed
					/// to the local node yet treated as channel broadcasts (toUser == nil).
					newMessage.xeddsaSigned = packet.xeddsaSigned && isBroadcastMessage
					// Mark read when: (a) it's our own message (self-echo or S&F replay), OR
					// (b) it's a detection-sensor with notifications disabled. These conditions
					// are OR'd so neither path can accidentally clear the other.
					if isFromSelf {
						newMessage.read = true
					}
					if packet.decoded.portnum == PortNum.detectionSensorApp {
						if !UserDefaults.enableDetectionNotifications {
							newMessage.read = true
						}
					}
					if packet.decoded.replyID > 0 {
						newMessage.replyID = Int64(packet.decoded.replyID)
					}
					// Updated logic for handling toUser
					if fetchedUsers.first(where: { $0.num == packet.to }) != nil && packet.to != Constants.maximumNodeNum {
						if !storeForwardBroadcast {
							newMessage.toUser = fetchedUsers.first(where: { $0.num == packet.to })
						} else if storeForwardBroadcast {
							// For S&F broadcast messages, treat as a channel message (not a DM)
							newMessage.toUser = nil
						} else {
							do {
								let newUser = try createUser(num: Int64(truncatingIfNeeded: packet.to), context: modelContext)
								newMessage.toUser = newUser
							} catch PersistenceError.invalidInput(let message) {
								Logger.data.error("Error Creating a new UserEntity (Invalid Input) from node number: \(packet.to, privacy: .public) Error:  \(message, privacy: .public)")
							} catch {
								Logger.data.error("Error Creating a new UserEntity from node number: \(packet.to, privacy: .public) Error:  \(error.localizedDescription, privacy: .public)")
							}
						}
					}
					if fetchedUsers.first(where: { $0.num == packet.from }) != nil {
						newMessage.fromUser = fetchedUsers.first(where: { $0.num == packet.from })
						/// Set the public key for the message
						if newMessage.fromUser?.pkiEncrypted ?? false && packet.pkiEncrypted {
							newMessage.pkiEncrypted = true
							newMessage.publicKey = packet.publicKey
						}

						/// Check for key mismatch
						if let nodeKey = newMessage.fromUser?.publicKey {
							if newMessage.toUser != nil && packet.pkiEncrypted && !packet.publicKey.isEmpty {
								if nodeKey != newMessage.publicKey {
									newMessage.fromUser?.keyMatch = false
									newMessage.fromUser?.newPublicKey = newMessage.publicKey
									let nodeKey = String(nodeKey.base64EncodedString()).prefix(8)
									let messageKey = String(newMessage.publicKey?.base64EncodedString() ?? "No Key").prefix(8)
									Logger.data.error("🔑 Key mismatch original key: \(nodeKey, privacy: .public) . . . new key: \(messageKey, privacy: .public) . . .")
								}
							}
						} else if packet.pkiEncrypted {
							/// We have no key, set it if it is not empty
							if !packet.publicKey.isEmpty {
								newMessage.fromUser?.pkiEncrypted = true
								newMessage.fromUser?.publicKey = packet.publicKey
							}
						}
					} else {
						/// Make a new from user if they are unknown
						do {
							let newUser = try createUser(num: Int64(truncatingIfNeeded: packet.from), context: modelContext)
							// Reuse an existing NodeInfoEntity if present to avoid creating duplicates
							let existingNodeRequest = makeFetchRequest(for: NodeInfoEntity.self, predicate: NSPredicate(format: "num == %lld", fromNum))
							let existingNodes = try fetch(existingNodeRequest)
							if let existingNode = existingNodes.first {
								existingNode.user = newUser
							} else {
								// findOrCreateNode, not a bare insert: num is @Attribute(.unique) and
								// the fetch above sees only saved rows — a crafted TEXT/NODEINFO pair
								// from a new node could otherwise double-insert and trap on save.
								let newNode = findOrCreateNode(num: Int64(newUser.num), context: modelContext)
								newNode.id = Int64(newUser.num)
								newNode.num = Int64(newUser.num)
								newNode.user = newUser
							}
							newMessage.fromUser = newUser
						} catch PersistenceError.invalidInput(let message) {
							Logger.data.error("Error Creating a new UserEntity (Invalid Input) from node number: \(packet.from, privacy: .public) Error:  \(message, privacy: .public)")
						} catch {
							Logger.data.error("Error Creating a new UserEntity from node number: \(packet.from, privacy: .public) Error:  \(error.localizedDescription, privacy: .public)")
						}
					}
					// Keep this write: a first-time sender's node is created here, a path
					// updateAnyPacketFrom (existing remote nodes only) doesn't cover.
					if packet.rxTime > 0 {
						newMessage.fromUser?.userNode?.lastHeard = Date(timeIntervalSince1970: TimeInterval(Int64(packet.rxTime)))
					} else {
						newMessage.fromUser?.userNode?.lastHeard = Date()
					}
					newMessage.messagePayload = messageText
					newMessage.messagePayloadMarkdown = generateMessageMarkdown(message: messageText!)
					if packet.to != Constants.maximumNodeNum && newMessage.fromUser != nil {
						newMessage.fromUser?.lastMessage = Date()
					}
					var messageSaved = false
					do {
						if modelContext.hasChanges {
							try modelContext.save()
						}
						Logger.data.debug("💾 Saved a new message for \(newMessage.messageId, privacy: .public)")
						messageSaved = true

						// Keep message storage bounded without scanning the whole table
						// after every incoming text.
						if shouldPruneMessageHistory() {
							let countRequest = makeCountRequest(for: MessageEntity.self)
							let totalMessages = (try? fetchCount(countRequest)) ?? 0
							if totalMessages > MeshPackets.maxTotalMessages {
								var oldestRequest = makeFetchRequest(for: MessageEntity.self, sortDescriptors: [NSSortDescriptor(key: "messageTimestamp", ascending: true)], fetchLimit: totalMessages - MeshPackets.maxTotalMessages)
								if let oldMessages = try? fetch(oldestRequest) {
									for old in oldMessages {
										modelContext.delete(old)
									}
									try modelContext.save()
									Logger.data.info("🗑️ Pruned \(oldMessages.count) old messages (cap: \(MeshPackets.maxTotalMessages))")
								}
							}
						}
					} catch {
						Logger.data.error("💥 Failed to save new MessageEntity: \(error.localizedDescription, privacy: .public)")
					}
					// Send notifications if the message saved properly to core data
					if messageSaved {
						// Donate to SiriKit so the message appears in CarPlay Messages
						// (CarPlay is iPhone-only, so skip on Mac Catalyst).
						#if os(iOS) && !targetEnvironment(macCatalyst)
						CarPlayIntentDonation.donateReceivedMessage(newMessage)
						#endif

						// Let the message lists and unread-displaying surfaces refresh. The message
						// was saved directly above, not through savePendingChanges, so post now
						// instead of waiting for the next save.
						postMessageChange()

						// Self-originated messages and muted detection-sensor packets skip
						// all notification work (no badge recount, no local notification).
						if isFromSelf {
							return
						}
						if packet.decoded.portnum == PortNum.detectionSensorApp && !UserDefaults.enableDetectionNotifications {
							return
						}
						if newMessage.fromUser != nil && newMessage.toUser != nil {
							// Set Unread Message Indicators. unreadMessages is O(unread); like the
							// channel badge, recomputing it for every incoming DM turns a burst into
							// quadratic work, so it gets the same ~1/sec rate limit.
							if packet.to == connectedNode, shouldRecomputeDirectUnread() {
								let unreadCount = await newMessage.toUser?.unreadMessages(context: modelContext, skipLastMessageCheck: true) ?? 0 // skipLastMessageCheck=true because we don't update lastMessage on our own connected node
								Task { @MainActor in
									appState?.unreadDirectMessages = unreadCount
								}
							}
							if !(newMessage.fromUser?.mute ?? false) {
								// Build the notification from the model objects now, while this context is valid,
								// and capture only the resulting value — a deferred Task must not hold `newMessage`
								// (a context-bound model), since a device switch can reset this context first
								// ("destroyed by ModelContext.reset").
								let senderName = newMessage.fromUser?.longName ?? "Unknown".localized
								let dmUserNum = Int64(packet.from)
								var dmNotification: Notification?
								if newMessage.isEmoji == false {
									let notificationPath = packet.decoded.portnum == PortNum.detectionSensorApp
										? "meshtastic:///nodes?nodenum=\(dmUserNum)"
										: "meshtastic:///messages?userNum=\(newMessage.fromUser?.num ?? 0)&messageId=\(newMessage.messageId)"
									dmNotification = makeMessageNotification(
										message: newMessage,
										content: messageText!,
										path: notificationPath,
										userNum: dmUserNum,
										critical: critical
									)
								} else if let reactionBody = MeshPackets.reactionNotificationBody(replyID: newMessage.replyID, emoji: messageText, senderName: senderName, context: modelContext) {
									// Tapback/reaction: follows the same notification rules as the message it
									// reacts to, and only notifies when the reacted-to message is known locally.
									// A "phantom" tapback (replyID with no matching local message) is stored but not
									// surfaced — reactionNotificationBody returns nil in that case.
									dmNotification = makeMessageNotification(
										message: newMessage,
										content: reactionBody,
										path: "meshtastic:///messages?userNum=\(newMessage.fromUser?.num ?? 0)&messageId=\(newMessage.replyID)",
										userNum: dmUserNum,
										critical: critical,
										replyMessageId: newMessage.replyID
									)
								}
								if let notification = dmNotification {
									let scheduler = notificationScheduler
									Task {@MainActor in
										scheduler([notification])
										Logger.services.debug("iOS Notification Scheduled for direct message from \(senderName, privacy: .public)")
									}
								}
							}
						} else if newMessage.fromUser != nil && newMessage.toUser == nil {
							let myInfoRequest = makeFetchRequest(for: MyInfoEntity.self, predicate: NSPredicate(format: "myNodeNum == %lld", connectedNode))
							do {
								let fetchedMyInfo = try fetch(myInfoRequest)
								if let myInfo = fetchedMyInfo.first {
									// Snapshot everything off this context NOW, synchronously, and capture only
									// plain values into the deferred Task. The entity (and `newMessage`) must not
									// cross the hop: a device switch can reset this context before the Task runs,
									// which traps with "destroyed by ModelContext.reset" on access.
									//
									// unreadMessages is O(unread); recomputing it for the badge on every incoming
									// channel message is quadratic over a burst and stalls slower devices. Throttle
									// to ~1/sec — the badge tolerates brief lag and resyncs on app-active and on read.
									let recountUnread = shouldRecomputeChannelUnread()
									let connectedNodeNum = connectedNode
									let channelNotificationsEnabled = UserDefaults.channelMessageNotifications
										&& !(newMessage.fromUser?.mute ?? false)
										&& myInfo.channels.contains(where: { $0.index == newMessage.channel && !$0.mute })
									// A message that @mentions the local node notifies even when channel
									// notifications are off or the channel is muted; a muted sender still wins.
									let isSelfMentioned = !(newMessage.fromUser?.mute ?? false)
										&& MentionParser.containsMention(of: connectedNode, in: messageText ?? "")
									let senderName = newMessage.fromUser?.longName ?? "Unknown".localized
									let channelUserNum = Int64(newMessage.fromUser?.userId ?? "0")
									var channelNotification: Notification?
									if channelNotificationsEnabled || isSelfMentioned {
										if newMessage.isEmoji == false {
											channelNotification = makeMessageNotification(
												message: newMessage,
												content: messageText!,
												path: "meshtastic:///messages?channelId=\(newMessage.channel)&messageId=\(newMessage.messageId)",
												userNum: channelUserNum,
												critical: critical
											)
										} else if let reactionBody = MeshPackets.reactionNotificationBody(replyID: newMessage.replyID, emoji: messageText, senderName: senderName, context: modelContext) {
											// Tapback/reaction: follows the channel-notification rules above, and
											// only notifies when the reacted-to message is known locally. A
											// "phantom" tapback is stored but not surfaced — the helper returns nil
											// in that case, per Android's guard.
											channelNotification = makeMessageNotification(
												message: newMessage,
												content: reactionBody,
												path: "meshtastic:///messages?channelId=\(newMessage.channel)&messageId=\(newMessage.replyID)",
												userNum: channelUserNum,
												critical: critical,
												replyMessageId: newMessage.replyID
											)
										}
									}
									let notification = channelNotification
									let scheduler = notificationScheduler
									Task {@MainActor in
										if recountUnread {
											// Recompute the badge against a freshly re-fetched, live main-context
											// entity (unreadMessages is @MainActor); never touch the captured
											// MeshPackets entity, which a device switch may have invalidated.
											let mainContext = CoreDataStackImpl.shared.context
											let liveRequest = NSFetchRequest<MyInfoEntity>(entityName: "MyInfoEntity")
											liveRequest.predicate = NSPredicate(format: "myNodeNum == %lld", connectedNodeNum)
											liveRequest.fetchLimit = 1
											if let liveMyInfo = try? mainContext.fetch(liveRequest).first {
												appState?.unreadChannelMessages = liveMyInfo.unreadMessages(context: mainContext)
											}
										}
										if let notification {
											scheduler([notification])
											Logger.services.debug("iOS Notification Scheduled for channel text message")
										}
									}
								}
							} catch {
								// Handle error
							}
						}
					}
			} catch {
				Logger.data.error("Fetch Message To and From Users Error")
			}
		}
	}

	func waypointPacket (packet: MeshPacket) {
		let waypointDetail = (try? Waypoint(serializedBytes: packet.decoded.payload)).map { w -> String in
			var parts: [String] = []
			let name = w.name.trimmingCharacters(in: .whitespacesAndNewlines)
			if !name.isEmpty { parts.append(name) }
			if w.latitudeI != 0 || w.longitudeI != 0 {
				parts.append(String(format: "%.5f,%.5f", Double(w.latitudeI) / 1e7, Double(w.longitudeI) / 1e7))
			}
			return parts.isEmpty ? "" : " — " + parts.joined(separator: " ")
		} ?? ""
		Logger.mesh.info("[Waypoint] packet received from \(packet.from.toHex(), privacy: .public)\(waypointDetail, privacy: .public)")

		do {
			if let waypointMessage = try? Waypoint(serializedBytes: packet.decoded.payload) {
				// Fetch waypoint by waypointMessage.id, not packet.id
				let waypointId = Int64(waypointMessage.id)
				let waypointRequest = makeFetchRequest(for: WaypointEntity.self, predicate: NSPredicate(format: "id == %lld", waypointId))

				let fetchedWaypoint = try fetch(waypointRequest)
				// A local-only waypoint must never be overwritten by a mesh packet that happens to
				// share its id — ignore the incoming waypoint entirely for that id.
				if fetchedWaypoint.first?.isLocal == true { return }
				// Fetch the node info to get the short name
				var nodeShortName: String = "?"
				let packetFrom = Int64(packet.from)
				let nodeRequest = makeFetchRequest(for: NodeInfoEntity.self, predicate: NSPredicate(format: "num == %lld", packetFrom))
				do {
					let fetchedNode = try fetch(nodeRequest)
					if let node = fetchedNode.first, let user = node.user {
						nodeShortName = user.shortName ?? node.user?.userId ?? String(packet.from.toHex())
					}
				} catch {
					Logger.data.error("Failed to fetch NodeInfoEntity for node \(packet.from.toHex(), privacy: .public): \(error)")
				}
				if fetchedWaypoint.isEmpty {
					// Create a new waypoint
					let waypoint = WaypointEntity(context: modelContext)
					waypoint.id = Int64(waypointMessage.id) // Use waypointMessage.id
					waypoint.name = waypointMessage.name
					waypoint.longDescription = waypointMessage.description_p
					waypoint.latitudeI = waypointMessage.latitudeI
					waypoint.longitudeI = waypointMessage.longitudeI
					waypoint.icon = Int64(waypointMessage.icon)
					waypoint.locked = waypointMessage.lockedTo != 0
					waypoint.createdBy = Int64(packet.from)
					// Geometry only: the notify flags are receiver-local (design#114), so a
					// received waypoint never notifies unless this user opts in via WaypointForm.
					waypoint.applyGeofenceGeometry(from: waypointMessage)
					if waypointMessage.expire >= 1 {
						waypoint.expire = Date(timeIntervalSince1970: TimeInterval(Int64(waypointMessage.expire)))
					} else {
						waypoint.expire = nil
					}
					waypoint.created = Date()
					savePendingChanges()
					Logger.data.info("💾 Added Node Waypoint App Packet For: \(waypoint.id, privacy: .public)")

					if UserDefaults.waypointNotifications {
						// Build the notification from the model now, while this context is valid, and
						// capture only the resulting value — same rule as the message path: a deferred
						// Task must not hold `waypoint`, a context-bound model.
						let icon = String(UnicodeScalar(Int(waypoint.icon)) ?? "📍")
						let latitude = Double(waypoint.latitudeI) / 1e7
						let longitude = Double(waypoint.longitudeI) / 1e7
						let waypointId = waypoint.id
						let waypointName = waypoint.name ?? "Dropped Pin".localized
						let notification = Notification(
							id: ("notification.id.\(waypointId)"),
							title: String.localizedStringWithFormat("New Waypoint From %@".localized, nodeShortName),
							subtitle: "\(icon) \(waypointName)",
							content: "\(waypoint.longDescription ?? "\(latitude), \(longitude)")",
							target: "map",
							path: "meshtastic:///map?waypointid=\(waypointId)"
						)
						let scheduler = notificationScheduler
						Task { @MainActor in
							scheduler([notification])
							Logger.data.debug("meshtastic:///map?waypointid=\(waypointId, privacy: .public)")
						}
					}
				} else {
					// Update existing waypoint
					let existingWaypoint = fetchedWaypoint[0]
					if !existingWaypoint.locked {
						let currentTime = Int64(Date().timeIntervalSince1970)
						if waypointMessage.expire > 0 && waypointMessage.expire <= currentTime {
							modelContext.delete(existingWaypoint)
							savePendingChanges()
							Logger.data.info("💾 Deleted a waypoint")
						} else {
							existingWaypoint.name = waypointMessage.name
							existingWaypoint.longDescription = waypointMessage.description_p
							existingWaypoint.latitudeI = waypointMessage.latitudeI
							existingWaypoint.longitudeI = waypointMessage.longitudeI
							existingWaypoint.icon = Int64(waypointMessage.icon)
							existingWaypoint.locked = waypointMessage.lockedTo != 0
							existingWaypoint.lastUpdatedBy = Int64(packet.from)
							// Geometry only — a mesh update must never overwrite this user's
							// local notification opt-in/opt-out (design#114).
							existingWaypoint.applyGeofenceGeometry(from: waypointMessage)
							if waypointMessage.expire >= 1 {
								existingWaypoint.expire = Date(timeIntervalSince1970: TimeInterval(Int64(waypointMessage.expire)))
							} else {
								existingWaypoint.expire = nil
							}
							existingWaypoint.lastUpdated = Date()
							savePendingChanges()
							Logger.data.info("💾 Updated Node Waypoint App Packet For: \(existingWaypoint.id, privacy: .public)")
						}
					}
				}
			}
		} catch {
			Logger.mesh.error("Error Deserializing WAYPOINT_APP packet.")
		}
	}
}

extension Position {
	/// True when the position carries usable, non-placeholder coordinates.
	///
	/// Requires both components to be non-zero, matching the app-wide coordinate convention
	/// (see `PositionEntity.nodeCoordinate`): a position with one axis unset/zero is treated
	/// as "no location" and would not render, so it must not be persisted as a valid fix.
	/// The Apple Park simulator default is also rejected — but only the exact placeholder,
	/// since a real position that shares just one coordinate with Apple Park is legitimate.
	var hasValidCoordinates: Bool {
		guard latitudeI != 0, longitudeI != 0 else { return false }
		let isApplePark = latitudeI == 373346000 && longitudeI == -1220090000
		return !isApplePark
	}
}

extension NodeInfo {
	var isValidPosition: Bool {
		hasPosition && position.hasValidCoordinates
	}
}
