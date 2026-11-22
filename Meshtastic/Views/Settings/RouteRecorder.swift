//
//  Routes.swift
//  Meshtastic
//
//  Created by Garth Vander Houwen on 11/21/23.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocation
import CoreMotion
import OSLog

struct RouteRecorder: View {

	@ObservedObject var locationsHandler: LocationsHandler = LocationsHandler.shared
	@Environment(\.managedObjectContext) private var context
	@Environment(\.dismiss) private var dismiss
	#if available(iOS 17.0, *)
	@State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
	@State var mapStyle: MapStyle = MapStyle.standard(elevation: .realistic)
	#else
	@State private var position: MKCoordinateRegion = MKCoordinateRegion()
	@State var mapStyle: Any = ""
	#endif
	@State var isShowingDetails = false
	@Namespace var namespace
	@Namespace var routerecorderscope
	@State var recording: RouteEntity?
	@State var color: Color = .blue
	@State var activity: Int = 1

	var body: some View {
		VStack {
			ZStack {
				if #available(iOS 17.0, *) {
					Map(position: $position, scope: routerecorderscope) {
						UserAnnotation()
						/// Route Lines
						let lineCoords = locationsHandler.locationsArray.compactMap({(position) -> CLLocationCoordinate2D in
							return position.coordinate
						})

						let gradient = LinearGradient(
							colors: [color],
							startPoint: .leading, endPoint: .trailing
						)
						let dashed = StrokeStyle(
							lineWidth: 3,
							lineCap: .round, lineJoin: .round, dash: [10, 10]
						)
						MapPolyline(coordinates: lineCoords)
							.stroke(gradient, style: dashed)

					}
					.mapStyle(mapStyle)
				} else {
					RouteRecorderMapView(
						locations: locationsHandler.locationsArray,
						color: color,
						position: $position
					)
				}
			}
			if #available(iOS 17.0, *) {
				.mapControls {
					MapScaleView(scope: routerecorderscope)
						.mapControlVisibility(.automatic)
					MapPitchToggle(scope: routerecorderscope)
						.mapControlVisibility(.automatic)
					MapCompass(scope: routerecorderscope)
						.mapControlVisibility(.automatic)
				}
			}
			.controlSize(.regular)
			.offset(y: 100)
			if #available(iOS 17.0, *) {
				.mapScope(routerecorderscope)
			}
			.safeAreaInset(edge: .bottom) {
				ZStack {
					VStack {
						HStack(spacing: 10) {
							Spacer()

							Button {
								isShowingDetails = true
							} label: {
								Image(systemName: locationsHandler.isRecording ? "record.circle.fill" : "record.circle")
									.font(.system(size: 72))
									.symbolRenderingMode(.multicolor)
									.foregroundColor(.red)
							}
							.glassButtonStyle()
							.buttonBorderShape(.circle)
							.matchedGeometryEffect(id: "Details Button", in: namespace)
							.accessibilityLabel(locationsHandler.isRecording ? String(localized: "Recording route, view details", comment: "VoiceOver label for the route recording button while a recording is in progress") : String(localized: "View route recording details", comment: "VoiceOver label for the route recording button when idle"))

							Spacer()
						}
					}
				}
				.padding()
			}
			.hostedSheet(isPresented: $isShowingDetails) {
				CompatNavigationStack {
					VStack {
							if locationsHandler.isRecording {
								HStack(alignment: .center) {
									Image(systemName: "record.circle.fill")
										.symbolRenderingMode(.multicolor)
										.font(.title)
										.foregroundColor(.red)
									Text("Recording route")
										.font(.title)
									Spacer()
									Text("\(Image(systemName: "mappin.and.ellipse")) \(locationsHandler.count)")
										.foregroundColor(.red)
										.font(.title2)
								}
								.padding()
							} else if locationsHandler.isRecordingPaused {
								HStack(alignment: .center) {

									Image(systemName: "playpause")
										.symbolRenderingMode(.multicolor)
										.font(.title3)
										.foregroundColor(.red)
									Text("Route recording paused")
										.font(.title)
								}
								.padding(.top)
							}

							if locationsHandler.isRecording || locationsHandler.isRecordingPaused {
								Divider()
								HStack {
									VStack {
										Text(locationsHandler.recordingStarted ?? Date(), style: .timer)
											.font(.title)
											.fixedSize()
										Text("Time")
											.font(.callout)
											.fixedSize()
									}
									.padding(.horizontal)
									Divider()
									VStack {
										let distance = Measurement(value: locationsHandler.distanceTraveled, unit: UnitLength.meters)
										Text("\(distance.formatted())")
											.font(.title)
											.fixedSize()
										Text("Distance")
											.font(.callout)
											.fixedSize()
									}
									.padding(.horizontal)
									Divider()
									VStack {
										let gain = Measurement(value: locationsHandler.elevationGain, unit: UnitLength.meters)
										Text(gain.formatted())
											.font(.title)
										Text("Elev. Gain")
											.font(.callout)
									}
									.padding(.horizontal)
								}
								.frame(maxHeight: 90)
							}
							Divider()
							VStack(alignment: .leading) {
								List {
									GPSStatus(largeFont: .body, smallFont: .callout)
								}
								.listStyle(.plain)
								if recording == nil {
									HStack(alignment: .center) {
										Spacer()
										Image(systemName: "figure.hiking")
											.symbolRenderingMode(.multicolor)
											.font(.title3)
											.foregroundColor(.accentColor)
										Text("Activity")
										Picker(selection: $activity, label: Text("Activity")) {
											ForEach(ActivityType.allCases) { r in
												Text(r.description)
											}
										}
										Spacer()
									}
								}
								HStack {
									Spacer()
									if !locationsHandler.isRecording && !locationsHandler.isRecordingPaused {
										/// We are not recording or paused, show start recording button
										Button {
											locationsHandler.isRecording = true
											locationsHandler.count = 0
											locationsHandler.distanceTraveled = 0.0
											locationsHandler.elevationGain = 0.0
											locationsHandler.locationsArray.removeAll()
											locationsHandler.recordingStarted = Date()
											let newRoute = RouteEntity(context: context)
											newRoute.date = Date()
											let at = ActivityType(rawValue: activity)
											newRoute.name = "\(newRoute.date?.relativeTimeOfDay() ?? "morning".localized) \(at?.fileNameString ?? "hike")"
											newRoute.id = Int32.random(in: Int32(Int8.max) ... Int32.max)
											newRoute.color = Int64(UIColor.random.hex)
											newRoute.enabled = false
											color = Color(UIColor(hex: UInt32(newRoute.color)))
											self.recording = newRoute
											do {
												try context.save()
												Logger.data.info("💾 Saved a new route")
											} catch {
												let nsError = error as NSError
												Logger.data.error("Error Saving RouteEntity from the Route Recorder \(nsError, privacy: .public)")
											}
										} label: {
											Label("Start", systemImage: "play")
										}
										.buttonStyle(.bordered)
										.buttonBorderShape(.capsule)
										.controlSize(.large)
										.padding(.bottom)

									} else if locationsHandler.isRecording {
										/// We are recording show pause button
										Button {
											locationsHandler.isRecording = false
											locationsHandler.isRecordingPaused = true
										} label: {
											Label("Pause", systemImage: "pause")
										}
										.buttonStyle(.bordered)
										.buttonBorderShape(.capsule)
										.controlSize(.large)
										.padding(.bottom)
									} else if locationsHandler.isRecordingPaused {
										/// We are paused show resume button
										Button {
											locationsHandler.isRecording = true
											locationsHandler.isRecordingPaused = false
										} label: {
											Label("Resume", systemImage: "playpause")
										}
										.buttonStyle(.bordered)
										.buttonBorderShape(.capsule)
										.controlSize(.large)
										.padding(.bottom)
									}

									if locationsHandler.isRecording || locationsHandler.isRecordingPaused {
										/// We are recording or paused, show finish button
										Button {

											if let rec = recording {
												rec.enabled = true
												rec.distance = locationsHandler.distanceTraveled
												rec.elevationGain = locationsHandler.elevationGain
											}
											locationsHandler.isRecording = false
											locationsHandler.isRecordingPaused = false
											locationsHandler.distanceTraveled = 0.0
											locationsHandler.elevationGain = 0.0
											locationsHandler.locationsArray.removeAll()
											locationsHandler.recordingStarted = nil
											do {
												try context.save()
												Logger.data.info("💾 Saved a route finish")
											} catch {
												let nsError = error as NSError
												Logger.data.error("Error Saving RouteEntity from the Route Recorder \(nsError, privacy: .public)")
											}
											isShowingDetails = false
										} label: {
											Label("Finish", systemImage: "flag.checkered")
										}
										.buttonStyle(.bordered)
										.buttonBorderShape(.capsule)
										.controlSize(.large)
										.padding(.bottom)
									}
									Spacer()
								}

							}
						}
						.navigationBarTitleDisplayMode(.inline)
						.sheetCloseButton { isShowingDetails = false }
				}
				.trackScreen(.routeRecordingDetails)
				.modifier(SheetPresentationModifiers(
					detents: [.fraction(0.45), .fraction(0.65)],
					selection: .constant(.fraction(0.45)),
					contentInteraction: .scrolls,
					dragIndicatorVisible: false,
					backgroundInteractionEnabled: false,
					interactiveDismissDisabled: false
				))
				.onAppear {
					UIApplication.shared.isIdleTimerDisabled = true
				}
				.onDisappear(perform: {
					UIApplication.shared.isIdleTimerDisabled = false
				})
				.onChange(of: locationsHandler.locationsArray.last) { _, newLoc in
					if locationsHandler.isRecording {
						if let loc = newLoc {
							if recording != nil {
								let locationEntity = LocationEntity(context: context)
								locationEntity.routeLocation = recording
								locationEntity.id = Int32(locationsHandler.count)
								locationEntity.altitude = Int32(loc.altitude)
								locationEntity.heading = Int32(loc.course)
								locationEntity.speed = Int32(loc.speed)
								locationEntity.latitudeI = Int32(loc.coordinate.latitude * 1e7)
								locationEntity.longitudeI = Int32(loc.coordinate.longitude * 1e7)
								do {
									try context.save()
									Logger.data.info("💾 Saved a new route location")
								} catch {
									let nsError = error as NSError
									Logger.data.error("Error Saving LocationEntity from the Route Recorder \(nsError, privacy: .public)")
								}
							}
						}
					}
				}
			}
		}
		.ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
	}
}

#if !os(iOS) || !os(visionOS) || os(macCatalyst)
/// Fallback for iOS 15/16 - uses MKMapView via UIViewRepresentable
struct RouteRecorderMapView: UIViewRepresentable {
	let locations: [CLLocation]
	let color: Color
	#if available(iOS 17.0, *)
	@Binding var position: MapCameraPosition
	#else
	@Binding var position: MKCoordinateRegion
	#endif

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .followWithHeading
		mapView.mapType = .standard

		// Draw route polyline
		if !locations.isEmpty {
			let coordinates = locations.map { $0.coordinate }
			let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
			mapView.addOverlay(polyline)
		}

		context.coordinator.mapView = mapView
		return mapView
	}

	func updateUIView(_ uiView: MKMapView, context: Context) {
		// Update polyline if locations changed
		if !locations.isEmpty {
			uiView.removeOverlays(uiView.overlays)
			let coordinates = locations.map { $0.coordinate }
			let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
			uiView.addOverlay(polyline)
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	class Coordinator: NSObject, MKMapViewDelegate {
		weak var mapView: MKMapView?

		func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
			if let polyline = overlay as? MKPolyline {
				let renderer = MKPolylineRenderer(polyline: polyline)
				renderer.strokeColor = UIColor(Color.blue)
				renderer.lineWidth = 3
				renderer.lineDashPattern = [10, 10]
				return renderer
			}
			return MKOverlayRenderer(overlay: overlay)
		}
	}
}
#else
typealias RouteRecorderMapView = EmptyView
#endif