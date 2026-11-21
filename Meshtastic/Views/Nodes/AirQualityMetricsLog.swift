//
//  AirQualityMetricsLog.swift
//  Meshtastic
//
//  Particulate-matter (PM) air quality telemetry log (issue #2040).
//  Updated for DGCharts iOS 15 compatibility
//

import CoreData
import DGCharts
import OSLog
import SwiftUI

struct AirQualityMetricsLog: View {
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
	var node: NodeInfoEntity

	@StateObject var columnList = MetricsColumnList.airQualityDefaultColumns
	@StateObject var seriesList = MetricsSeriesList.airQualityDefaultChartSeries

	@State var isEditingColumnConfiguration = false
	@State private var chartData: [TelemetryEntity] = []
	@State private var totalReadings = 0

	// AirQualityMetrics telemetry is stored with metricsType 3.
	private let metricsType: Int32 = 3

	var body: some View {
		VStack {
			// Gate on recent (last 7 days) data, not the all-time count: a node with only older
			// readings would otherwise satisfy the count but render an empty chart/table.
			if !chartData.isEmpty {
				let chartRange = applyMargins(seriesList.chartRange(forData: chartData))
				VStack {
					if chartData.count > 0 {
						GroupBox(label: Label("\(totalReadings) Readings Total", systemImage: "chart.xyaxis.line")) {
							chartView(chartRange: chartRange)
						}
					}

					// Dynamic table column using SwiftUI Table requires TableColumnForEach which requires the target
					// to be bumped to 17.4 -- Until that happens, the existing non-configurable table is used.
					if showsWideTable {
						Table(chartData) {
							TableColumnForEach(columnList.visible) { col in
								TableColumn(col.name) { em in
									col.body(em)
								}
							}
						}
					} else {
						ScrollView {
							LazyVGrid(columns: columnList.gridItems, alignment: .leading, spacing: 1, pinnedViews: [.sectionHeaders]) {
								GridRow {
									ForEach(columnList.visible) { col in
										Text(col.abbreviatedName)
											.font(.caption)
											.fontWeight(.bold)
									}
								}
								ForEach(chartData) { em  in
									GridRow {
										ForEach(columnList.visible) { col in
											col.body(em)
												.font(.caption)
										}
									}
								}
							}
							.padding(.leading, 15)
							.padding(.trailing, 5)
						}
					}
				}
				HStack {
					let wide = horizontalSizeClass == .regular
					let buttonSize: ControlSize = wide ? .large : .small
					let imageScale: Image.Scale = wide ? .medium : .small
					Button {
						self.isEditingColumnConfiguration = true
					} label: {
						Label("Config", systemImage: "tablecells")
							.imageScale(imageScale)
					}
					.buttonStyle(.bordered)
					.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
						view
							.buttonBorderShape(.capsule)
							.controlSize(buttonSize)
					}
					.padding(.bottom)
					.padding(.leading)
					.hostedSheet(isPresented: self.$isEditingColumnConfiguration) {
						MetricsColumnDetail(columnList: columnList, seriesList: seriesList)
					}
					Button(role: .destructive) {
						isPresentingClearLogConfirm = true
					} label: {
						Label("Clear", systemImage: "trash.fill")
							.imageScale(imageScale)
					}
					.buttonStyle(.bordered)
					.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
						view
							.buttonBorderShape(.capsule)
							.controlSize(buttonSize)
					}
					.padding(.bottom)
					.hostedConfirmation(
						"Are you sure?",
						isPresented: $isPresentingClearLogConfirm,
						titleVisibility: .visible
						) {
							Button("Delete all air quality metrics?", role: .destructive) {
								Task {
									if await MeshPackets.shared.clearTelemetry(destNum: node.num, metricsType: metricsType) {
										Logger.services.info("Cleared Air Quality Metrics for \(node.num, privacy: .public)")
										await MainActor.run {
											refreshMetrics()
											NotificationCenter.default.post(name: .nodeLogAvailabilityDidChange, object: node.num)
										}
									} else {
										Logger.services.error("Clear Air Quality Metrics Log Failed")
									}
								}
							}
					}
					Button {
						exportString = telemetryToCsvFile(telemetry: chartData, metricsType: Int(metricsType))
						isExporting = true
					} label: {
						Label("Save", systemImage: "square.and.arrow.down")
							.imageScale(imageScale)
					}
					.hostedWindowOnly()
					.buttonStyle(.bordered)
					.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
						view
							.buttonBorderShape(.capsule)
							.controlSize(buttonSize)
					}
					.padding(.bottom)
					.padding(.trailing)
				}

			} else {
				VStack(spacing: 16) {
					Image(systemName: "slash.circle")
						.font(.system(size: 48))
						.foregroundColor(.secondary)
					Text("No Air Quality Metrics")
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

		.navigationTitle("Air Quality Metrics Log")
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
			defaultFilename: CsvDocument.exportFilename("\(node.user?.longName ?? "Node") Air Quality Metrics Log \(Date.now.exportTimestamp)"),
			onCompletion: { result in
				switch result {
				case .success:
					self.isExporting = false
					Logger.services.info("Air quality metrics log download succeeded.")
				case .failure(let error):
					Logger.services.error("Air quality metrics log download failed: \(error.localizedDescription, privacy: .public)")
				}
			}
		)
	}

	// Helper.  Adds a little buffer to the Y axis range, but keeps Y=0
	func applyMargins<T>(_ range: ClosedRange<T>) -> ClosedRange<T> where T: BinaryFloatingPoint {
		let span = range.upperBound - range.lowerBound
		// Constant readings produce a zero span (e.g. 42...42), a degenerate Y domain SwiftUI can't
		// render — fall back to a minimum margin derived from the value (or a fixed floor at 0).
		let margin = span > 0 ? span * 0.1 : Swift.max(range.upperBound * T(0.1), T(1))
		let lower = range.lowerBound == 0.0 ? 0.0  : range.lowerBound - margin
		let upper = range.upperBound + margin
		return lower...upper
	}

	private func refreshMetrics() {
		totalReadings = node.telemetryCount(ofType: metricsType, context: context)
		let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date.distantPast
		chartData = node.safeTelemetries(ofType: metricsType)
			.filter { ($0.time ?? Date.distantPast) >= oneWeekAgo }
			.sorted { ($0.time ?? .distantPast) > ($1.time ?? .distantPast) }
	}

	@ViewBuilder
	private func chartView(chartRange: ClosedRange<Float>) -> some View {
		let visibleSeries = seriesList.visible

		// Convert series to DGCharts data
		let chartSeriesData = visibleSeries.compactMap { series -> ChartSeriesData? in
			let points = chartData.compactMap { entity -> ChartDataPoint? in
				guard let time = entity.time, let value = series.valueFor(entity) else { return nil }
				return ChartDataPoint(x: time.timeIntervalSince1970, y: Double(value))
			}
			guard !points.isEmpty else { return nil }

			return series.toChartSeriesData(points: points)
		}

		guard !chartSeriesData.isEmpty else {
			return Text("No data to display")
				.frame(height: 200)
				.foregroundStyle(.secondary)
		}

		let xAxisConfig = DGChartXAxisConfig(
			position: .top,
			labelCount: 6,
			dateFormat: "MM/dd HH:mm"
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: 6,
			axisMinimum: chartRange.lowerBound,
			axisMaximum: chartRange.upperBound
		)

		let legendConfig = DGChartLegendConfig(
			isEnabled: true,
			position: .belowChartCenter,
			alignment: .center,
			orientation: .horizontal
		)

		return AnyView(LineChartView(
			data: chartSeriesData,
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: [],
			yDomain: chartRange.lowerBound...chartRange.upperBound,
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
			drawCircles: false,
			circleRadius: 4.0,
			mode: .linear,
			cubicIntensity: 0.2,
			drawFilled: false,
			fillAlpha: 0.3
		))
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
	AirQualityMetricsLog(node: node)
		.environmentObject(AccessoryManager.shared)
		.modelContainer(PersistenceController.preview.container)
}
*/