# Meshtastic-Apple iOS 15 Backport - macOS Transition Guide

## ✅ What's Done (Windows - No Build Required)

### Project Configuration (`project.yml`)
- `IPHONEOS_DEPLOYMENT_TARGET`: 15.0
- `SWIFT_VERSION`: **5.9** (for Ventura/Xcode 15.2 compatibility)
- `MACOSX_DEPLOYMENT_TARGET`: **13.6** (Ventura)
- `SUPPORTED_PLATFORMS`: **iphoneos iphonesimulator** (removed xros/visionOS)
- Removed `SWIFT_STRICT_CONCURRENCY`
- **Disabled iOS 16+ targets**: WidgetsExtension, MeshtasticMessages, Watch App, TV, TVUITests
- **Code signing disabled for TrollStore**: `CODE_SIGN_STYLE: "Manual"`, `CODE_SIGN_IDENTITY: ""`, `CODE_SIGNING_REQUIRED: "NO"`

### Core Data Stack (New Files)
| File | Status |
|------|--------|
| `Meshtastic/Persistence/CoreDataStack.swift` | ✅ Complete - **FIXED: `let container` → `var container`, container swap logic implemented** |
| `Meshtastic/Model/CoreData/*.swift` (50 files) | ⚠️ Generated - **MISSING 16+ entities from MeshtasticSchemaV1 (70 total)** |
| `scripts/generate_coredata_entities.py` | ⚠️ Ready to regenerate - **NEEDS UPDATE with all 70 entities** |

### Compatibility Shims (New Files)
| File | Purpose | Status |
|------|---------|--------|
| `Meshtastic/Extensions/NavigationStackShim.swift` | NavigationStack → NavigationView for iOS 15 | ⚠️ **FIXED: `CompatNavigationStackWithData` now iOS 16+ only (NavigationPath doesn't exist on iOS 15)** |
| `Meshtastic/Extensions/ObservableObjectShim.swift` | @Observable → ObservableObject + @Published | ⚠️ **FIXED: `Published` wrapper now checks equality for Equatable types** |

### Migration Scripts
| Script | Purpose | Status |
|--------|---------|--------|
| `scripts/bulk_migrate_ios15.py` | Regex-based source migration (run on macOS) | ⚠️ **FIXED: Removed `import CoreDataStack`, fixed FetchDescriptor placeholder, removed disabled targets from SOURCE_DIRS** |

---

## 🚨 CRITICAL BLOCKERS (Must Fix Before Build)

1. **Missing `.xcdatamodeld` current version**: The file `Meshtastic/Meshtastic.xcdatamodeld` exists but its **current version points to base model (~20 entities), not V58 (50+ entities)**.
   - **Fix on macOS**: Open in Xcode → Select `Meshtastic.xcdatamodeld` → File Inspector → Set "Current Version" to V58

2. **Missing 16+ entities in generator**: `generate_coredata_entities.py` only defines 54 entities but `MeshtasticSchemaV1.swift` has 70.
   - **Fix**: Update `generate_coredata_entities.py` ENTITIES dict with all 70 entities, then run to regenerate CoreData files

3. **NavigationPath fundamentally doesn't work on iOS 15**: `CompatNavigationStackWithData` is iOS 16+ only. Value-based navigation (`NavigationLink(value:)`) **silently fails on iOS 15**.
   - **Fix**: Rewrite all value-based navigation to explicit `NavigationLink(destination:)` or tag-based approach

---

## 📋 macOS Setup Steps

### 1. Install Prerequisites
```bash
brew install xcodegen
# Xcode 15.2 (for Swift 5.9 / iOS 15 SDK on Ventura)
```

### 2. Generate Xcode Project
```bash
cd Meshtastic-Apple
xcodegen generate
open Meshtastic.xcworkspace
```

### 3. CRITICAL: Set xcdatamodeld Current Version to V58
1. In Xcode Project Navigator, select `Meshtastic.xcdatamodeld`
2. File Inspector (⌘⌥1) → "Versioned Core Data Model" → **Current: V58**
3. Build should now find `MeshtasticDataModelV 58.mom`

### 4. Update Entity Generator & Regenerate
```bash
# Edit generate_coredata_entities.py to add missing 16 entities from MeshtasticSchemaV1.swift
python3 scripts/generate_coredata_entities.py
```

### 5. Run Bulk Migration Script
```bash
python3 scripts/bulk_migrate_ios15.py
# Review EVERY change - regex is imperfect
```

### 6. Manual Fixes Required (Priority Order)

#### A. Fix @Observable Classes (~13 classes)
```bash
# Find them:
grep -r "@Observable" Meshtastic/ --include="*.swift"
```
Convert each:
```swift
// BEFORE
@MainActor @Observable
final class DiscoveryScanEngine {
    var currentState = DiscoveryState.idle
}

// AFTER
@MainActor
final class DiscoveryScanEngine: ObservableObject {
    @Published var currentState = DiscoveryState.idle
}
```

#### B. Replace PersistenceController → CoreDataStack
In `MeshtasticApp.swift`:
```swift
// Change:
private let persistenceController: PersistenceController?
// To:
private let persistenceController: CoreDataStack?

// And:
let persistenceController: PersistenceController? = ...
// To:
let persistenceController: CoreDataStack? = ...
```
Update all `.modelContainer(persistenceController.container)` to use CoreDataStack's container manually.

#### C. Convert SwiftData → Core Data Queries (Massive - 233 files)
| SwiftData | Core Data |
|-----------|-----------|
| `@Query` | `@FetchRequest(sortDescriptors: [...])` |
| `ModelContext` | `NSManagedObjectContext` |
| `ModelContainer` | `NSPersistentContainer` |
| `FetchDescriptor<Foo>` | `NSFetchRequest<Foo>(entityName: "Foo")` |
| `#Predicate { $0.name == "x" }` | `NSPredicate(format: "name == %@", "x")` |
| `context.insert(obj)` | `context.insert(obj)` |
| `context.delete(obj)` | `context.delete(obj)` |
| `try context.save()` | `try context.save()` |

#### D. Navigation Rewrite (iOS 15 Limitation)
- `NavigationStack` → `CompatNavigationStack` (auto-done by script)
- `NavigationLink(value:)` → **MUST use explicit `NavigationLink(destination:)` on iOS 15**
- `.navigationDestination(for:)` → `.compatNavigationDestination(for:)` (no-op on iOS 15)
- Programmatic navigation via `NavigationPath` **does NOT work on iOS 15**

#### E. Guard iOS 16+ APIs
```swift
// Wrap in availability checks:
#if available(iOS 16.1, *)
// LiveActivity, ActivityKit code
#endif

// Remove entirely (iOS 18 only):
// WidgetControls, Control Center widgets
```

---

## 🧪 Testing Checklist (iPhone 7 / iOS 15.8.3)

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

## 📦 Dependencies to Verify (iOS 15 support)

| Package | Min iOS | Status |
|---------|---------|--------|
| CocoaMQTT 2.x | 13+ | ✅ |
| IOS-DFU-Library 4.x | 12+ | ✅ |
| swift-protobuf 1.x | 13+ | ✅ |
| swift-markdown 0.x | 13+ | ✅ |
| SwiftDraw 0.x | 13+ | ✅ |
| dd-sdk-ios 3.x | ? | ⚠️ Check |
| mvt-tools | ? | ⚠️ Check |
| opentelemetry-swift | ? | ⚠️ Check |

---

## 📁 Files to Ignore (Disabled Targets)
- `Widgets/` - entire directory
- `MeshtasticMessages/` - Messages Extension
- `Meshtastic Watch App/` - watchOS app
- `Meshtastic TV/` - tvOS app
- `MeshtasticTVUITests/` - tvOS UI tests

---

## ⏱️ Estimated Effort

| Task | Effort |
|------|--------|
| Create xcdatamodeld | 2-3 days |
| @Observable → ObservableObject | 1-2 days |
| SwiftData → Core Data queries | 2-3 weeks |
| Navigation migration | 1-2 weeks |
| Dependency fixes | 1-2 days |
| Testing on iPhone 7 | 1 week |
| **Total** | **4-6 weeks** |

---

## 🔗 Key Reference Files

- `CoreDataMigrationService.swift` - Entity/property reference for xcdatamodeld
- `scripts/generate_coredata_entities.py` - Complete entity definitions
- `MeshtasticSchemaV1.swift` - Complete entity list
- `CoreDataStack.swift` - Core Data stack implementation
- `NavigationStackShim.swift` - Navigation compatibility
- `ObservableObjectShim.swift` - Observation compatibility

---

*Ready for macOS transition. Start with creating `Meshtastic.xcdatamodeld`.*