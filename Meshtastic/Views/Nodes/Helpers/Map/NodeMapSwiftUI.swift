//
//  NodeMapSwiftUI.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 9/11/23.
//

import SwiftUI
import CoreData
import CoreLocation
import MapKit

struct NodeMapContentSignature: Equatable {
	let nodeNum: Int64
	let positionCount: Int
	let lastPositionTime: Date?
	let showNodeHistory: Bool
	let showRouteLines: Bool
	let showConvexHull: Bool
	let favorite: Bool
}

private struct NodeMapContentEquatableWrapper<Content: View>: View, Equatable {
	let signature: NodeMapContentSignature
	@ViewBuilder let content: () -> Content
	static func == (lhs: NodeMapContentEquatableWrapper<Content>, rhs: NodeMapContentEquatableWrapper<Content>) -> Bool { lhs.signature == rhs.signature }
	var body: some View { content() }
}

struct NodeMapSwiftUI: View {
	private let visiblePositionLimit = 1_000

	@Environment(\.managedObjectContext) private var context
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@Environment(\.displayScale) private var displayScale
	@EnvironmentObject var accessoryManager: AccessoryManager
	/// Parameters
	var node: NodeInfoEntity
	@State var showUserLocation: Bool = false
	@State private var positions: [PositionEntity] = []
	@State private var totalPositionCount = 0
	@State private var mostRecentPosition: PositionEntity?
	/// Map State User Defaults
	@AppStorage("meshMapShowNodeHistory") private var showNodeHistory = false
	@AppStorage("meshMapShowRouteLines") private var showRouteLines = false
	@AppStorage("enableMapConvexHull") private var showConvexHull = false
	@AppStorage("enableMapTraffic") private var showTraffic: Bool = false
	@AppStorage("enableMapPointsOfInterest") private var showPointsOfInterest: Bool = false
	@AppStorage("mapLayer") private var selectedMapLayer: MapLayer = .hybrid
	// Map Configuration
	@Namespace var mapScope
	@State var mapStyle: Any = MapStyle.hybrid(elevation: .flat, pointsOfInterest: .all, showsTraffic: true)
	@State var position: Any = MapCameraPosition.automatic
	@State var scene: Any?
	@State var distance = 10000.0
	@State var isLookingAround = false
	@State var isShowingAltitude = false
	@State var isEditingSettings = false
	@State var isShowingLegend = false
	@State var isMeshMap = false
	@State var enabledOverlayConfigs: Set<UUID> = Set()

	@State private var mapRegion = MKCoordinateRegion.init()

	var body: some View {
		if !node.isDeleted {
			Group {
				if totalPositionCount > 0 {
					mapWithNavigation
				} else {
					VStack(spacing: 16) {
						Image(systemName: "mappin.slash")
							.font(.system(size: 48))
							.foregroundColor(.secondary)
						Text("No Positions")
							.font(.title2)
							.foregroundColor(.secondary)
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				}
			}
			.onChange(of: node) {
				handleNodeChange()
				refreshPositions()
			}
			.onAppear {
				handleAppear()
			}
		}
	}

	private var mapWithNavigation: some View {
		ZStack {
			if #available(iOS 17.0, *) {
				MapReader { _ in
					configuredMap
				}
			} else {
				NodeMapMKView(
					node: node,
					positions: positions,
					showUserLocation: showUserLocation,
					showNodeHistory: showNodeHistory,
					showRouteLines: showRouteLines,
					showConvexHull: showConvexHull,
					selectedMapLayer: selectedMapLayer,
					showTraffic: showTraffic,
					showPointsOfInterest: showPointsOfInterest,
					displayScale: displayScale,
					position: $position,
					distance: $distance
				)
			}
		}
		.navigationBarTitle(String((node.user?.shortName ?? "Unknown".localized) + (" \(totalPositionCount) points")), displayMode: .inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				ConnectedDevice(deviceConnected: accessoryManager.isConnected, name: accessoryManager.activeConnection?.device.shortName ?? "?")
			}
		}
	}

	@ViewBuilder
	private var configuredMap: some View {
		if #available(iOS 17.0, *) {
			baseMap
				.overlay(alignment: .bottom) {
					lookAroundView
				}
				.overlay(alignment: .bottom) {
					altitudeView
				}
				.hostedSheet(isPresented: $isEditingSettings) {
					MapSettingsForm(traffic: $showTraffic, pointsOfInterest: $showPointsOfInterest, mapLayer: $selectedMapLayer, meshMap: $isMeshMap, enabledOverlayConfigs: $enabledOverlayConfigs)
				}
				.hostedSheet(isPresented: $isShowingLegend) {
					MapLegend(isMeshMap: false)
						.trackScreen(.mapLegend)
				}
				.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
					view
						.presentationDetents([.medium, .large])
						.presentationContentInteraction(.scrolls)
						.presentationDragIndicator(.visible)
						.presentationBackgroundInteraction(.enabled(upThrough: .medium))
				}
				.onChange(of: selectedMapLayer) { _, newMapLayer in
					updateMapStyle(for: newMapLayer)
				}
				.onChange(of: showNodeHistory) {
					refreshPositions()
				}
				.onChange(of: showRouteLines) {
					refreshPositions()
				}
				.onChange(of: showConvexHull) {
					refreshPositions()
				}
				.overlay(alignment: .bottomTrailing) {
					controlButtons
				}
				.onDisappear {
					UIApplication.shared.isIdleTimerDisabled = false
				}
		}
	}

	private var mapContentSignature: NodeMapContentSignature {
		let positionCount = positions.count
		let lastPositionTime = positions.first?.time
		return NodeMapContentSignature(nodeNum: node.num, positionCount: positionCount, lastPositionTime: lastPositionTime, showNodeHistory: showNodeHistory, showRouteLines: showRouteLines, showConvexHull: showConvexHull, favorite: node.favorite)
	}

	@ViewBuilder
	private var baseMap: some View {
		if #available(iOS 17.0, *) {
			NodeMapContentEquatableWrapper(signature: mapContentSignature) {
				Map(position: $position, bounds: MapCameraBounds(minimumDistance: 0, maximumDistance: .infinity), scope: mapScope) {
					NodeMapContent(node: node, positions: positions, displayScale: displayScale)
				}
			}
			.mapScope(mapScope)
			.mapStyle(mapStyle)
			.mapControls {
				MapScaleView(scope: mapScope)
					.mapControlVisibility(.visible)
				if showUserLocation {
					MapUserLocationButton(scope: mapScope)
						.mapControlVisibility(.visible)
				}
				MapPitchToggle(scope: mapScope)
					.mapControlVisibility(.visible)
				MapCompass(scope: mapScope)
					.mapControlVisibility(.visible)
			}
			.controlSize(.regular)
			.transaction { $0.animation = nil }
		}
	}

	private var lookAroundView: some View {
		Group {
			if #available(iOS 17.0, *) {
				if scene != nil && isLookingAround {
					LookAroundPreview(initialScene: scene!)
						.frame(height: horizontalSizeClass == .regular ? 400 : 250)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.padding(.leading, 20)
						.padding(.trailing, 72)
				}
			}
		}
	}

	private var altitudeView: some View {
		Group {
			if !isLookingAround && isShowingAltitude {
				PositionAltitudeChart(node: node)
					.frame(height: horizontalSizeClass == .regular ? 400 : 250)
					.clipShape(RoundedRectangle(cornerRadius: 12))
					.padding(.leading, 20)
					.padding(.trailing, 72)
			}
		}
	}

	private var controlButtons: some View {
		MapControlBar {
			Button(action: {
				withAnimation {
					isShowingLegend = !isShowingLegend
				}
			}) {
				Image(systemName: isShowingLegend ? "map.fill" : "map")
			}
			.accessibilityLabel(isShowingLegend ? Text("Hide legend") : Text("Show legend"))
			.accessibilityHint(Text("Toggles the map legend"))

			Button(action: {
				withAnimation {
					isEditingSettings = !isEditingSettings
				}
			}) {
				Image(systemName: isEditingSettings ? "info.circle.fill" : "info.circle")
			}
			.accessibilityLabel(isEditingSettings ? Text("Hide map settings") : Text("Show map settings"))

			if #available(iOS 17.0, *) {
				if scene != nil {
					Button(action: {
						if isShowingAltitude {
							isShowingAltitude = false
						}
						isLookingAround = !isLookingAround
					}) {
						Image(systemName: isLookingAround ? "binoculars.fill" : "binoculars")
					}
					.accessibilityLabel(isLookingAround ? Text("Exit look around") : Text("Look around"))
				}
			}

			if totalPositionCount > 1 {
				Button(action: {
					if isLookingAround {
						isLookingAround = false
					}
					isShowingAltitude = !isShowingAltitude
				}) {
					Image(systemName: isShowingAltitude ? "mountain.2.fill" : "mountain.2")
				}
				.accessibilityLabel(isShowingAltitude ? Text("Hide altitude chart") : Text("Show altitude chart"))
			}
		}
		.padding(.trailing, 12)
		.padding(.bottom, 12)
	}

	private func updateMapStyle(for layer: MapLayer) {
		UserDefaults.mapLayer = layer
		if #available(iOS 17.0, *) {
			switch layer {
			case .standard:
				mapStyle = MapStyle.standard(elevation: .flat, pointsOfInterest: showPointsOfInterest ? .all : .excludingAll, showsTraffic: showTraffic)
			case .hybrid:
				mapStyle = MapStyle.hybrid(elevation: .flat, pointsOfInterest: showPointsOfInterest ? .all : .excludingAll, showsTraffic: showTraffic)
			case .satellite:
				mapStyle = MapStyle.imagery(elevation: .flat)
			case .offline:
				break
			}
		}
	}

	private func cameraDistanceForPrecision(_ position: PositionEntity?) -> Double {
		guard let position,
			  12...24 ~= position.precisionBits,
			  let pp = PositionPrecision(rawValue: Int(position.precisionBits)) else {
			return distance
		}
		let needed = pp.precisionMeters * 10.0
		return max(distance, needed)
	}

	private func handleNodeChange() {
		refreshPositions()
		isLookingAround = false
		isShowingAltitude = false
		let newMostRecent = mostRecentPosition
		if totalPositionCount > 1 {
			if #available(iOS 17.0, *) {
				position = .automatic
			}
		} else if let mrCoord = newMostRecent?.nodeCoordinate {
			let cameraDistance = cameraDistanceForPrecision(newMostRecent)
			if #available(iOS 17.0, *) {
				position = .camera(MapCamera(centerCoordinate: mrCoord, distance: cameraDistance, heading: 0, pitch: 0))
			}
		}
		if let newMostRecent, let coord = newMostRecent.nodeCoordinate {
			Task {
				if #available(iOS 17.0, *) {
					scene = try? await fetchScene(for: coord)
				}
			}
		}
	}

	private func handleAppear() {
		UIApplication.shared.isIdleTimerDisabled = true
		updateMapStyle(for: selectedMapLayer)
		refreshPositions()
		let mostRecent = mostRecentPosition
		if totalPositionCount > 1 {
			if #available(iOS 17.0, *) {
				position = .automatic
			}
		} else if let mrCoord = mostRecent?.nodeCoordinate {
			let cameraDistance = cameraDistanceForPrecision(mostRecent)
			if #available(iOS 17.0, *) {
				position = .camera(MapCamera(centerCoordinate: mrCoord, distance: cameraDistance, heading: 0, pitch: 0))
			}
		}
		if #available(iOS 17.0, *) {
			if scene == nil, let mrCoord = mostRecent?.nodeCoordinate {
				Task {
					scene = try? await fetchScene(for: mrCoord)
				}
			}
		}
	}

	private func refreshPositions() {
		totalPositionCount = node.positionCount(context: context)
		let limit = (showNodeHistory || showRouteLines || showConvexHull) ? visiblePositionLimit : 1
		let latestPositions = node.positionsSortedByTime(context: context, ascending: false, limit: limit)
		mostRecentPosition = latestPositions.first
		positions = limit == 1 ? latestPositions : Array(latestPositions.reversed())
	}

	@available(iOS 17.0, *)
	private func fetchScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
		let lookAroundScene = MKLookAroundSceneRequest(coordinate: coordinate)
		return try await lookAroundScene.scene
	}
}

#if !os(iOS) || !os(visionOS) || os(macCatalyst)
/// Fallback for iOS 15/16 - uses MKMapView via UIViewRepresentable
struct NodeMapMKView: UIViewRepresentable {
	let node: NodeInfoEntity
	let positions: [PositionEntity]
	let showUserLocation: Bool
	let showNodeHistory: Bool
	let showRouteLines: Bool
	let showConvexHull: Bool
	let selectedMapLayer: MapLayer
	let showTraffic: Bool
	let showPointsOfInterest: Bool
	let displayScale: CGFloat
	@Binding var position: Any
	@Binding var distance: Double

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		mapView.showsUserLocation = showUserLocation
		mapView.userTrackingMode = showUserLocation ? .follow : .none

		// Apply map configuration
		context.coordinator.applyConfiguration(mapView: mapView, layer: selectedMapLayer, showTraffic: showTraffic, showPointsOfInterest: showPointsOfInterest)

		// Add position annotations
		context.coordinator.addAnnotations(mapView: mapView, positions: positions, node: node, showNodeHistory: showNodeHistory)

		// Add route lines
		if showRouteLines {
			context.coordinator.addRouteLines(mapView: mapView, positions: positions, node: node)
		}

		// Add convex hull
		if showConvexHull {
			context.coordinator.addConvexHull(mapView: mapView, positions: positions)
		}

		// Add precision circles for reduced precision positions
		context.coordinator.addPrecisionCircles(mapView: mapView, positions: positions, node: node)

		context.coordinator.mapView = mapView
		return mapView
	}

	func updateUIView(_ mapView: MKMapView, context: Context) {
		context.coordinator.updateAnnotations(mapView: mapView, positions: positions, node: node, showNodeHistory: showNodeHistory)
		context.coordinator.updateRouteLines(mapView: mapView, positions: positions, node: node, showRouteLines: showRouteLines)
		context.coordinator.updateConvexHull(mapView: mapView, positions: positions, showConvexHull: showConvexHull)
		context.coordinator.updatePrecisionCircles(mapView: mapView, positions: positions, node: node)
		context.coordinator.applyConfiguration(mapView: mapView, layer: selectedMapLayer, showTraffic: showTraffic, showPointsOfInterest: showPointsOfInterest)
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	class Coordinator: NSObject, MKMapViewDelegate {
		weak var mapView: MKMapView?
		private var positionAnnotations: [MKPointAnnotation] = []
		private var historyAnnotations: [MKPointAnnotation] = []
		private var routePolyline: MKPolyline?
		private var convexHullPolygon: MKPolygon?
		private var precisionCircles: [MKCircle] = []

		func applyConfiguration(mapView: MKMapView, layer: MapLayer, showTraffic: Bool, showPointsOfInterest: Bool) {
			let poi: MKPointOfInterestFilter = showPointsOfInterest ? .includingAll : .excludingAll
			switch layer {
			case .standard, .offline:
				let standard = MKStandardMapConfiguration(elevationStyle: .flat)
				standard.pointOfInterestFilter = poi
				standard.showsTraffic = showTraffic
				mapView.preferredConfiguration = standard
			case .hybrid:
				let hybrid = MKHybridMapConfiguration(elevationStyle: .realistic)
				hybrid.pointOfInterestFilter = poi
				hybrid.showsTraffic = showTraffic
				mapView.preferredConfiguration = hybrid
			case .satellite:
				mapView.preferredConfiguration = MKImageryMapConfiguration(elevationStyle: .realistic)
			}
			mapView.showsUserLocation = showUserLocation
			mapView.showsScale = true
			mapView.showsCompass = true
		}

		func addAnnotations(mapView: MKMapView, positions: [PositionEntity], node: NodeInfoEntity, showNodeHistory: Bool) {
			// Clear existing annotations
			mapView.removeAnnotations(positionAnnotations)
			mapView.removeAnnotations(historyAnnotations)
			positionAnnotations.removeAll()
			historyAnnotations.removeAll()

			let nodeColor = UIColor(hex: UInt32(node.num))
			let pf = PositionFlags(rawValue: Int(node.metadata?.positionFlags ?? 771))

			for position in positions {
				guard let coord = position.nodeCoordinate else { continue }

				if position.latest {
					let annotation = MKPointAnnotation()
					annotation.coordinate = coord
					annotation.title = node.user?.shortName ?? "?"
					positionAnnotations.append(annotation)
				} else if showNodeHistory && node.favorite {
					let annotation = MKPointAnnotation()
					annotation.coordinate = coord
					annotation.title = ""
					historyAnnotations.append(annotation)
				}
			}

			mapView.addAnnotations(positionAnnotations)
			mapView.addAnnotations(historyAnnotations)
		}

		func updateAnnotations(mapView: MKMapView, positions: [PositionEntity], node: NodeInfoEntity, showNodeHistory: Bool) {
			addAnnotations(mapView: mapView, positions: positions, node: node, showNodeHistory: showNodeHistory)
		}

		func addRouteLines(mapView: MKMapView, positions: [PositionEntity], node: NodeInfoEntity) {
			let coords = positions.compactMap { $0.nodeCoordinate }
			guard coords.count >= 2 else { return }

			let nodeColor = UIColor(hex: UInt32(node.num))
			let polyline = MKPolyline(coordinates: coords, count: coords.count)
			routePolyline = polyline
			mapView.addOverlay(polyline)
		}

		func updateRouteLines(mapView: MKMapView, positions: [PositionEntity], node: NodeInfoEntity, showRouteLines: Bool) {
			if !showRouteLines {
				if let polyline = routePolyline {
					mapView.removeOverlay(polyline)
					routePolyline = nil
				}
				return
			}
			if routePolyline == nil {
				addRouteLines(mapView: mapView, positions: positions, node: node)
			}
		}

		func addConvexHull(mapView: MKMapView, positions: [PositionEntity]) {
			let coords = positions.compactMap { $0.nodeCoordinate }
			guard coords.count > 0 else { return }

			let hull = coords.getConvexHull()
			let polygon = MKPolygon(coordinates: hull, count: hull.count)
			convexHullPolygon = polygon
			mapView.addOverlay(polygon)
		}

		func updateConvexHull(mapView: MKMapView, positions: [PositionEntity], showConvexHull: Bool) {
			if !showConvexHull {
				if let polygon = convexHullPolygon {
					mapView.removeOverlay(polygon)
					convexHullPolygon = nil
				}
				return
			}
			if convexHullPolygon == nil {
				addConvexHull(mapView: mapView, positions: positions)
			}
		}

		func addPrecisionCircles(mapView: MKMapView, positions: [PositionEntity], node: NodeInfoEntity) {
			for circle in precisionCircles {
				mapView.removeOverlay(circle)
			}
			precisionCircles.removeAll()

			for position in positions where position.latest && position.isReducedPrecision {
				guard let coord = position.nodeCoordinate,
					  let pp = PositionPrecision(rawValue: Int(position.precisionBits)) else { continue }
				let radius = pp.precisionMeters
				if radius > 0 {
					let circle = MKCircle(center: coord, radius: radius)
					precisionCircles.append(circle)
					mapView.addOverlay(circle)
				}
			}
		}

		func updatePrecisionCircles(mapView: MKMapView, positions: [PositionEntity], node: NodeInfoEntity) {
			addPrecisionCircles(mapView: mapView, positions: positions, node: node)
		}

		func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
			if let polyline = overlay as? MKPolyline, polyline === routePolyline {
				let renderer = MKPolylineRenderer(polyline: polyline)
				renderer.strokeColor = UIColor.systemBlue
				renderer.lineWidth = 3
				renderer.lineDashPattern = [10, 10]
				return renderer
			}
			if let polygon = overlay as? MKPolygon, polygon === convexHullPolygon {
				let renderer = MKPolygonRenderer(polygon: polygon)
				renderer.strokeColor = UIColor.systemBlue
				renderer.fillColor = UIColor.systemIndigo.withAlphaComponent(0.4)
				renderer.lineWidth = 3
				return renderer
			}
			if let circle = overlay as? MKCircle, precisionCircles.contains(circle) {
				let renderer = MKCircleRenderer(circle: circle)
				renderer.strokeColor = UIColor.white
				renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.25)
				renderer.lineWidth = 2
				return renderer
			}
			return MKOverlayRenderer(overlay: overlay)
		}

		func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
			if annotation is MKUserLocation { return nil }

			let reuseId = "positionPin"
			var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
			if annotationView == nil {
				annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
				annotationView?.canShowCallout = true
			} else {
				annotationView?.annotation = annotation
			}
			return annotationView
		}
	}
}
#else
typealias NodeMapMKView = EmptyView
#endif