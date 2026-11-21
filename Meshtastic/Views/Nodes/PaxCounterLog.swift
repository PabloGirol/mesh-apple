//
//  PaxCounterLog.swift
//  Meshtastic
//
//  Created by Garth Vander Houwen on 2/25/24.
//  Updated for DGCharts iOS 15 compatibility
//

import DGCharts
import OSLog
import SwiftUI

struct PaxCounterLog: View {

	@Environment(\.managedObjectContext) private var context
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass

	/// Table on iPhone shows only its first column, even in a regular size class.
	private var showsWideTable: Bool {
		horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom != .phone
	}
	@EnvironmentObject var accessoryManager: AccessoryManager

	@State private var isPresentingClearLogConfirm: Bool = false
	@State var isExporting = false
	@State var exportString = ""

	@State private var bleChartColor: Color = .blue
	@State private var wifiChartColor: Color = .orange
	@State private var paxChartColor: Color = .green
	var node: NodeInfoEntity
	@State private var paxCounters: [PaxCounterEntity] = []
	@State private var chartData: [PaxCounterEntity] = []
	@State private var maxValue: Int32 = 5
	@State private var totalReadings = 0

	@ViewBuilder
	private var chartView: some View {
		let paxPoints = chartData.compactMap { point -> ChartDataPoint? in
			guard let time = point.time else { return nil }
			return ChartDataPoint.fromDate(time, value: Double(point.wifi + point.ble))
		}

		let wifiPoints = chartData.compactMap { point -> ChartDataPoint? in
			guard let time = point.time else { return nil }
			return ChartDataPoint.fromDate(time, value: Double(point.wifi))
		}

		let blePoints = chartData.compactMap { point -> ChartDataPoint? in
			guard let time = point.time else { return nil }
			return ChartDataPoint.fromDate(time, value: Double(point.ble))
		}

		let paxSeries = ChartSeriesData(
			id: "total",
			name: "Total PAX".localized,
			color: paxChartColor,
			chartType: .point,
			points: paxPoints,
			lineWidth: 0,
			drawCircles: true,
			circleRadius: 5.0
		)

		let wifiSeries = ChartSeriesData(
			id: "wifi",
			name: "WiFi".localized,
			color: wifiChartColor,
			chartType: .point,
			points: wifiPoints,
			lineWidth: 0,
			drawCircles: true,
			circleRadius: 5.0
		)

		let bleSeries = ChartSeriesData(
			id: "ble",
			name: "BLE".localized,
			color: bleChartColor,
			chartType: .point,
			points: blePoints,
			lineWidth: 0,
			drawCircles: true,
			circleRadius: 5.0
		)

		let xAxisConfig = DGChartXAxisConfig(
			position: .top,
			labelCount: 6,
			dateFormat: "MM/dd HH:mm"
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: 6,
			axisMinimum: 0,
			axisMaximum: Double(maxValue)
		)

		let legendConfig = DGChartLegendConfig(
			isEnabled: true,
			position: .belowChartCenter,
			alignment: .center,
			orientation: .horizontal
		)

		return ScatterChartView(
			data: [paxSeries, wifiSeries, bleSeries],
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: [],
			yDomain: 0...Double(maxValue),
			visibleXRange: nil,
			scrollPosition: nil,
			isScrollable: false,
			legendHidden: false,
			frame: nil,
			selection: nil,
			onSelectionChanged: nil,
			backgroundColor: .systemBackground,
			gridColor: .systemGray4,
			gridLineWidth: 0.5
		)
	}

	var body: some View {
		VStack {
			if totalReadings > 0 {
				if chartData.count > 0 {
					GroupBox(label: Label("\(totalReadings) Readings Total", systemImage: "chart.xyaxis.line")) {
						chartView
					}
					.frame(minHeight: 250)
				}
				if showsWideTable {
					Table(paxCounters) {
						TableColumn("BLE") { pc in
							Text("\(pc.ble)")
						}
						TableColumn("WiFi") { pc in
							Text("\(pc.wifi)")
						}
						TableColumn("Total PAX") { pc in
							Text("\(pc.wifi + pc.ble)")
						}
						TableColumn("Uptime") { pc in
							let now = Date.now
							let later = now + TimeInterval(pc.uptime)
							let components = (now..<later).formatted(.components(style: .condensedAbbreviated))
							Text(components)
						}
						TableColumn("Timestamp") { pc in
							Text(pc.time?.formatted(date: .numeric, time: .shortened) ?? "Unknown Age".localized)
						}
						.width(min: 180)
					}
				} else {
					ScrollView {
						let columns = [
							GridItem(.flexible(minimum: 20, maximum: 50), spacing: 0.1),
							GridItem(.flexible(minimum: 20, maximum: 50), spacing: 0.1),
							GridItem(.flexible(minimum: 20, maximum: 50), spacing: 0.1),
							GridItem(.flexible(minimum: 60, maximum: 140), spacing: 0.1),
							GridItem(.flexible(minimum: 100, maximum: 160), spacing: 0.1)
						]
						LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
							GridRow {
								Text("BLE")
									.font(.caption)
									.fontWeight(.bold)
								Text("WiFi")
									.font(.caption)
									.fontWeight(.bold)
								Text("Total")
									.font(.caption)
									.fontWeight(.bold)
								Text("Uptime")
									.font(.caption)
									.fontWeight(.bold)
								Text("Timestamp")
									.font(.caption)
									.fontWeight(.bold)
							}
							ForEach(paxCounters) { pc in
								GridRow {
									Text(String(pc.ble))
										.font(.caption)
									Text(String(pc.wifi))
										.font(.caption)
									Text(String(pc.ble + pc.wifi))
										.font(.caption)
									let now = Date.now
									let later = now + TimeInterval(pc.uptime)
									let components = (now..<later).formatted(.components(style: .condensedAbbreviated))
									Text(components)
										.font(.caption)
									Text(pc.time?.formatted(date: .numeric, time: .shortened) ?? "Unknown Age".localized)
										.font(.caption)
								}
							}
						}
						.padding(.leading, 15)
						.padding(.trailing, 5)
					}
				}
					HStack {
						Button(role: .destructive) {
							isPresentingClearLogConfirm = true
						} label: {
							Label("Clear", systemImage: "trash.fill")
						}
						.buttonStyle(.bordered)
						.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
							view
								.buttonBorderShape(.capsule)
								.controlSize(.large)
						}
						.padding(.bottom)
						.padding(.leading)
						.hostedConfirmation(
							"Are you sure?",
							isPresented: $isPresentingClearLogConfirm,
							titleVisibility: .visible
						) {
							Button("Delete all pax data?", role: .destructive) {
								Task {
									if await MeshPackets.shared.clearPax(destNum: node.num) {
										Logger.services.info("Cleared Pax Counter for \(node.num, privacy: .public)")
										await MainActor.run {
											refreshPaxCounters()
											NotificationCenter.default.post(name: .nodeLogAvailabilityDidChange, object: node.num)
										}
									} else {
										Logger.services.error("Clear Pax Counter Log Failed")
									}
								}
							}
						}

						Button {
							exportString = paxToCsvFile(pax: node.paxCountersSortedByTime(context: context, ascending: true))
							isExporting = true
						} label: {
							Label("Save", systemImage: "square.and.arrow.down")
						}
						.hostedWindowOnly()
						.buttonStyle(.bordered)
						.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
							view
								.buttonBorderShape(.capsule)
								.controlSize(.large)
						}
						.padding(.bottom)
						.padding(.trailing)
					}
			} else {
				VStack(spacing: 16) {
					Image(systemName: "slash.circle")
						.font(.system(size: 48))
						.foregroundColor(.secondary)
					Text("No PAX Counter Logs")
						.font(.title2)
						.foregroundColor(.secondary)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.onAppear {
			refreshPaxCounters()
		}
		.onChange(of: node.lastHeard) {
			refreshPaxCounters()
		}
			.navigationTitle("PAX Counter Log")
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
				defaultFilename: CsvDocument.exportFilename("\(node.user?.longName ?? "Node") \("paxcounter.log".localized) \(Date.now.exportTimestamp)"),
				onCompletion: { result in
					switch result {
					case .success:
						self.isExporting = false
						Logger.services.info("PAX Counter log download succeeded")
					case .failure(let error):
						Logger.services.error("PAX Counter log download failed: \(error.localizedDescription, privacy: .public)")
					}
				}
			)
	}

	private func refreshPaxCounters() {
		totalReadings = node.paxCount(context: context)
		paxCounters = node.paxCountersSortedByTime(context: context, ascending: false, limit: 500)
		let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date.distantPast
		chartData = paxCounters
			.filter { ($0.time ?? Date.distantPast) >= oneWeekAgo }
			.sorted { ($0.time ?? .distantPast) < ($1.time ?? .distantPast) }
		maxValue = (chartData.map { $0.wifi }.max() ?? 0) + (chartData.map { $0.ble }.max() ?? 0) + 5
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
	PaxCounterLog(node: node)
		.environmentObject(AccessoryManager.shared)
		.modelContainer(PersistenceController.preview.container)
}
*/