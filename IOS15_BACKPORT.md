# Meshtastic-Apple iOS 15 Backport Plan

## Overview
This document tracks the effort to backport Meshtastic-Apple from iOS 17.5 to iOS 15.0 (iPhone 7 compatible).

**Status**: Configuration done, source migration pending macOS build.

---

## Changes Already Made (Windows - No Build Required)

### 1. Project Configuration (`project.yml`)
- `IPHONEOS_DEPLOYMENT_TARGET`: 17.5/16.4 → **15.0**
- `SWIFT_VERSION`: 6.0 → **5.10** (last version with full iOS 15 support)
- Removed `SWIFT_STRICT_CONCURRENCY` (Swift 6 only)
- **Disabled targets** requiring iOS 16+:
  - ❌ WidgetsExtension (WidgetKit, Live Activities)
  - ❌ MeshtasticMessages (Messages Extension)
  - ❌ Meshtastic Watch App (watchOS 10+)
  - ❌ Meshtastic TV (tvOS 17+)
  - ❌ Meshtastic TVUITests
  - ❌ WidgetsExtension scheme

### 2. Core Data Stack (New Files)
| File | Purpose |
|------|---------|
| `Meshtastic/Persistence/CoreDataStack.swift` | Replaces `PersistenceController` (SwiftData → Core Data) |
| `Meshtastic/Model/CoreData/*.swift` (50 files) | `NSManagedObject` subclasses for all entities |
| `scripts/generate_coredata_entities.py` | Generator script (run to regenerate) |

### 3. Compatibility Shims (New Files)
| File | Purpose |
|------|---------|
| `Meshtastic/Extensions/NavigationStackShim.swift` | `NavigationStack` → `CompatNavigationStack` for iOS 15 |
| `Meshtastic/Extensions/ObservableObjectShim.swift` | `@Observable` → `ObservableObject` + `@Published` |

### 4. Migration Scripts
| Script | Purpose |
|--------|---------|
| `scripts/bulk_migrate_ios15.py` | Regex-based source migration (run on macOS) |

---

## Required Manual Work (On macOS)

### Phase 1: Generate Xcode Project & Verify Config
```bash
# On macOS
brew install xcodegen
xcodegen generate
open Meshtastic.xcworkspace
# Build → should fail with SwiftData/NavigationStack errors
```

### Phase 2: Run Bulk Migration Script
```bash
cd /path/to/Meshtastic-Apple
python3 scripts/bulk_migrate_ios15.py
# Review EVERY change - regex is imperfect
```

### Phase 3: Core Data Model (CRITICAL)
The generated `NSManagedObject` subclasses need a matching `.xcdatamodeld`.

**Option A: Use existing V58 model from bundle**
- The `CoreDataStack.swift` already loads `MeshtasticDataModelV 58.mom` from the bundled `.momd`
- Verify `Meshtastic.xcdatamodeld/MeshtasticDataModelV 58.xcdatamodel` exists in Xcode
- If missing: extract from old 2.7.12 build or recreate in Xcode modeler

**Option B: Recreate in Xcode Data Model Editor**
- 70+ entities, ~500 properties, ~100 relationships
- Use `CoreDataMigrationService.swift` as reference for entity definitions
- Set up inverse relationships correctly

### Phase 4: Fix @Observable Classes (Manual, ~15 classes)
Search for `@Observable` and convert each:

```swift
// BEFORE (iOS 17+)
@MainActor @Observable
final class DiscoveryScanEngine {
    var currentState = DiscoveryState.idle
    var dwellTimeRemaining: TimeInterval = 0
    func start() { ... }
}

// AFTER (iOS 15+)
@MainActor
final class DiscoveryScanEngine: ObservableObject {
    @Published var currentState = DiscoveryState.idle
    @Published var dwellTimeRemaining: TimeInterval = 0
    func start() { ... }
}
```

**Classes to migrate** (grep `@Observable`):
- `DiscoveryScanEngine` (Services/)
- `DocModels` (Views/Settings/HelpAndDocumentation/)
- `BeaconJoinPrompts` (Views/Settings/Discovery/)
- `RadioSetupModel` (Views/Onboarding/RadioSetup/)
- `SpatialMapModel` (Views/Nodes/SpatialMap/)
- `ShowcaseSceneController` (Views/Showcase/)
- `ShowcaseDisplays` (Views/Showcase/)
- `LookoutScene` (Helpers/Cinema/)
- `CinemaModelStand` (Helpers/Cinema/)
- `LookoutMarkerPanels` (Helpers/Cinema/)
- `SpatialTerrainKeeper` (Helpers/SpatialMap/)
- `DisplayMirrorSession` (Accessory/DisplayMirror/)
- `MeshClient` (Meshtastic TV/Client/)

### Phase 5: SwiftData → Core Data Queries (Massive)
Every SwiftData query must be converted:

| SwiftData | Core Data |
|-----------|-----------|
| `@Query` | `@FetchRequest` |
| `ModelContext` | `NSManagedObjectContext` |
| `ModelContainer` | `NSPersistentContainer` |
| `FetchDescriptor<Foo>` | `NSFetchRequest<Foo>(entityName: "Foo")` |
| `#Predicate { $0.name == "x" }` | `NSPredicate(format: "name == %@", "x")` |
| `context.insert(obj)` | `context.insert(obj)` |
| `context.delete(obj)` | `context.delete(obj)` |
| `try context.save()` | `try context.save()` |

**Files with heavy SwiftData usage** (grep `SwiftData\|ModelContext\|@Query`):
- All `Persistence/*.swift`
- All `Model/*.swift`
- All `Extensions/SwiftData/*.swift`
- All View files using `@Query` or `@Environment(\.modelContext)`

### Phase 6: NavigationStack → NavigationView
The `NavigationStackShim` provides `CompatNavigationStack` but:
- `NavigationLink(value:)` → `CompatNavigationLink(value:)` (limited on iOS 15)
- `.navigationDestination(for:)` → `.compatNavigationDestination(for:)` (no-op on iOS 15)
- Programmatic navigation via `NavigationPath` **does not work on iOS 15**

**Strategy**: Replace value-based navigation with explicit `NavigationLink(destination:)` or tag-based approach.

### Phase 7: Remove/Guard iOS 16+ APIs
Search and handle:
- `LiveActivity` / `Activity` / `ActivityKit` → wrap in `#available(iOS 16.1, *)`
- `WidgetKit` advanced features → wrap in `#available(iOS 16.0, *)`
- `ControlCenter` / `WidgetControls` → remove (iOS 18 only)
- `SwiftUI.Charts` → remove or use alternative
- `@Attribute(.indexed)` → use `@Attribute(.unique)` instead (per existing comment)
- `FileHandle.read(upToCount:)` → OK (iOS 15+)

### Phase 8: Dependencies Verification
Check each SPM dependency supports iOS 15:
- ✅ CocoaMQTT 2.x
- ✅ IOS-DFU-Library 4.x (Nordic supports iOS 12+)
- ✅ swift-protobuf 1.x
- ✅ swift-markdown 0.x
- ✅ SwiftDraw 0.x
- ⚠️ dd-sdk-ios 3.x - verify min deployment
- ⚠️ mvt-tools - verify
- ⚠️ opentelemetry-swift-packages - verify

---

## Estimated Effort

| Task | Effort | Risk |
|------|--------|------|
| Core Data model setup | 2-3 days | High |
| @Observable → ObservableObject | 1-2 days | Medium |
| SwiftData → Core Data queries | 2-3 weeks | Very High |
| Navigation migration | 1-2 weeks | High |
| Dependency fixes | 1-2 days | Medium |
| Testing on iPhone 7 | 1 week | High |
| **Total** | **4-6 weeks** | **Very High** |

---

## Quick Wins (Do First)
1. ✅ Config changes (done)
2. ✅ Core Data stack skeleton (done)
3. ✅ Entity classes generated (done)
4. ⬜ Run `xcodegen generate` on Mac
5. ⬜ Verify V58 .xcdatamodeld loads
6. ⬜ Migrate 1-2 @Observable classes as proof of concept
7. ⬜ Convert one View with @Query to @FetchRequest

---

## Files to Ignore for iOS 15 Build
These targets are disabled in project.yml:
- `Widgets/` - entire directory (WidgetKit, Live Activities)
- `MeshtasticMessages/` - Messages Extension
- `Meshtastic Watch App/` - watchOS app
- `Meshtastic TV/` - tvOS app
- `MeshtasticTVUITests/` - tvOS UI tests
- `WidgetsExtension/` - Widget Extension target

---

## Testing Checklist (iPhone 7 / iOS 15.8.3)
- [ ] App launches without crash
- [ ] BLE pairing works
- [ ] Message send/receive works
- [ ] Node list displays
- [ ] Map works (MapKit)
- [ ] Settings persist (Core Data)
- [ ] Firmware update (DFU) works
- [ ] Channel management works
- [ ] No memory leaks (Instruments)

---

## References
- `CoreDataMigrationService.swift` - Entity/property reference
- `MeshtasticSchemaV1.swift` - Complete entity list
- Apple: [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html)
- Apple: [Migrating from SwiftData to Core Data](https://developer.apple.com/documentation/swiftdata/migrating-from-swiftdata-to-core-data)

---

*Generated as part of iOS 15 backport effort. Last updated: 2026-11-05*