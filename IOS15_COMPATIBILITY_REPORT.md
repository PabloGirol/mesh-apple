# iOS 15 Compatibility Report for Meshtastic

## Current Deployment Target
- **iOS 16.4** (most targets) / **iOS 17.5** (some targets)
- To support iOS 15: Change to `IPHONEOS_DEPLOYMENT_TARGET = 15.0` and add `MESHTASTIC_IOS15` to `SWIFT_ACTIVE_COMPILATION_CONDITIONS`

## Existing iOS 15 Compatibility Infrastructure ✅

1. **NavigationStackShim** (`Extensions/NavigationStackShim.swift`) - Provides `CompatNavigationStack`, `CompatNavigationLink`, `compatNavigationDestination` for iOS 15
2. **ObservableObjectShim** (`Extensions/ObservableObjectShim.swift`) - Replaces `@Observable` macro with `ObservableObject` + `@Published`
3. **Core Data Stack** (`Persistence/CoreDataStack.swift`) - Full Core Data replacement for SwiftData (iOS 15+)
4. **DGCharts Wrappers** (`Views/Helpers/Charts/`) - Swift Charts API replicated using DGCharts for iOS 15
5. **Model Entities** - All SwiftData `@Model` classes converted to Core Data `NSManagedObject` subclasses (see comments: "Converted from SwiftData for iOS 15 compatibility")
6. **Conditional Compilation** - Uses `#if !MESHTASTIC_IOS15` guards for iOS 16+ features

## iOS 16+ APIs Used WITHOUT Proper Guards ❌

### 1. Sheet Presentation APIs (iOS 16+)
**Files affected:** ~40 files
- `.presentationDetents([.large])` - iOS 16+
- `.presentationDetents([.medium, .large])` - iOS 16+
- `.presentationDetents([.fraction(...)])` - iOS 16+
- `.presentationDragIndicator(.visible/.automatic/.hidden)` - iOS 16+
- `.interactiveDismissDisabled()` - iOS 16+

**Key files:**
- `Views/Connect/Connect.swift:603,604`
- `Views/Helpers/DeviceModelView.swift:317,347`
- `Views/MainScene.swift:158,160`
- `Views/Messages/ChannelList.swift:206,208`
- `Views/Nodes/MeshMapMK.swift:521,523,561,563,570,572,579,581,618,621,628,630`
- `Views/Settings/Channels.swift:285,293,295,302,304`
- `Views/Settings/RouteRecorder.swift:277,278,279`
- ...and 25+ more files

### 2. Scroll View APIs (iOS 16+/17+)
**Files affected:** ~10 files
- `.defaultScrollAnchor(.bottom)` / `.defaultScrollAnchor(.bottom, for: .sizeChanges)` - iOS 17+
- `.scrollContentBackground(.hidden)` - iOS 16+
- `.scrollBounceBehavior(.basedOnSize)` - iOS 16+
- `.scrollIndicators(.visible)` - iOS 16+
- `.contentMargins(.top, 0, for: .scrollContent)` - iOS 17+
- `.safeAreaPadding(.vertical, 20)` - iOS 17+

**Key files:**
- `Extensions/View.swift:34,153` (has partial guard for iOS 18)
- `Views/Messages/ChannelMessageList.swift:275`
- `Views/Messages/UserMessageList.swift:313`
- `Views/Nodes/Helpers/AddContactConfirmationView.swift:94`
- `Views/Nodes/Helpers/NodeDetail.swift:185`
- `Views/Settings/Discovery/DiscoveryMapView.swift:113`

### 3. Glass/Visual Effects (iOS 17+)
**Files affected:** ~12 files
- `.glassBackgroundEffect()` - iOS 17+
- `.glassBackgroundEffect(in: shape)` - iOS 17+

**Key files:**
- `Extensions/View.swift:153`
- `Views/Cinema/CinemaModelTag.swift:60`
- `Views/Cinema/CinemaPanel.swift:73`
- `Views/Cinema/CinemaScreen.swift:231,321`
- `Views/Cinema/LookoutNodeCard.swift:35`
- `Views/Helpers/SpatialFeaturesOrnament.swift:75`
- `Views/Nodes/Helpers/Map/MapControlBar.swift:41`
- `Views/Nodes/SpatialMap/SpatialMapView.swift:259`
- `Views/Nodes/SpatialMap/SpatialMapWindow.swift:533`
- `Views/Nodes/SpatialMap/SpatialNodeDetailPanel.swift:78`
- `Views/Showcase/ShowcasePanels.swift:73,202,300`

### 4. Map APIs (iOS 17+)
**Files affected:** ~8 files (extensive usage)
- `Map(position:scope:)` - iOS 17+
- `MapCameraPosition` - iOS 17+
- `MapCamera` - iOS 17+
- `mapStyle()` - iOS 17+
- `.mapScope()` - iOS 17+
- `MapUserLocationButton` - iOS 17+
- `MapPitchToggle` - iOS 17+
- `MapCompass` - iOS 17+
- `MapScaleView` - iOS 17+
- `MapCameraBounds` - iOS 17+

**Key files:**
- `Views/Nodes/Helpers/Map/GeofenceBoundsSelectorView.swift:23,64`
- `Views/Nodes/Helpers/Map/NodeMapSwiftUI.swift:54,56,152,156,157,159,162,165,167,287,306`
- `Views/Nodes/Helpers/Map/Offline/RegionSelectorView.swift:74,127`
- `Views/Nodes/MeshMapMK.swift:65,76,2202`
- `Views/Settings/Discovery/DiscoveryMapView.swift:18,19,68,111,112,115,116,117`
- `Views/Settings/RouteRecorder.swift:20,32,51,63`

### 5. onChange with initial: (iOS 17+)
**Files affected:** ~10 files
- `.onChange(of: value, initial: true) { _, new in }` - iOS 17+

**Key files:**
- `Extensions/PresentationHost.swift:313,650`
- `Views/Nodes/LocalStatsLog.swift:549`
- `Views/Nodes/SpatialMap/SpatialMapView.swift:114`
- `Views/Nodes/SpatialMap/SpatialMapWindow.swift:123,126,130,133`
- `Views/Settings/Config/Forms/PowerConfig.swift:152`
- `Views/Showcase/ShowcaseSpace.swift:143,146`

### 6. Searchable Placement (iOS 16+)
**Files affected:** 7 files
- `.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))` - iOS 16+

**Key files:**
- `Views/Messages/ChannelMessageList.swift:365`
- `Views/Messages/UserList.swift:80`
- `Views/Messages/UserMessageList.swift:403`
- `Views/Nodes/NodeList.swift:230`
- `Views/Settings/AppLog.swift:129`
- `Views/Settings/HelpAndDocumentation/DocBrowserView.swift:168`
- `Views/Settings/Settings.swift:842`

### 7. Toolbar Background/Color Scheme (iOS 16+)
**Files affected:** 2 files
- `.toolbarColorScheme(...)` - iOS 16+
- `.toolbarBackground(.hidden, for: .navigationBar)` - iOS 16+

**Key files:**
- `Views/Connect/EventFirmwareInfoView.swift:86`
- `Views/Nodes/MeshMapMK.swift:879`

### 8. Popover Attachment Anchor (iOS 16+)
**Files affected:** 1 file
- `PopoverAttachmentAnchor` - iOS 16+

**Key files:**
- `Extensions/PresentationHost.swift:347,350,368,377`

### 9. Task with id: (iOS 15+ ✅)
- `.task(id: value)` - **Available in iOS 15** ✅

### 10. Other APIs
- `navigationDestination(isPresented:)` - iOS 16+ (used in PresentationHost.swift:320)
- `matchedGeometryEffect` - iOS 15+ ✅
- `@FocusState` - iOS 15+ ✅
- `Namespace` - iOS 15+ ✅

## AppIntents (iOS 16+) - Properly Guarded ✅
All AppIntents files have:
```swift
#if canImport(AppIntents) && compiler(>=5.9) && !MESHTASTIC_IOS15
@available(iOS 16.0, *)
```
This is correct - AppIntents require iOS 16+.

## Required Actions for iOS 15 Support

### 1. Build Settings Changes
- Set `IPHONEOS_DEPLOYMENT_TARGET = 15.0` for all targets
- Add `MESHTASTIC_IOS15` to `SWIFT_ACTIVE_COMPILATION_CONDITIONS` in Debug/Release configs

### 2. Add Availability Guards
Wrap all iOS 16+ APIs with `#if !MESHTASTIC_IOS15` or `if #available(iOS 16, *)`:

```swift
// For modifiers that can be conditionally applied
if #available(iOS 16, *) {
    view.presentationDetents([.large])
} else {
    view
}

// For APIs that need complete replacement
#if !MESHTASTIC_IOS15
// iOS 16+ implementation
#else
// iOS 15 fallback
#endif
```

### 3. Map View Replacement (Major Work)
The SwiftUI Map APIs (iOS 17+) need complete replacement with `MKMapView` wrapped in `UIViewRepresentable` for iOS 15. This affects ~8 files with extensive map functionality.

### 4. Sheet Presentation Fallback
For iOS 15, sheets don't support `presentationDetents`. Options:
- Use fixed-size sheets
- Use `.frame(maxHeight: ...)` on content
- Create custom presentation controllers

### 5. Glass Effects Fallback
Replace `.glassBackgroundEffect()` with standard backgrounds or custom blur views for iOS 15.

## Estimated Effort
- **High**: Map view replacement (~8 files, significant rewrite)
- **Medium**: Sheet presentation APIs (~40 files, mechanical guards)
- **Medium**: Scroll view APIs (~10 files, mechanical guards)
- **Medium**: Glass effects (~12 files, mechanical guards)
- **Low**: onChange initial:, searchable placement, toolbar modifiers (~20 files, mechanical guards)

## Recommendation
Given the extensive use of iOS 17+ Map APIs and iOS 16+ sheet presentation APIs, supporting iOS 15 would require:
1. Significant refactoring of map views (MKMapView wrappers)
2. Mechanical addition of availability guards to ~80+ API usages
3. Testing on iOS 15 simulator/device

Consider whether iOS 15 support is still required, as iOS 16+ adoption is very high (>90%).