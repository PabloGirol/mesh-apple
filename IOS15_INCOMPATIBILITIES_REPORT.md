# iOS 15 Incompatibilities Report for Meshtastic-Apple

**Date:** 2026-11-21  
**Branch:** main  
**Deployment Target:** iOS 15.0 (configured in project.yml)

---

## ✅ Already Configured

| Item | Status | Details |
|------|--------|---------|
| `IPHONEOS_DEPLOYMENT_TARGET` | ✅ | Set to `15.0` in project.yml for all configs |
| `SWIFT_VERSION` | ✅ | Set to `5.9` (last with full iOS 15 support) |
| `MESHTASTIC_IOS15` compilation condition | ✅ | Defined in Debug & Release for Meshtastic target |
| NavigationStackShim | ✅ | `CompatNavigationStack`, `CompatNavigationLink`, `compatNavigationDestination` |
| ObservableObjectShim | ✅ | Replaces `@Observable` with `ObservableObject` + `@Published` |
| CoreDataStack | ✅ | Full Core Data replacement for SwiftData |
| DGCharts Wrappers | ✅ | Swift Charts API replicated using DGCharts for iOS 15 |
| Model Entities | ✅ | SwiftData `@Model` → Core Data `NSManagedObject` subclasses |

---

## ❌ Unguarded iOS 16+ APIs Requiring Fixes

### 1. Sheet Presentation APIs (iOS 16+) — **~40 files**

**API:** `.presentationDetents([.large])`, `.presentationDetents([.medium, .large])`, `.presentationDetents([.fraction(...)])`, `.presentationDragIndicator(.visible)`, `.interactiveDismissDisabled()`

**Files (representative):**
- `Meshtastic/Views/Connect/Connect.swift:603-604`
- `Meshtastic/Views/Helpers/DeviceModelView.swift:317,347`
- `Meshtastic/Views/MainScene.swift:158,160`
- `Meshtastic/Views/Messages/ChannelList.swift:206,208`
- `Meshtastic/Views/Nodes/MeshMapMK.swift:521,523,561,563,570,572,579,581,618,621,628,630`
- `Meshtastic/Views/Settings/Channels.swift:285,293,295,302,304`
- `Meshtastic/Views/Settings/RouteRecorder.swift:277,278,279`
- `Meshtastic/Views/Nodes/Helpers/AddContactConfirmationView.swift:94`
- `Meshtastic/Views/Nodes/Helpers/Map/MapSettingsForm.swift`
- `Meshtastic/Views/Nodes/Helpers/Map/NodeMapSwiftUI.swift`
- `Meshtastic/Views/Nodes/Helpers/Metrics Columns/MetricsColumnDetail.swift`
- `Meshtastic/Views/Nodes/Helpers/NodeListFilter.swift`
- `Meshtastic/Views/Nodes/LocalStatsLog.swift`
- `Meshtastic/Views/Provisioning/WifiNetworkListView.swift`
- `Meshtastic/Views/Settings/AppSettings.swift`
- `Meshtastic/Views/Settings/Config/Forms/MQTTConfig.swift`
- `Meshtastic/Views/Settings/Logs/AppLogFilter.swift`
- `Meshtastic/Views/Settings/Logs/LogDetail.swift`
- `Meshtastic/Views/Helpers/Help/ChannelsHelp.swift`
- `Meshtastic/Views/Helpers/Help/DirectMessagesHelp.swift`
- `Meshtastic/Views/Helpers/Help/NodeListHelp.swift`
- `Meshtastic/Views/Messages/MessageText.swift`
- `Meshtastic/Views/Messages/TapbackInputView.swift`

**Fix:** Wrap with `#if !MESHTASTIC_IOS15` or `if #available(iOS 16, *)`. For iOS 15, use fixed-size sheets with `.frame(maxHeight: ...)`.

---

### 2. Glass/Visual Effects (iOS 17+) — **~12 files**

**API:** `.glassBackgroundEffect()`, `.glassBackgroundEffect(in: shape)`

**Files:**
- `Meshtastic/Extensions/View.swift:153` — `.glassBackgroundEffect(in: Capsule())`
- `Meshtastic/Views/Cinema/CinemaModelTag.swift:60` — `.glassBackgroundEffect()`
- `Meshtastic/Views/Cinema/CinemaPanel.swift:73` — `.glassBackgroundEffect()`
- `Meshtastic/Views/Cinema/CinemaScreen.swift:231,321` — `.glassBackgroundEffect(in: shape)`, `.glassBackgroundEffect()`
- `Meshtastic/Views/Cinema/LookoutNodeCard.swift:35` — `.glassBackgroundEffect()`
- `Meshtastic/Views/Helpers/SpatialFeaturesOrnament.swift:75` — `.glassBackgroundEffect(in: Capsule())`
- `Meshtastic/Views/Nodes/Helpers/Map/MapControlBar.swift:41` — `content.glassBackgroundEffect(in: Capsule())`
- `Meshtastic/Views/Nodes/SpatialMap/SpatialMapView.swift:259` — `.glassBackgroundEffect(in: .capsule)`
- `Meshtastic/Views/Nodes/SpatialMap/SpatialMapWindow.swift:533` — `.glassBackgroundEffect()`
- `Meshtastic/Views/Nodes/SpatialMap/SpatialNodeDetailPanel.swift:78` — `.glassBackgroundEffect(in: RoundedRectangle(...))`
- `Meshtastic/Views/Showcase/ShowcasePanels.swift:73,202,300` — `.glassBackgroundEffect(in: ...)`, `.glassBackgroundEffect()`

**Fix:** Wrap with `#if !MESHTASTIC_IOS15`. For iOS 15, use `.background(.regularMaterial, in: shape)` or custom blur views.

---

### 3. Scroll View APIs (iOS 16+/17+) — **~10 files**

**APIs:** `.scrollContentBackground(.hidden)`, `.scrollIndicators(.visible)`, `.defaultScrollAnchor(.bottom)`, `.scrollBounceBehavior(.basedOnSize)`, `.contentMargins(...)`, `.safeAreaPadding(...)`

**Files:**
- `Meshtastic/Extensions/View.swift:34,153` — partial guard for iOS 18 only
- `Meshtastic/Views/Connect/EventFirmwareInfoView.swift` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Messages/ChannelMessageList.swift:275` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Messages/UserMessageList.swift:313` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Messages/TextMessageField/TextMessageField.swift` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Nodes/Helpers/AddContactConfirmationView.swift:94` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Nodes/Helpers/Map/WaypointForm.swift` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Nodes/Helpers/NodeDetail.swift:185` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Settings/Discovery/DiscoveryMapView.swift:113` — `.scrollContentBackground(.hidden)`
- `Meshtastic/Views/Settings/Firmware/UF2 Mass Storage/BootloaderUpgradeView.swift` — `.scrollIndicators(.visible)`
- `Meshtastic/Views/Settings/Firmware/UF2 Mass Storage/FactoryEraseView.swift` — `.scrollIndicators(.visible)`
- `Meshtastic/Views/Settings/Firmware/UF2 Mass Storage/UF2MassStorageView.swift` — `.scrollIndicators(.visible)`

**Fix:** Wrap with `#if !MESHTASTIC_IOS15` or `if #available(iOS 16, *)`.

---

### 4. onChange with `initial:` (iOS 17+) — **~10 files**

**API:** `.onChange(of: value, initial: true) { _, new in }`

**Files:**
- `Meshtastic/Extensions/PresentationHost.swift:313,650`
- `Meshtastic/Views/Nodes/LocalStatsLog.swift:549`
- `Meshtastic/Views/Nodes/SpatialMap/SpatialMapView.swift:114`
- `Meshtastic/Views/Nodes/SpatialMap/SpatialMapWindow.swift:123,126,130,133`
- `Meshtastic/Views/Settings/Config/Forms/PowerConfig.swift:152`
- `Meshtastic/Views/Showcase/ShowcaseSpace.swift:143,146`

**Fix:** For iOS 15, manually trigger the closure on appear:
```swift
#if !MESHTASTIC_IOS15
.onChange(of: value, initial: true) { _, new in ... }
#else
.onAppear { handleChange(value) }
.onChange(of: value) { _, new in handleChange(new) }
#endif
```

---

### 5. Searchable Placement (iOS 16+) — **7 files**

**API:** `.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))`

**Files:**
- `Meshtastic/Views/Messages/ChannelMessageList.swift:365`
- `Meshtastic/Views/Messages/UserList.swift:80`
- `Meshtastic/Views/Messages/UserMessageList.swift:403`
- `Meshtastic/Views/Nodes/NodeList.swift:230`
- `Meshtastic/Views/Settings/AppLog.swift:129`
- `Meshtastic/Views/Settings/HelpAndDocumentation/DocBrowserView.swift:168`
- `Meshtastic/Views/Settings/Settings.swift:842`

**Fix:** Wrap with `#if !MESHTASTIC_IOS15`. On iOS 15, use default placement (no `placement:` parameter).

---

### 6. Toolbar Background/Color Scheme (iOS 16+) — **2 files**

**API:** `.toolbarColorScheme(...)`, `.toolbarBackground(.hidden, for: .navigationBar)`

**Files:**
- `Meshtastic/Views/Connect/EventFirmwareInfoView.swift:86`
- `Meshtastic/Views/Nodes/MeshMapMK.swift:879` — `.toolbarBackground(.hidden, for: .navigationBar)`

**Fix:** Wrap with `#if !MESHTASTIC_IOS15`.

---

### 7. SwiftUI Map APIs (iOS 17+) — **~8 files (extensive usage)**

**APIs:** `Map(position:scope:)`, `MapCameraPosition`, `MapCamera`, `mapStyle()`, `.mapScope()`, `MapUserLocationButton`, `MapPitchToggle`, `MapCompass`, `MapScaleView`, `MapCameraBounds`, `.onMapCameraChange()`

**Files:**
- `Meshtastic/Views/Nodes/Helpers/Map/GeofenceBoundsSelectorView.swift:23,64`
- `Meshtastic/Views/Nodes/Helpers/Map/NodeMapSwiftUI.swift:54,56,152,156,157,159,162,165,167,287,306`
- `Meshtastic/Views/Nodes/Helpers/Map/Offline/RegionSelectorView.swift:74,127`
- `Meshtastic/Views/Nodes/Helpers/Map/MapContent/NodeMapContent.swift` (uses `@Namespace var mapScope`)
- `Meshtastic/Views/Settings/Discovery/DiscoveryMapView.swift:18,19,68,111,112,115,116,117`
- `Meshtastic/Views/Settings/RouteRecorder.swift:20,32,51,63`

**Note:** `MeshMapMK.swift` uses `MKMapView` via `ClusterMapView` wrapper — **compatible with iOS 15** ✅

**Fix:** Requires complete replacement with `MKMapView` wrapped in `UIViewRepresentable` for iOS 15. This is major work affecting ~8 files with extensive map functionality.

---

### 8. Popover Attachment Anchor (iOS 16+) — **1 file**

**API:** `PopoverAttachmentAnchor`

**Files:**
- `Meshtastic/Extensions/PresentationHost.swift:347,350,368,377`

**Fix:** Wrap with `#if !MESHTASTIC_IOS15`. Use standard popover presentation on iOS 15.

---

### 9. navigationDestination(isPresented:) (iOS 16+) — **1 file**

**API:** `.navigationDestination(isPresented:)`

**Files:**
- `Meshtastic/Extensions/PresentationHost.swift:320`

**Fix:** Wrap with `#if !MESHTASTIC_IOS15`. Use explicit `NavigationLink` on iOS 15.

---

### 10. @Observable Macro (iOS 17+) — **~13 files**

**Status:** Infrastructure exists (`ObservableObjectShim.swift`), but migration incomplete.

**Classes to migrate (grep `@Observable`):**
- `DiscoveryScanEngine` (`Services/`)
- `DocModels` (`Views/Settings/HelpAndDocumentation/`)
- `BeaconJoinPrompts` (`Views/Settings/Discovery/`)
- `RadioSetupModel` (`Views/Onboarding/RadioSetup/`)
- `SpatialMapModel` (`Views/Nodes/SpatialMap/`)
- `ShowcaseSceneController` (`Views/Showcase/`)
- `ShowcaseDisplays` (`Views/Showcase/`)
- `LookoutScene` (`Helpers/Cinema/`)
- `CinemaModelStand` (`Helpers/Cinema/`)
- `LookoutMarkerPanels` (`Helpers/Cinema/`)
- `SpatialTerrainKeeper` (`Helpers/SpatialMap/`)
- `DisplayMirrorSession` (`Accessory/DisplayMirror/`)
- `MeshClient` (`Meshtastic TV/Client/`)

**Fix:** Convert each class from `@Observable` to `ObservableObject` with `@Published` properties.

---

### 11. SwiftData → Core Data Migration — **~250 files**

**Status:** Infrastructure exists (`CoreDataStack.swift`, entity classes), but queries not migrated.

**APIs to convert:**
| SwiftData | Core Data |
|-----------|-----------|
| `@Query` | `@FetchRequest` |
| `ModelContext` | `NSManagedObjectContext` |
| `ModelContainer` | `NSPersistentContainer` |
| `FetchDescriptor<Foo>` | `NSFetchRequest<Foo>(entityName: "Foo")` |
| `#Predicate { $0.name == "x" }` | `NSPredicate(format: "name == %@", "x")` |

**Key directories:**
- `Meshtastic/Persistence/*.swift`
- `Meshtastic/Model/*.swift`
- `Meshtastic/Extensions/SwiftData/*.swift`
- All View files using `@Query` or `@Environment(\.modelContext)`

---

### 12. NavigationStack Migration — **~67 files**

**Status:** `NavigationStackShim` provides `CompatNavigationStack`, but value-based navigation (`NavigationLink(value:)`, `.navigationDestination(for:)`) doesn't work on iOS 15.

**Files using NavigationStack:** (67 files found)
- Most View files in `Meshtastic/Views/`
- `Meshtastic/Extensions/PresentationHost.swift`

**Fix:** Replace value-based navigation with explicit `NavigationLink(destination:)` or tag-based approach. Programmatic navigation via `NavigationPath` **does not work on iOS 15**.

---

### 13. LiveActivity / WidgetKit / AppIntents — **Properly Guarded ✅**

**Status:** All AppIntents files have:
```swift
#if canImport(AppIntents) && compiler(>=5.9) && !MESHTASTIC_IOS15
@available(iOS 16.0, *)
```
This is correct — AppIntents require iOS 16+.

**Disabled targets in project.yml:**
- ❌ WidgetsExtension (WidgetKit, Live Activities)
- ❌ MeshtasticMessages (Messages Extension)
- ❌ Meshtastic Watch App (watchOS 10+)
- ❌ Meshtastic TV (tvOS 17+)
- ❌ Meshtastic TVUITests
- ❌ WidgetsExtension scheme

---

## 📋 Summary of Required Work

| Category | Files Affected | Effort | Risk |
|----------|----------------|--------|------|
| Sheet Presentation APIs | ~40 | Medium | Medium |
| Glass Effects | ~12 | Medium | Low |
| Scroll View APIs | ~10 | Low | Low |
| onChange initial: | ~10 | Low | Low |
| Searchable Placement | 7 | Low | Low |
| Toolbar Modifiers | 2 | Low | Low |
| **SwiftUI Map APIs** | **~8** | **Very High** | **Very High** |
| Popover/Navigation APIs | ~3 | Medium | Medium |
| @Observable → ObservableObject | ~13 | Medium | Medium |
| SwiftData → Core Data Queries | ~250 | **Very High** | **Very High** |
| NavigationStack Migration | ~67 | High | High |

---

## 🎯 Recommended Priority Order

1. **Add `MESHTASTIC_IOS15` to Release config** (missing from some targets)
2. **Guard all iOS 16+ view modifiers** (`presentationDetents`, `glassBackgroundEffect`, `scrollContentBackground`, etc.) with `#if !MESHTASTIC_IOS15`
3. **Migrate @Observable classes** to `ObservableObject` + `@Published` (13 classes)
4. **Convert one View with @Query** to `@FetchRequest` as proof of concept
5. **Replace SwiftUI Map APIs** with `MKMapView` wrappers (major rewrite)
6. **Full SwiftData → Core Data migration** for all queries
7. **Test on iOS 15 simulator/device** (iPhone 7 / iOS 15.8.3)

---

## 📝 Notes

- The `bulk_migrate_ios15.py` script exists but produces imperfect regex-based changes — **all changes must be reviewed manually**
- The Core Data model (`MeshtasticDataModelV 58.xcdatamodel`) must exist in `Meshtastic.xcdatamodeld` and be compiled via `momc` (handled by pre-build script in project.yml)
- `SWIFT_VERSION = 5.9` is correct — Swift 6.0 requires iOS 16+ for strict concurrency
- Consider whether iOS 15 support is still required given >90% iOS 16+ adoption

---

*Generated by analyzing the codebase for iOS 15 incompatibilities.*