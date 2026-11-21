//
//  EnvironmentMetricsLog.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 7/7/22.
//  Updated for DGCharts iOS 15 compatibility
//

import CoreData
import DGCharts
import OSLog
import SwiftUI

struct EnvironmentMetricsLog: View {
	@Environment(\.managedObjectContext) private var context
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@EnvironmentObject var accessoryManager: AccessoryManager

	/// Table on iPhone shows only its first column, even in a regular size class.
	private var showsColumnGrid: Bool {
		horizontalSizeClass != .regular || UIDevice.current.userInterfaceIdiom == .phone
	}
	@State private var isPresentingClearLogConfirm: Bool = false
	@State var isExporting = false
	@State var exportString = ""
	var node: NodeInfoEntity

	@StateObject var columnList = MetricsColumnList.environmentDefaultColumns
	@StateObject var seriesList = MetricsSeriesList.environmentDefaultChartSeries

	@State var isEditingColumnConfiguration = false
	@State private var chartData: [TelemetryEntity] = []
	/// Chart input only — the table and export use `chartData` in full.
	@State private var chartPoints: [TelemetryEntity] = []
	@State private var totalReadings = 0

	var body: some View {
		VStack {
			if totalReadings > 0 {
				let chartRange = applyMargins(seriesList.chartRange(forData: chartPoints))
				VStack {
					if chartData.count > 0 {
						GroupBox(label: Label("\(totalReadings) Readings Total", systemImage: "chart.xyaxis.line")) {
							chartView(chartRange: chartRange)
						}
					}

					// Dynamic table column using SwiftUI Table requires TableColumnForEach which requires the target
					// to be bumped to 17.4 -- Until that happens, the existing non-configurable table is used.
					if showsColumnGrid {
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
					} else {
						Table(chartData) {
							TableColumnForEach(columnList.visible) { col in
								TableColumn(col.name) { em in
									col.body(em)
								}
							}
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
							Button("Delete all environment metrics?", role: .destructive) {
								Task {
									if await MeshPackets.shared.clearTelemetry(destNum: node.num, metricsType: 1) {
										Logger.services.info("Cleared Environment Metrics for \(node.num, privacy: .public)")
										await MainActor.run {
											refreshMetrics()
											NotificationCenter.default.post(name: .nodeLogAvailabilityDidChange, object: node.num)
										}
									} else {
										Logger.services.error("Clear Environment Metrics Log Failed")
									}
								}
							}
					}
					Button {
						exportString = telemetryToCsvFile(telemetry: chartData, metricsType: 1)
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
					Text("No Environment Metrics")
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

		.navigationTitle("Environment Metrics Log")
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
			defaultFilename: CsvDocument.exportFilename("\(node.user?.longName ?? "Node") Environment Metrics Log \(Date.now.exportTimestamp)"),
			onCompletion: { result in
				switch result {
				case .success:
					self.isExporting = false
					Logger.services.info("Environment metrics log download succeeded.")
				case .failure(let error):
					Logger.services.error("Environment metrics log download failed: \(error.localizedDescription, privacy: .public)")
				}
			}
		)
	}

	// Helper.  Adds a little buffer to the Y axis range, but keeps Y=0
	func applyMargins<T>(_ range: ClosedRange<T>) -> ClosedRange<T> where T: BinaryFloatingPoint {
		let span = range.upperBound - range.lowerBound
		let margin = span * 0.1
		let lower = range.lowerBound == 0.0 ? 0.0  : range.lowerBound - margin
		let upper = range.upperBound + margin
		return lower...upper
	}

	private func refreshMetrics() {
		totalReadings = node.telemetryCount(ofType: 1, context: context)
		let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date.distantPast
		chartData = node.safeTelemetries(ofType: 1)
			.filter { ($0.time ?? Date.distantPast) >= oneWeekAgo }
			.sorted { ($0.time ?? .distantPast) > ($1.time ?? .distantPast) }
		// chartData is sorted newest-first for the table; the chart wants the visible
		// window oldest-first, decimated AFTER the week filter so the mark budget is
		// spent entirely on points the chart will draw.
		chartPoints = downsampledForChart(Array(chartData.reversed()))
	}

	@ViewBuilder
	private func chartView(chartRange: ClosedRange<Float>) -> some View {
		let visibleSeries = seriesList.visible

		// Convert series to DGCharts data
		let chartSeriesData = visibleSeries.compactMap { series -> ChartSeriesData? in
			let points = chartPoints.compactMap { entity -> ChartDataPoint? in
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

		// Determine chart type based on series
		let hasAreaSeries = chartSeriesData.contains { $0.chartType == .area }
		let hasBarSeries = chartSeriesData.contains { $0.chartType == .bar }
		let hasLineSeries = chartSeriesData.contains { $0.chartType == .line }
		let hasPointSeries = chartSeriesData.contains { $0.chartType == .point }

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

		if hasBarSeries {
			return AnyView(BarChartView(
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
				barWidth: 0.8,
				groupSpace: 0.1
			))
		} else if hasAreaSeries || hasLineSeries {
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
				drawCircles: hasPointSeries,
				circleRadius: 4.0,
				mode: .linear,
				cubicIntensity: 0.2,
				drawFilled: hasAreaSeries,
				fillAlpha: 0.3
			))
		} else {
			return AnyView(CombinedChartView(
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
				drawOrder: [.bar, .bubble, .line, .scatter, .candle]
			))
		}
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
	EnvironmentMetricsLog(node: node)
		.environmentObject(AccessoryManager.shared)
		.modelContainer(PersistenceController.preview.container)
}
*/