//
//  DeviceMetricsLog.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 7/7/22.
//  Updated for DGCharts iOS 15 compatibility
//

import DGCharts
import OSLog
import SwiftUI

struct DeviceMetricsLog: View {
	@Environment(\.managedObjectContext) private var context
	@EnvironmentObject var accessoryManager: AccessoryManager
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass

	/// Table on iPhone shows only its first column, even in a regular size class.
	private var showsStackedReadings: Bool {
		horizontalSizeClass != .regular || UIDevice.current.userInterfaceIdiom == .phone
	}

	@State private var isPresentingClearLogConfirm: Bool = false
	@State var isExporting = false
	@State var exportString = ""

	@State private var batteryChartColor: Color = .blue
	@State private var airtimeChartColor: Color = .yellow
	@State private var channelUtilizationChartColor: Color = .green
	var node: NodeInfoEntity
	@State private var deviceMetrics: [TelemetryEntity] = []
	@State private var chartData: [TelemetryEntity] = []
	@State private var totalReadings = 0
	@State private var sortOrder = [KeyPathComparator(\TelemetryEntity.comparableTime, order: .reverse)]
	@State private var selection: NSManagedObjectID?
	@State private var chartSelection: Date?

	var body: some View {
		VStack {
			if totalReadings > 0 {
				if chartData.count > 0 {
					GroupBox(label: Label("\(totalReadings) Readings Total", systemImage: "chart.xyaxis.line")) {
						chartView
					}
					.frame(minHeight: 240)
				}
				if showsStackedReadings {
					/// Single cell. On iPhone this is the only column Table draws.
					Table(deviceMetrics, selection: $selection, sortOrder: $sortOrder) {
						TableColumn("Battery Level") { dm in
							Group {
								HStack {
									Text(dm.time?.formatted(date: .numeric, time: .shortened) ?? "Unknown Age".localized)
										.font(.caption)
										.fontWeight(.semibold)
									Spacer()
									Image(systemName: "bolt")
										.font(.caption)
										.symbolRenderingMode(.multicolor)
									Text("Volts \(dm.voltage?.formatted(.number.precision(.fractionLength(2))) ?? Constants.nilValueIndicator)")
										.font(.caption2)
									BatteryCompact(batteryLevel: dm.batteryLevel, font: .caption, iconFont: .callout, color: .accentColor)
								}
								HStack {
									if let channelUtilization = dm.channelUtilization {
										// Text("Channel Utilization \(String(format: "%.2f%%", channelUtilization))")
										Text("Channel Utilization \(channelUtilization.formatted(.number.precision(.fractionLength(2))))%")
											.foregroundColor(channelUtilization < 25 ? .green : (channelUtilization > 50 ? .red : .orange))
									} else {
										Text("Channel Utilization " + Constants.nilValueIndicator)
											.foregroundColor(.gray)
									}
									// Keep "Airtime" separate here as to avoid creating a new localization key
									Text("Airtime") + Text(" \(dm.airUtilTx?.formatted(.number.precision(.fractionLength(2))) ?? Constants.nilValueIndicator)%")
										.foregroundColor(.secondary)
									Spacer()
								}
								.font(.caption)
							}
							.accessibilityElement(children: .combine)
						}
						.width(ideal: 200, max: .infinity)
					}
				} else {
					/// Columns for iPad and Mac, where Table shows them.
					Table(deviceMetrics, selection: $selection, sortOrder: $sortOrder) {
						TableColumn("Battery Level") { dm in
							if dm.batteryLevel ?? 0 > 100 {
								Text("Powered")
							} else {
								// dm.batteryLevel.map { Text("\(String($0))%") } ?? Text("--")
								Text("\(dm.batteryLevel?.formatted(.number.precision(.fractionLength(0))) ?? Constants.nilValueIndicator)%")
							}
						}
						TableColumn("Voltage") { dm in
							// dm.voltage.map { Text("\(String(format: "%.2f", $0))") } ?? Text("--")
							Text("\(dm.voltage?.formatted(.number.precision(.fractionLength(2))) ?? Constants.nilValueIndicator)")
						}
						TableColumn("Channel Utilization") { dm in
							dm.channelUtilization.map { channelUtilization in
								// Text("\(String(format: "%.2f", channelUtilization))%")
								Text("\(channelUtilization.formatted(.number.precision(.fractionLength(2))))%")
									.foregroundColor(channelUtilization < 25 ? .green : (channelUtilization > 50 ? .red : .orange))
							} ?? Text(Constants.nilValueIndicator)
						}
						TableColumn("Airtime") { dm in
							 // dm.airUtilTx.map { Text("\(String(format: "%.2f", $0))%") } ?? Text("--")
							Text("\(dm.airUtilTx?.formatted(.number.precision(.fractionLength(2))) ?? Constants.nilValueIndicator)")
						}
						TableColumn("Uptime") { dm in
							if let uptimeSeconds = dm.uptimeSeconds {
								let now = Date.now
								let later = now + TimeInterval(uptimeSeconds)
								let components = (now..<later).formatted(.components(style: .narrow))
								Text(components)
							} else {
								Text(Constants.nilValueIndicator)
							}
						}
						.width(min: 100)
						TableColumn("Timestamp") { dm in
							Text(dm.time?.formatted(date: .numeric, time: .shortened) ?? "Unknown Age".localized)
						}
						.width(min: 180)
					}
				}
				HStack {
					Button(role: .destructive) {
						isPresentingClearLogConfirm = true
					} label: {
						Label("Clear Log", systemImage: "trash.fill")
					}
					.buttonStyle(.bordered)
					.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
						view
							.buttonBorderShape(.capsule)
							.controlSize(horizontalSizeClass == .regular ? .large : .regular)
					}
					.padding(.bottom)
					.padding(.leading)
					.hostedConfirmation(
						"Are you sure?",
						isPresented: $isPresentingClearLogConfirm,
						titleVisibility: .visible
					) {
						Button("Delete all device metrics?", role: .destructive) {
							Task {
								if await MeshPackets.shared.clearTelemetry(destNum: node.num, metricsType: 0) {
									Logger.data.notice("Cleared Device Metrics for \(node.num, privacy: .public)")
									await MainActor.run {
										refreshMetrics()
										NotificationCenter.default.post(name: .nodeLogAvailabilityDidChange, object: node.num)
									}
								} else {
									Logger.data.error("Clear Device Metrics Log Failed")
								}
							}
						}
					}

					Button {
						exportString = telemetryToCsvFile(telemetry: deviceMetrics, metricsType: 0)
						isExporting = true
					} label: {
						Label("Save", systemImage: "square.and.arrow.down")
					}
					.hostedWindowOnly()
					.buttonStyle(.bordered)
					.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
						view
							.buttonBorderShape(.capsule)
							.controlSize(horizontalSizeClass == .regular ? .large : .regular)
					}
					.padding(.bottom)
					.padding(.trailing)
				}
				.onChange(of: selection) { _, newSelection in
					guard let metrics = deviceMetrics.first(where: { $0.objectID == newSelection }) else {
						return
					}
					chartSelection = metrics.time
				}
			} else {
				VStack(spacing: 16) {
					Image(systemName: "slash.circle")
						.font(.system(size: 48))
						.foregroundColor(.secondary)
					Text("No Device Metrics")
						.font(.title2)
						.foregroundColor(.secondary)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.onAppear {
			refreshMetrics()
		}
		.onChange(of: node.lastHeard) {
			refreshMetrics()
		}
		.navigationTitle("Device Metrics Log")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				ConnectedDevice(deviceConnected: accessoryManager.isConnected, name: accessoryManager.activeConnection?.device.shortName ?? "?")
			}
		}
			.fileExporter(
				isPresented: $isExporting,
				document: CsvDocument(emptyCsv: exportString),
				contentType: .commaSeparatedText,
				defaultFilename: CsvDocument.exportFilename("\(node.user?.longName ?? "Node") \("Device Metrics Log".localized) \(Date.now.exportTimestamp)"),
				onCompletion: { result in
					switch result {
					case .success:
						self.isExporting = false
						Logger.services.info("Device metrics log download succeeded.")
					case .failure(let error):
						Logger.services.error("Device metrics log download failed: \(error.localizedDescription, privacy: .public)")
					}
				}
			)
	}

	private var chartView: some View {
		let batteryPoints = chartData.compactMap { point -> ChartDataPoint? in
			guard let time = point.time, let batteryLevel = point.batteryLevel else { return nil }
			return ChartDataPoint.fromDate(time, value: Double(batteryLevel))
		}

		let channelUtilPoints = chartData.compactMap { point -> ChartDataPoint? in
			guard let time = point.time, let channelUtil = point.channelUtilization else { return nil }
			return ChartDataPoint.fromDate(time, value: Double(channelUtil))
		}

		let airtimePoints = chartData.compactMap { point -> ChartDataPoint? in
			guard let time = point.time, let airUtil = point.airUtilTx else { return nil }
			return ChartDataPoint.fromDate(time, value: Double(airUtil))
		}

		let batterySeries = ChartSeriesData(
			id: "battery",
			name: horizontalSizeClass == .regular ? "Battery Level".localized : "Battery".localized,
			color: batteryChartColor,
			chartType: .line,
			points: batteryPoints,
			lineWidth: 2.0
		)

		let channelUtilSeries = ChartSeriesData(
			id: "channelUtil",
			name: "Channel Utilization".localized,
			color: channelUtilizationChartColor,
			chartType: .point,
			points: channelUtilPoints,
			lineWidth: 0,
			drawCircles: true,
			circleRadius: 5.0
		)

		let airtimeSeries = ChartSeriesData(
			id: "airtime",
			name: "Airtime".localized,
			color: airtimeChartColor,
			chartType: .point,
			points: airtimePoints,
			lineWidth: 0,
			drawCircles: true,
			circleRadius: 5.0
		)

		var ruleMarks: [DGRuleMark] = []
		// Add network status reference lines
		ruleMarks.append(DGRuleMark(
			position: 25,
			axis: .y,
			color: .orange,
			lineWidth: 1.0,
			dashPattern: [5, 10]
		))
		ruleMarks.append(DGRuleMark(
			position: 50,
			axis: .y,
			color: .red,
			lineWidth: 1.0,
			dashPattern: [5, 10]
		))

		if let chartSelection = chartSelection {
			ruleMarks.append(DGRuleMark(
				position: chartSelection.timeIntervalSince1970,
				axis: .x,
				color: .tertiary,
				lineWidth: 1.0,
				dashPattern: nil
			))
		}

		let xAxisConfig = DGChartXAxisConfig(
			position: .top,
			labelCount: 6,
			dateFormat: "MM/dd HH:mm"
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: 6,
			axisMinimum: 0,
			axisMaximum: 100
		)

		let legendConfig = DGChartLegendConfig(
			isEnabled: true,
			position: .belowChartCenter,
			alignment: .center,
			orientation: .horizontal
		)

		return CombinedChartView(
			data: [batterySeries, channelUtilSeries, airtimeSeries],
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: ruleMarks,
			yDomain: 0...100,
			visibleXRange: nil,
			scrollPosition: nil,
			isScrollable: false,
			legendHidden: false,
			frame: nil,
			selection: nil,
			onSelectionChanged: nil,
			backgroundColor: .systemBackground,
			gridColor: .systemGray4,
			gridLineWidth: 0.5,
			drawOrder: [.bar, .bubble, .line, .scatter, .candle]
		)
	}

	private func refreshMetrics() {
		totalReadings = node.telemetryCount(ofType: 0, context: context)
		deviceMetrics = node.safeTelemetries(ofType: 0)
		let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date.distantPast
		chartData = downsampledForChart(
			deviceMetrics
				.filter { ($0.time ?? Date.distantPast) >= oneWeekAgo }
				.sorted { ($0.time ?? .distantPast) < ($1.time ?? .distantPast) }
		)
	}
}

// TODO: Fix preview for SwiftData
/*
#Preview {
	let node = NodeInfoEntity()
	node.num = 123456789
	let user = UserEntity()
	user.longName = "Test Node"
	user.shortName = "TN"
	node.user = user
	DeviceMetricsLog(node: node)
		.environmentObject(AccessoryManager.shared)
		.modelContainer(PersistenceController.preview.container)
}
*/