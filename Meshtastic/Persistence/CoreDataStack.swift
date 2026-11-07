//
//  CoreDataStack.swift
//  Meshtastic
//
//  Core Data replacement for SwiftData PersistenceController (iOS 15+ compatible).
//  Generated from MeshtasticSchemaV1 + CoreDataMigrationService entity definitions.
//

import CoreData
import OSLog
import Foundation
import UIKit

@MainActor
final class CoreDataStack {

    // MARK: - Singleton

    static let shared = CoreDataStack()
    static var preview: CoreDataStack = {
        let stack = CoreDataStack(inMemory: true)
        // Add sample data for previews if needed
        return stack
    }()

    // MARK: - Properties

    var container: NSPersistentContainer
    let storeName: String
    let inMemory: Bool

    var context: NSManagedObjectContext {
        container.viewContext
    }

    // Generation counter for container recreation (like SwiftData's containerGeneration)
    private(set) var containerGeneration = 0

    private(set) var isProvisionalPendingFirstUnlock = false

    // MARK: - Initialization

    private init(inMemory: Bool = false, storeName: String = "Meshtastic") {
        self.storeName = storeName
        self.inMemory = inMemory

        // Create model from bundled .xcdatamodeld (V58)
        let model = Self.makeManagedObjectModel()
        container = NSPersistentContainer(name: "Meshtastic", managedObjectModel: model)

        let config = NSPersistentStoreDescription()
        config.url = Self.storeURL(for: storeName, inMemory: inMemory)
        config.shouldMigrateStoreAutomatically = true
        config.shouldInferMappingModelAutomatically = true
        config.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        config.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if inMemory {
            config.type = NSInMemoryStoreType
        }

        container.persistentStoreDescriptions = [config]

        // Disable autosave - we control saves manually like SwiftData
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil

        loadStore()

        // Clean up parked files from previous sessions
        if !inMemory {
            Self.sweepParkedStoreFiles(near: config.url)
            NodeBackupManager.sweepStagedBackupDirectories()
        }
    }

    // MARK: - Store Loading

    private func loadStore() {
        let isTestEnvironment = NSClassFromString("XCTestCase") != nil
            || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

        // Guard Core Data store from being clobbered by SwiftData (if both builds exist)
        if !inMemory && !isTestEnvironment {
            CoreDataMigrationService.prepareForMigration()
        }

        var loadError: Error?
        container.loadPersistentStores { [weak self] _, error in
            loadError = error
            if let error = error {
                self?.handleLoadError(error)
            }
        }

        if let error = loadError {
            // Error already handled in handleLoadError
            return
        }

        // Post-unlock store reopen observer
        observeFirstUnlockToReopenStore()
    }

    private func handleLoadError(_ error: Error) {
        guard !inMemory else {
            Logger.data.critical("💾 CoreDataStack in-memory store failed: \(error.localizedDescription, privacy: .public)")
            return
        }

        let config = container.persistentStoreDescriptions.first
        guard let storeURL = config?.url else { return }

        // Check if it's a data protection lock (pre-first-unlock)
        if Self.storeExistsButIsUnreadable(at: storeURL) {
            Logger.data.critical("💾 Core Data store locked by data protection (pre-first-unlock). Using provisional in-memory store.")
            switchToProvisionalStore()
            return
        }

        // Corrupt store - attempt recovery
        Logger.data.critical("💾 Core Data store failed to open, attempting recovery: \(error.localizedDescription, privacy: .public)")
        parkStoreFiles(at: storeURL)

        // Retry with fresh store
        var retryError: Error?
        container.persistentStoreDescriptions = [config]
        container.loadPersistentStores { _, error in
            retryError = error
        }

        if let retryError = retryError {
            Logger.data.critical("💾 Core Data unrecoverable, falling back to in-memory: \(retryError.localizedDescription, privacy: .public)")
            switchToProvisionalStore()
        } else {
            Logger.data.warning("💾 Core Data store recreated after recovery — local data reset")
            containerGeneration &+= 1
        }
    }

    private func switchToProvisionalStore() {
        let model = container.managedObjectModel
        let provisionalContainer = NSPersistentContainer(name: "Meshtastic", managedObjectModel: model)
        let config = NSPersistentStoreDescription()
        config.type = NSInMemoryStoreType
        provisionalContainer.persistentStoreDescriptions = [config]

        var loadError: Error?
        provisionalContainer.loadPersistentStores { _, error in
            loadError = error
        }

        if let loadError = loadError {
            fatalError("💾 Provisional in-memory store failed: \(loadError.localizedDescription)")
        }

        // Replace container with provisional in-memory store
        self.container = provisionalContainer
        isProvisionalPendingFirstUnlock = true
        observeFirstUnlockToReopenStore()
    }

    private func observeFirstUnlockToReopenStore() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.protectedDataDidBecomeAvailableNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isProvisionalPendingFirstUnlock else { return }
                Logger.data.info("💾 Protected data available — reopening on-disk store")
                self.isProvisionalPendingFirstUnlock = false
                self.recreateContainer()
            }
        }
    }

    // MARK: - Container Recreation (like SwiftData's recreateContainer)

    func recreateContainer() {
        let model = Self.makeManagedObjectModel()
        let freshContainer = NSPersistentContainer(name: "Meshtastic", managedObjectModel: model)

        let config = NSPersistentStoreDescription()
        config.url = Self.storeURL(for: storeName, inMemory: inMemory)
        config.shouldMigrateStoreAutomatically = true
        config.shouldInferMappingModelAutomatically = true
        freshContainer.persistentStoreDescriptions = [config]
        freshContainer.viewContext.automaticallyMergesChangesFromParent = true
        freshContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        freshContainer.viewContext.undoManager = nil

        var loadError: Error?
        freshContainer.loadPersistentStores { _, error in
            loadError = error
        }

        if let loadError = loadError {
            Logger.data.error("💾 Failed to recreate Core Data container: \(loadError.localizedDescription, privacy: .public)")
            return
        }

        // Swap to the fresh container
        self.container = freshContainer
        containerGeneration &+= 1
        Logger.data.info("💾 Core Data container recreated (generation \(self.containerGeneration))")
    }

    // MARK: - Database Clear (like SwiftData's clearDatabase)

    func clearDatabase(includeRoutes: Bool = true) {
        let context = container.viewContext
        context.performAndWait {
            do {
                // Delete in dependency order
                let entityNames = [
                    "DeviceHardwareTagEntity",
                    "DeviceHardwareImageEntity",
                    "DeviceHardwareEntity",
                    "DeviceLinkEntity",
                    "FirmwareReleaseEntity",
                    "EventFirmwareEntity",
                    "TelemetryEntity",
                    "PaxCounterEntity",
                    "TraceRouteHopEntity",
                    "TraceRouteNodePositionEntity",
                    "TraceRouteEntity",
                    "WaypointEntity",
                    "RouteEntity",
                    "LocationEntity",
                    "NeighborLinkEntity",
                    "PositionEntity",
                    "MessageEntity",
                    "ChannelEntity",
                    "UserEntity",
                    "MyInfoEntity",
                    "NodeInfoEntity",
                    // Config entities (alphabetical)
                    "AmbientLightingConfigEntity",
                    "AudioConfigEntity",
                    "BluetoothConfigEntity",
                    "CannedMessageConfigEntity",
                    "DeviceConfigEntity",
                    "DisplayConfigEntity",
                    "ExternalNotificationConfigEntity",
                    "LoRaConfigEntity",
                    "MeshBeaconConfigEntity",
                    "BroadcastTargetEntity",
                    "MQTTConfigEntity",
                    "NeighborInfoConfigEntity",
                    "NetworkConfigEntity",
                    "PaxCounterConfigEntity",
                    "PositionConfigEntity",
                    "PowerConfigEntity",
                    "RangeTestConfigEntity",
                    "RTTTLConfigEntity",
                    "SecurityConfigEntity",
                    "SerialConfigEntity",
                    "StatusMessageConfigEntity",
                    "StoreForwardConfigEntity",
                    "TAKConfigEntity",
                    "TelemetryConfigEntity",
                    // Discovery
                    "DiscoveryPresetResultEntity",
                    "DiscoverySessionEntity",
                    "DiscoveredNodeEntity",
                    "DiscoveredBeaconEntity",
                    "DeviceMetadataEntity",
                ]

                for entityName in entityNames {
                    if !includeRoutes && (entityName == "RouteEntity" || entityName == "LocationEntity") {
                        continue
                    }
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let delete = NSBatchDeleteRequest(fetchRequest: fetch)
                    delete.resultType = .resultTypeObjectIDs
                    try context.execute(delete)
                }

                try context.save()
                Logger.data.error("Core Data database truncated. All app data erased.")
            } catch {
                Logger.data.error("Failed to clear Core Data database: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    // MARK: - Store URL Helpers

    static func storeURL(for name: String, inMemory: Bool) -> URL {
        if inMemory {
            return URL(fileURLWithPath: "/dev/null")
        }
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("\(name).sqlite")
    }

    static func storeExistsButIsUnreadable(at url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        let fd = open(url.path, O_RDONLY)
        if fd >= 0 {
            close(fd)
            return false
        }
        return true
    }

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
                try? fm.removeItem(at: src)
            }
        }
    }

    private static func sweepParkedStoreFiles(near storeURL: URL) {
        let fm = FileManager.default
        let dir = storeURL.deletingLastPathComponent()
        let prefix = storeURL.lastPathComponent + ".parked-"
        guard let names = try? fm.contentsOfDirectory(atPath: dir.path) else { return }
        for name in names where name.hasPrefix(prefix) {
            try? fm.removeItem(at: dir.appendingPathComponent(name))
        }
    }

    // MARK: - Model Creation

    /// Creates the NSManagedObjectModel from the bundled .xcdatamodeld (V58)
    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        guard let momdURL = Bundle.main.url(
            forResource: "Meshtastic",
            withExtension: "momd"
        ) else {
            fatalError("💾 Meshtastic.momd not found in bundle")
        }

        // Load V58 model explicitly (same as CoreDataMigrationService)
        let v58URL = momdURL.appendingPathComponent("MeshtasticDataModelV 58.mom")
        let modelURL: URL
        if FileManager.default.fileExists(atPath: v58URL.path) {
            modelURL = v58URL
        } else {
            modelURL = momdURL
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("💾 Failed to load Core Data model from \(modelURL.path)")
        }
        return model
    }
}

// MARK: - Core Data Entity Protocol (for type-safe fetch requests)

protocol CoreDataEntity: NSManagedObject {
    static var entityName: String { get }
}

extension CoreDataEntity {
    static var entityName: String {
        String(describing: Self.self)
    }

    static func fetchRequest() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: entityName)
    }
}

// MARK: - Convenience Extensions

extension NSManagedObjectContext {
    /// Fetch all objects of a given entity type
    func fetchAll<T: CoreDataEntity>(_ type: T.Type) throws -> [T] {
        try fetch(T.fetchRequest())
    }

    /// Fetch first object matching predicate
    func fetchFirst<T: CoreDataEntity>(_ type: T.Type, predicate: NSPredicate) throws -> T? {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        return try fetch(request).first
    }
}

import Foundation // for Logger
extension Logger {
    static let data = Logger(subsystem: "gvh.MeshtasticClient", category: "data")
}