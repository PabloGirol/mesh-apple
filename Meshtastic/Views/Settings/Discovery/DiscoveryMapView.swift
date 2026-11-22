// MARK: DiscoveryMapView
//
//  DiscoveryMapView.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 2026.
//

import MapKit
import SwiftUI

struct DiscoveryMapView: View {
	let discoveredNodes: [DiscoveredNodeEntity]
	let userLatitude: Double
	let userLongitude: Double
	var isScanning: Bool = false

	@Namespace private var mapScope
	@State private var mapPosition: MapCameraPosition = .automatic

	private var userCoordinate: CLLocationCoordinate2D? {
		guard userLatitude != 0.0 || userLongitude != 0.0 else { return nil }
		return CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
	}

	private var nodesWithPosition: [DiscoveredNodeEntity] {
		discoveredNodes.filter { $0.latitude != 0.0 || $0.longitude != 0.0 }
	}

	/// Compute a camera region that fits all nodes inside the radar circle.
	/// The radar circle uses min(width, height) / 2. Since the map is wider
	/// than it is tall (landscape-ish frame), the circle radius is based on
	/// the height. We add ~30 % extra span so nodes sit comfortably inside
	/// the circle rather than at its edge.
	private var fittedRegion: MKCoordinateRegion? {
		guard let userCoord = userCoordinate, !nodesWithPosition.isEmpty else { return nil }

		var maxLat = userCoord.latitude
		var minLat = userCoord.latitude
		var maxLon = userCoord.longitude
		var minLon = userCoord.longitude

		for node in nodesWithPosition {
			maxLat = max(maxLat, node.latitude)
			minLat = min(minLat, node.latitude)
			maxLon = max(maxLon, node.longitude)
			minLon = min(minLon, node.longitude)
		}

		let latSpan = (maxLat - minLat) * 1.6
		let lonSpan = (maxLon - minLon) * 1.6

		// Minimum span so the map doesn't zoom in too far with a single nearby node
		let clampedLatSpan = max(latSpan, 0.005)
		let clampedLonSpan = max(lonSpan, 0.005)

		let centerLat = (maxLat + minLat) / 2
		let centerLon = (maxLon + minLon) / 2

		return MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
			span: MKCoordinateSpan(latitudeDelta: clampedLatSpan, longitudeDelta: clampedLonSpan)
		)
	}

	var body: some View {
		if #available(iOS 17.0, *) {
			swiftUIMap
		} else {
			DiscoveryMapMKView(
				discoveredNodes: discoveredNodes,
				userCoordinate: userCoordinate,
				nodesWithPosition: nodesWithPosition,
				isScanning: isScanning,
				fittedRegion: fittedRegion,
				mapPosition: $mapPosition
			)
		}
	}

	@available(iOS 17.0, *)
	private var swiftUIMap: some View {
		ZStack {
			Map(position: $mapPosition, scope: mapScope) {
				// User position
				if let userCoord = userCoordinate {
					Annotation("You", coordinate: userCoord) {
						Image(systemName: "person.circle.fill")
							.foregroundStyle(.orange)
							.font(.title2)
					}
				}

				// Discovered node annotations
				ForEach(nodesWithPosition, id: \.nodeNum) { node in
					let coord = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
					let nodeColor = Color(UIColor(hex: UInt32(node.nodeNum)))

					// `Annotation`'s title argument drives MapKit-internal behavior (clustering/collision
					// text) — it is NOT surfaced as the hosted content's VoiceOver accessibility label.
					// The explicit modifiers below are what actually make this pin announce node.displayName.
					Annotation(node.displayName, coordinate: coord) {
						VStack(spacing: 2) {
							CircleText(
								text: node.shortName.isEmpty ? String(node.nodeNum.toHex().suffix(4)) : node.shortName,
								color: nodeColor,
								circleSize: 30
							)
							Image(systemName: node.iconName)
								.font(.caption2)
								.foregroundStyle(nodeColor)
						}
						.accessibilityElement(children: .combine)
						.accessibilityLabel(node.displayName)
					}
				}

				// Topology polylines to direct neighbors
				if let userCoord = userCoordinate {
					ForEach(nodesWithPosition.filter { $0.neighborType == "direct" }, id: \.nodeNum) { node in
						let nodeCoord = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
						MapPolyline(coordinates: [userCoord, nodeCoord])
							.stroke(.green.opacity(0.5), lineWidth: 2)
					}
				}
			}
			.mapScope(mapScope)
			.mapStyle(.standard(elevation: .realistic))
			.safeAreaPadding(.vertical, 20)
			.mapControls {
				MapUserLocationButton(scope: mapScope)
				MapCompass(scope: mapScope)
				MapScaleView(scope: mapScope)
			}

			// Radar sweep overlay during active dwell
			RadarSweepView(isActive: isScanning)
		}
		.onChange(of: nodesWithPosition.count) {
			if let region = fittedRegion {
				withAnimation(.easeInOut(duration: 0.8)) {
					mapPosition = .region(region)
				}
			}
		}
	}
}

#if !os(iOS) || !os(visionOS) || os(macCatalyst)
/// Fallback for iOS 15/16 - uses MKMapView via UIViewRepresentable
struct DiscoveryMapMKView: UIViewRepresentable {
	let discoveredNodes: [DiscoveredNodeEntity]
	let userCoordinate: CLLocationCoordinate2D?
	let nodesWithPosition: [DiscoveredNodeEntity]
	let isScanning: Bool
	let fittedRegion: MKCoordinateRegion?
	@Binding var mapPosition: MapCameraPosition

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		mapView.showsUserLocation = userCoordinate != nil
		mapView.userTrackingMode = .none

		// Apply map configuration
		let standard = MKStandardMapConfiguration(elevationStyle: .realistic)
		standard.pointOfInterestFilter = .excludingAll
		mapView.preferredConfiguration = standard
		mapView.showsScale = true
		mapView.showsCompass = true

		// Add annotations
		context.coordinator.addAnnotations(mapView: mapView, userCoordinate: userCoordinate, nodesWithPosition: nodesWithPosition)

		// Add topology polylines
		context.coordinator.addTopologyLines(mapView: mapView, userCoordinate: userCoordinate, nodesWithPosition: nodesWithPosition)

		context.coordinator.mapView = mapView
		return mapView
	}

	func updateUIView(_ mapView: MKMapView, context: Context) {
		context.coordinator.updateAnnotations(mapView: mapView, userCoordinate: userCoordinate, nodesWithPosition: nodesWithPosition)
		context.coordinator.updateTopologyLines(mapView: mapView, userCoordinate: userCoordinate, nodesWithPosition: nodesWithPosition)

		// Handle fitted region update
		if let region = fittedRegion {
			context.coordinator.setRegionIfNeeded(mapView: mapView, region: region)
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	class Coordinator: NSObject, MKMapViewDelegate {
		weak var mapView: MKMapView?
		private var userAnnotation: MKPointAnnotation?
		private var nodeAnnotations: [Int64: MKPointAnnotation] = [:]
		private var topologyPolylines: [MKPolyline] = []
		private var lastFittedRegion: MKCoordinateRegion?

		func addAnnotations(mapView: MKMapView, userCoordinate: CLLocationCoordinate2D?, nodesWithPosition: [DiscoveredNodeEntity]) {
			// User annotation
			if let userCoord = userCoordinate {
				let annotation = MKPointAnnotation()
				annotation.coordinate = userCoord
				annotation.title = "You"
				userAnnotation = annotation
				mapView.addAnnotation(annotation)
			}

			// Node annotations
			for node in nodesWithPosition {
				let coord = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
				let annotation = MKPointAnnotation()
				annotation.coordinate = coord
				annotation.title = node.displayName
				nodeAnnotations[node.nodeNum] = annotation
				mapView.addAnnotation(annotation)
			}
		}

		func updateAnnotations(mapView: MKMapView, userCoordinate: CLLocationCoordinate2D?, nodesWithPosition: [DiscoveredNodeEntity]) {
			// Update user annotation
			if let userCoord = userCoordinate {
				if let annotation = userAnnotation {
					annotation.coordinate = userCoord
				} else {
					let annotation = MKPointAnnotation()
					annotation.coordinate = userCoord
					annotation.title = "You"
					userAnnotation = annotation
					mapView.addAnnotation(annotation)
				}
			} else if let annotation = userAnnotation {
				mapView.removeAnnotation(annotation)
				userAnnotation = nil
			}

			// Update node annotations
			let currentNodes = Set(nodesWithPosition.map { $0.nodeNum })
			for (num, annotation) in nodeAnnotations where !currentNodes.contains(num) {
				mapView.removeAnnotation(annotation)
				nodeAnnotations.removeValue(forKey: num)
			}
			for node in nodesWithPosition {
				if let annotation = nodeAnnotations[node.nodeNum] {
					annotation.coordinate = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
					annotation.title = node.displayName
				} else {
					let coord = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
					let annotation = MKPointAnnotation()
					annotation.coordinate = coord
					annotation.title = node.displayName
					nodeAnnotations[node.nodeNum] = annotation
					mapView.addAnnotation(annotation)
				}
			}
		}

		func addTopologyLines(mapView: MKMapView, userCoordinate: CLLocationCoordinate2D?, nodesWithPosition: [DiscoveredNodeEntity]) {
			guard let userCoord = userCoordinate else { return }
			for node in nodesWithPosition.filter({ $0.neighborType == "direct" }) {
				let nodeCoord = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
				let polyline = MKPolyline(coordinates: [userCoord, nodeCoord], count: 2)
				topologyPolylines.append(polyline)
				mapView.addOverlay(polyline)
			}
		}

		func updateTopologyLines(mapView: MKMapView, userCoordinate: CLLocationCoordinate2D?, nodesWithPosition: [DiscoveredNodeEntity]) {
			// Remove old polylines
			for polyline in topologyPolylines {
				mapView.removeOverlay(polyline)
			}
			topologyPolylines.removeAll()

			// Add new ones
			addTopologyLines(mapView: mapView, userCoordinate: userCoordinate, nodesWithPosition: nodesWithPosition)
		}

		func setRegionIfNeeded(mapView: MKMapView, region: MKCoordinateRegion) {
			// Only set region if it's significantly different to avoid animation conflicts
			if let last = lastFittedRegion {
				let latDiff = abs(last.center.latitude - region.center.latitude)
				let lonDiff = abs(last.center.longitude - region.center.longitude)
				let spanLatDiff = abs(last.span.latitudeDelta - region.span.latitudeDelta)
				let spanLonDiff = abs(last.span.longitudeDelta - region.span.longitudeDelta)
				if latDiff < 0.0001 && lonDiff < 0.0001 && spanLatDiff < 0.0001 && spanLonDiff < 0.0001 {
					return // No significant change
				}
			}
			lastFittedRegion = region
			mapView.setRegion(region, animated: true)
		}

		func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
			if let polyline = overlay as? MKPolyline {
				let renderer = MKPolylineRenderer(polyline: polyline)
				renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.5)
				renderer.lineWidth = 2
				return renderer
			}
			return MKOverlayRenderer(overlay: overlay)
		}

		func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
			if annotation is MKUserLocation { return nil }

			if annotation.title == "You" {
				let reuseId = "userPin"
				var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
				if annotationView == nil {
					annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
					annotationView?.canShowCallout = true
					annotationView?.markerTintColor = .orange
				} else {
					annotationView?.annotation = annotation
				}
				return annotationView
			}

			// Node annotation
			let reuseId = "nodePin"
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
typealias DiscoveryMapMKView = EmptyView
#endif