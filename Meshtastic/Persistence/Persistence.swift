//
//  Persistence.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 11/28/21.
//

import CoreData
import OSLog
import Foundation
import UIKit

@MainActor
class PersistenceController {

	static let shared: PersistenceController = {
		let isTestEnvironment = NSClassFromString("XCTestCase") != nil || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
		return PersistenceController(inMemory: isTestEnvironment)
	}()

	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true, storeName: "MeshtasticPreview")
		let context = result.context
		for _ in 0..<10 {
			let newItem = NodeInfoEntity(context: context)
			newItem.lastHeard = Date()
		}
		try? context.save()
		return result
	}()

	/// The underlying Core Data stack implementation.
	private let coreDataStack: CoreDataStackImpl

	/// The underlying NSPersistentContainer for APIs that require direct container access.
	var container: NSPersistentContainer {
		coreDataStack.container
	}

	/// Advances synchronously with each container replacement. Long-lived view tasks capture the
	/// generation they were mounted against and stop before touching a stale `NSManagedObjectContext`.
	private(set) var containerGeneration = 0

	/// The name of the store file (without extension).
	private let storeName: String
	/// Whether the store is in-memory only.
	private let inMemory: Bool

	var context: NSManagedObjectContext {
		coreDataStack.context
	}

	/// True while `container` is a provisional, empty in-memory stand-in because the on-disk
	/// store was unreadable under data protection (the process launched in the background before
	/// the user's first unlock — Bluetooth state restoration does this after a phone reboot).
	/// The real store is untouched on disk and is reopened by `observeFirstUnlockToReopenStore()`.
	private(set) var isProvisionalPendingFirstUnlock = false

	/// Distinguishes "the store file is locked by data protection" from "the store file is corrupt".
	/// Before the first unlock, `open(2)` on a file protected with the default
	/// CompleteUntilFirstUserAuthentication class fails outright; a corrupt-but-unlocked file opens
	/// fine at the POSIX layer (its damage surfaces inside SQLite instead). Any exists-but-unopenable
	/// state is treated as locked: the cost of a false positive is one provisional in-memory session,
	/// while destructive "recovery" of a merely-locked store permanently deletes the user's data (#2243).
	nonisolated static func storeExistsButIsUnreadable(at url: URL) -> Bool {
		guard FileManager.default.fileExists(atPath: url.path) else { return false }
		let fd = open(url.path, O_RDONLY)
		if fd >= 0 {
			close(fd)
			return false
		}
		return true
	}

	init(inMemory: Bool = false, storeName: String = "Meshtastic") {
		self.storeName = storeName
		self.inMemory = inMemory
		self.coreDataStack = CoreDataStackImpl(inMemory: inMemory, storeName: storeName)

		// Sync generation and provisional state from the Core Data stack
		self.containerGeneration = coreDataStack.containerGeneration
		self.isProvisionalPendingFirstUnlock = coreDataStack.isProvisionalPendingFirstUnlock
	}

	/// Reopen the (already-migrated) store in a brand-new `NSPersistentContainer`, replacing `container`.
	///
	/// Used after a full data clear so every context — the main context and any actor contexts
	/// built from the container — starts with no stale object registrations. Without this, a
	/// long-lived context keeps the pre-clear objects registered; on reconnect SQLite reuses the
	/// freed rowids, so a fetch/relationship access returns a dead instance and Core Data traps
	/// with "This model instance was destroyed by calling ModelContext.reset".
	///
	/// Invariant: any caller that can run while the UI is in the FOREGROUND must also bump
	/// `AppState.databaseResetID` after this returns. The swap advances `containerGeneration`,
	/// which makes guarded view tasks (e.g. the Nodes refresh loop) stop fetching; only the
	/// `.id(databaseResetID)` remount re-binds them to the new container. A foreground caller
	/// that forgets the bump gets a silently frozen list, not a crash. Background-only callers
	/// (the first-unlock store reopen) are exempt because their views mount after the swap.
	func recreateContainer() {
		coreDataStack.recreateContainer()
		containerGeneration = coreDataStack.containerGeneration
		Logger.data.info("💾 Core Data container recreated after data clear")
	}

	/// Nuclear reset: delete the on-disk store files and reopen a brand-new, guaranteed-empty
	/// container. Used by the device-switch / cross-device reset paths as an escalation when the
	/// per-model `clearDatabase` fails part-way (e.g. a relationship constraint aborts the batch
	/// deletes) — proceeding on a half-cleared store is how one radio's nodes leak into another's
	/// session. POSIX unlink semantics make this safe with stragglers: any old context still
	/// holding the previous container writes to the unlinked inode, never into the new store.
	/// Not usable when data must be preserved (routes, favorites) — everything is erased.
	func destroyStoreAndRecreateContainer() {
		guard !inMemory else {
			recreateContainer()
			return
		}
		// For Core Data, we use CoreDataStackImpl
		clearDatabase(includeRoutes: true)
		Logger.data.warning("💾 Core Data store destroyed and container recreated (escalated database reset)")
	}

	/// File-swap restore: replace the on-disk store with a copy of a backup and reopen the
	/// container on top of it. The switch path must not run SwiftData saves at all —
	/// observer bridges from previous containers survive any amount of view unmounting
	/// (registration lives until dealloc and the graph retains them), and a bulk restore
	/// save's synchronous NotificationCenter callout traps inside the stale bridge
	/// regardless of thread or of what is mounted (caught live in lldb at the restore's
	/// `save()`; the no-crash-report flavor of Datadog 324bff02). Replacing the store file
	/// and reopening posts nothing. POSIX unlink semantics keep stragglers safe, as with
	/// the destroy path above; `recreateContainer()` runs the migration plan in place on
	/// the writable copy, which also covers backups written by older schemas.
	/// Rename the store files out of the way instead of deleting them — unlinking a store a
	/// leaked container still has open trips SQLite's vnode watch, which invalidates the open
	/// fds ("database integrity compromised by API violation: vnode unlinked while in use")
	/// and breaks that container and everything observing through it. (SQLite alarms on a
	/// rename too, but the destroy path is an already-broken escalation; parking at least
	/// preserves the bytes.) Parked files are orphans from this or previous sessions;
	/// `sweepParkedStoreFiles()` removes last session's on launch.
	private static func parkStoreFiles(at storeURL: URL) {
		let fm = FileManager.default
		let tag = ".parked-\(UUID().uuidString.prefix(8))"
		for suffix in ["", "-wal", "-shm"] {
			let src = URL(fileURLWithPath: storeURL.path + suffix)
			guard fm.fileExists(atPath: src.path) else { continue }
			let dst = URL(fileURLWithPath: storeURL.path + tag + suffix)
			do {
				try fm.moveItem(at: src, to: dst)
			} catch {
				Logger.data.error("💾 Failed to park store file \(src.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
				// Fall back to unlink rather than restoring on top of a stale file.
				try? fm.removeItem(at: src)
			}
		}
	}

	/// Remove parked store files left by previous sessions' node switches. Called once at
	/// launch, when nothing can still hold them open.
	private static func sweepParkedStoreFiles(near storeURL: URL) {
		let fm = FileManager.default
		let dir = storeURL.deletingLastPathComponent()
		let prefix = storeURL.lastPathComponent + ".parked-"
		guard let names = try? fm.contentsOfDirectory(atPath: dir.path) else { return }
		for name in names where name.hasPrefix(prefix) {
			try? fm.removeItem(at: dir.appendingPathComponent(name))
		}
	}

	private static func removeStoreFiles(at storeURL: URL) {
		let fm = FileManager.default
		let storeFiles = [
			storeURL,
			URL(fileURLWithPath: storeURL.path + "-shm"),
			URL(fileURLWithPath: storeURL.path + "-wal")
		]

		for url in storeFiles where fm.fileExists(atPath: url.path) {
			do {
				try fm.removeItem(at: url)
			} catch {
				Logger.data.error("📈 [PerfSeed] Failed to remove existing store file \(url.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
			}
		}
	}

	@MainActor
	public func clearDatabase(includeRoutes: Bool = true) {
		coreDataStack.clearDatabase(includeRoutes: includeRoutes)
		Logger.data.error("Core Data database truncated. All app data has been erased.")
	}
}