//
//  LocalStatsLog.swift
//  Meshtastic
//
//  Copyright(c) Benjamin Faershtein 1/17/26.
//

import SwiftUI
import UIKit
import OSLog
import CoreData
import DGCharts

struct LocalStatsLog: View {

	@EnvironmentObject var accessoryManager: AccessoryManager
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass

	/// Table on iPhone shows only its first column, even in a regular size class.
	private var showsWideTable: Bool {
		horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom != .phone
	}

	@State private var isPresentingClearLogConfirm: Bool = false
	@State var isExporting = false
	@State var exportString = ""
	@State private var isPresentingNoiseFloorInfo = false

	var node: NodeInfoEntity
	@Environment(\.managedObjectContext) private var context
	@State private var sortOrder = [KeyPathComparator(\LocalStatsRow.time, order: .reverse)]
	@State private var selection: LocalStatsRow.ID?
	/// Set when a table row is picked so the chart scrolls to that reading.
	@State private var chartScrollTarget: LocalStatsChartScrollTarget?

	// Derived data is cached in @State and recomputed only when the underlying telemetry
	// changes (refreshData), NOT in `body`. The fetch runs on a background ModelActor
	// (LocalStatsFetchActor) and only value rows cross back. The chart's scroll
	// position lives in LocalStatsChart, so scrolling re-runs that view alone and
	// never this body with its table and toolbar. Recomputing these getters in `body`
	// fired ~8 fetches + sorts per frame and janked scrolling.
	@State private var localStats: [LocalStatsRow] = []
	@State private var noiseFloorReadings: [LocalStatsChartPoint] = []
	@State private var chartYDomain: ClosedRange<Int> = -130 ... -60
	@State private var didLoad = false
	/// The node the loaded rows belong to, so a node switch drops them before the new fetch.
	@State private var loadedNodeNum: Int64?
	@State private var refreshScheduled = false
	@State private var refreshTask: Task<Void, Never>?
	@State private var fetchActor: LocalStatsFetchActor?

	private var dateFormatString: String {
		let localeDateFormat = DateFormatter.dateFormat(fromTemplate: "yyMdjmma", options: 0, locale: Locale.current)
		return (localeDateFormat ?? "M/d/YY j:mma").replacingOccurrences(of: ",", with: "")
	}

	var body: some View {
		VStack {
			if !localStats.isEmpty {
				if !noiseFloorReadings.isEmpty {
					chartView
				}
				tableView
			} else if didLoad {
				VStack(spacing: 16) {
					Image(systemName: "waveform")
						.font(.system(size: 48))
						.foregroundColor(.secondary)
					Text("No Local Stats")
						.font(.title2)
						.foregroundColor(.secondary)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
			buttonView
		}
		.navigationTitle("Local Stats Log")
		.navigationBarTitleDisplayMode(.inline)
		.trackScreen(.localStatsLog)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				ConnectedDevice(deviceConnected: accessoryManager.isConnected, name: accessoryManager.activeConnection?.device.shortName ?? "?")
			}
			ToolbarItem(placement: .topBarLeading) {
				Button {
					isPresentingNoiseFloorInfo = true
				} label: {
					Label("Noise Floor Info", systemImage: "info.circle")
				}
			}
		}
		.hostedSheet(isPresented: $isPresentingNoiseFloorInfo) {
			SheetNavigationStack {
				NoiseFloorInfoView()
					.navigationTitle("Noise Floor")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .confirmationAction) {
							Button {
								isPresentingNoiseFloorInfo = false
							} label: {
								Image(systemName: "xmark")
							}
							.accessibilityLabel(String(localized: "Done", comment: "VoiceOver: dismiss the noise floor info sheet"))
						}
					}
			}
			.trackScreen(.noiseFloorInfo)
			.presentationDetents([.medium])
		}
		.fileExporter(
			isPresented: $isExporting,
			document: CsvDocument(emptyCsv: exportString),
			contentType: .commaSeparatedText,
			defaultFilename: CsvDocument.exportFilename("\(node.user?.longName ?? "Node") \("Local Stats Log".localized) \(Date.now.exportTimestamp)"),
			onCompletion: { result in
				switch result {
				case .success:
					self.isExporting = false
					Logger.services.info("Local stats log download succeeded.")
				case .failure(let error):
					Logger.services.error("Local stats log download failed: \(error.localizedDescription, privacy: .public)")
				}
			}
		)
		.task(id: node.num) {
			// The fetch runs on a background ModelActor, so the first frame and the
			// push animation never wait on it — it took hundreds of ms on the main
			// thread against a long-lived store and locked the app up on open.
			// Keyed on node.num: if this view position is reused for another node,
			// the pending work is cancelled and the new node's data loads.
			refreshTask?.cancel()
			if loadedNodeNum != node.num {
				// Another node's rows would build the new chart and set its position from
				// the wrong range, so clear them first; the chart appears with the new data.
				localStats = []
				noiseFloorReadings = []
				didLoad = false
			}
			await refreshData()
			if !Task.isCancelled { loadedNodeNum = node.num }
		}
		.onDisappear {
			refreshTask?.cancel()
		}
		.onChange(of: node.lastHeard) {
			// New packets (including local-stats telemetry) update lastHeard; refetch then.
			// Scrolling the chart does not touch lastHeard, so it never triggers a refetch.
			// Coalesced: lastHeard bumps at packet rate for the connected node, and an
			// unthrottled fetch-per-packet saturated the main thread on busy meshes.
			scheduleRefresh()
		}
	}

	private var chartView: some View {
		GroupBox {
			LocalStatsChart(readings: noiseFloorReadings, yDomain: chartYDomain, scrollTarget: chartScrollTarget)
				.id(node.num)
		} label: {
			Label("\(localStats.count) Local Stats Readings", systemImage: "chart.xyaxis.line")
		}
		.padding(.horizontal)
	}

	@ViewBuilder
	private var tableView: some View {
		if showsWideTable {
			macTableView
		} else {
			phoneTableView
		}
	}

	private var phoneTableView: some View {
		Table(localStats, selection: $selection, sortOrder: $sortOrder) {
			TableColumn("Local Stats") { ls in
				HStack {
					CopyableLocalStatsField(
						timestampText(for: ls),
						title: "Timestamp",
						font: .caption,
						fontWeight: .semibold
					)
					Spacer()
				}
				HStack {
					CopyableLocalStatsField(
						phoneNoiseFloorText(for: ls),
						title: "Noise Floor",
						color: noiseFloorTextColor(for: ls)
					)
					Spacer()
				}
				HStack {
					CopyableLocalStatsField("Relayed: \(ls.numTxRelay)", title: "Relayed")
					CopyableLocalStatsField("Canceled: \(ls.numTxRelayCanceled)", title: "Canceled")
					CopyableLocalStatsField("Dupes: \(ls.numRxDupe)", title: "Dupes")
					Spacer()
				}
				.font(.caption)
			}
			.width(ideal: 200, max: .infinity)
		}
	}

	private var macTableView: some View {
		Table(localStats, selection: $selection, sortOrder: $sortOrder) {
			TableColumn("Noise Floor") { ls in
				CopyableLocalStatsField(
					noiseFloorValueText(for: ls),
					title: "Noise Floor",
					color: noiseFloorTextColor(for: ls)
				)
			}
			TableColumn("Uptime") { ls in
				CopyableLocalStatsField(uptimeText(for: ls), title: "Uptime")
			}
			.width(min: 100)
			TableColumn("Relayed") { ls in
				CopyableLocalStatsField("\(ls.numTxRelay)", title: "Relayed")
			}
			.width(min: 80)
			TableColumn("Canceled") { ls in
				CopyableLocalStatsField("\(ls.numTxRelayCanceled)", title: "Canceled")
			}
			.width(min: 80)
			TableColumn("Dupes") { ls in
				CopyableLocalStatsField("\(ls.numRxDupe)", title: "Dupes")
			}
			.width(min: 80)
			TableColumn("Packets Tx") { ls in
				CopyableLocalStatsField("\(ls.numPacketsTx)", title: "Packets Tx")
			}
			.width(min: 80)
			TableColumn("Packets Rx") { ls in
				CopyableLocalStatsField("\(ls.numPacketsRx)", title: "Packets Rx")
			}
			.width(min: 80)
			TableColumn("Bad Rx") { ls in
				CopyableLocalStatsField("\(ls.numPacketsRxBad)", title: "Bad Rx")
			}
			.width(min: 80)
			TableColumn("Nodes Online") { ls in
				CopyableLocalStatsField("\(ls.numOnlineNodes)", title: "Nodes Online")
			}
			.width(min: 100)
			TableColumn("Timestamp") { ls in
				CopyableLocalStatsField(timestampText(for: ls), title: "Timestamp")
			}
			.width(min: 180)
		}
	}

	private var buttonView: some View {
		HStack(spacing: 8) {
			if !localStats.isEmpty {
				Button(role: .destructive) {
					isPresentingClearLogConfirm = true
				} label: {
					Label {
						Text("Clear")
							.lineLimit(1)
					} icon: {
						Image(systemName: "trash.fill")
					}
				}
				.buttonStyle(.bordered)
				.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
					view
						.buttonBorderShape(.capsule)
						.controlSize(horizontalSizeClass == .regular ? .large : .regular)
				}
				.hostedConfirmation(
					"Are you sure?",
					isPresented: $isPresentingClearLogConfirm,
					titleVisibility: .visible
				) {
					Button("Delete all local stats?", role: .destructive) {
						Task { @MainActor in
							if await MeshPackets.shared.clearTelemetry(destNum: node.num, metricsType: 4) {
								Logger.data.notice("Cleared Local Stats for \(node.num, privacy: .public)")
								await refreshData()
							} else {
								Logger.data.error("Clear Local Stats Log Failed")
							}
						}
					}
				}
			}

			RequestLocalStatsButton(
				node: node,
				title: "Request",
				cooldownTitle: "Wait",
				systemImage: "arrow.clockwise"
			)
			.buttonStyle(.bordered)
			.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
				view
					.buttonBorderShape(.capsule)
					.controlSize(horizontalSizeClass == .regular ? .large : .regular)
			}

			if !localStats.isEmpty {
				Button {
					exportString = localStatsCsv(rows: localStats)
					isExporting = true
				} label: {
					Label {
						Text("Save")
							.lineLimit(1)
					} icon: {
						Image(systemName: "square.and.arrow.down")
					}
				}
				.hostedWindowOnly()
				.buttonStyle(.bordered)
				.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
					view
						.buttonBorderShape(.capsule)
						.controlSize(horizontalSizeClass == .regular ? .large : .regular)
				}
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal)
		.padding(.bottom)
		.onChange(of: selection) { _, newSelection in
			guard let metrics = localStats.first(where: { $0.id == newSelection }) else {
				return
			}
			if let time = metrics.time {
				chartScrollTarget = LocalStatsChartScrollTarget(date: time, serial: (chartScrollTarget?.serial ?? 0) + 1)
			}
		}
	}

	private func noiseFloorColor(_ value: Int32) -> Color {
		if value < -95 {
			return .green
		} else if value < -90 {
			return .orange
		} else {
			return .red
		}
	}

	private func timestampText(for localStats: LocalStatsRow) -> String {
		localStats.time?.formattedDate(format: dateFormatString) ?? "Unknown Age".localized
	}

	private func phoneNoiseFloorText(for localStats: LocalStatsRow) -> String {
		guard let noiseFloor = localStats.noiseFloor else {
			return "Noise Floor No Reading"
		}
		return "Noise Floor \(noiseFloor) dBm"
	}

	private func noiseFloorValueText(for localStats: LocalStatsRow) -> String {
		guard let noiseFloor = localStats.noiseFloor else {
			return "No Reading"
		}
		return "\(noiseFloor) dBm"
	}

	private func noiseFloorTextColor(for localStats: LocalStatsRow) -> Color {
		guard let noiseFloor = localStats.noiseFloor else {
			return .gray
		}
		return noiseFloorColor(noiseFloor)
	}

	private func uptimeText(for localStats: LocalStatsRow) -> String {
		guard let uptimeSeconds = localStats.uptimeSeconds else {
			return Constants.nilValueIndicator
		}
		let now = Date.now
		let later = now + TimeInterval(uptimeSeconds)
		return (now..<later).formatted(.components(style: .narrow))
	}
}

private extension LocalStatsLog {
	/// Coalesces refetches: the connected node's lastHeard changes with every packet,
	/// and one fetch per packet hung the app on busy meshes. At most one refresh runs
	/// per two-second window, trailing, so the last packet in a burst is always picked
	/// up. The pending task is cancelled on disappear and on node change so a stale
	/// refresh can't write another node's rows into this view.
	@MainActor
	func scheduleRefresh() {
		guard !refreshScheduled else { return }
		refreshScheduled = true
		refreshTask = Task { @MainActor in
			defer { refreshScheduled = false }
			try? await Task.sleep(nanoseconds: 2_000_000_000)
			guard !Task.isCancelled else { return }
			await refreshData()
		}
	}

	/// Single source of the view's derived data. Fetches on a background ModelActor —
	/// the predicate scan takes hundreds of ms on a long-lived store and must never
	/// block the main actor — then recomputes the cached chart inputs from the value
	/// rows. Called on appear, when the node hears new packets, and after a clear —
	/// never from `body`, so chart scrolling does no fetching or sorting.
	@MainActor
	func refreshData() async {
		let fetcher: LocalStatsFetchActor
		if let fetchActor {
			fetcher = fetchActor
		} else {
			fetcher = LocalStatsFetchActor(modelContainer: CoreDataStackImpl.shared.container)
			fetchActor = fetcher
		}
		let stats = await fetcher.rows(nodeNum: node.num)
		guard !Task.isCancelled else { return }
		localStats = stats

		// The fetch returns rows sorted by time descending; compactMap preserves
		// that order, and plottable reverses it to ascending without a second sort
		// while leaving readings with a wrong clock off the chart.
		let readings = LocalStatsChartPoint.plottable(
			stats.compactMap { point -> LocalStatsChartPoint? in
				guard let time = point.time, let noiseFloor = point.noiseFloor else { return nil }
				return LocalStatsChartPoint(time: time, noiseFloor: noiseFloor)
			},
			now: .now
		)
		noiseFloorReadings = downsampledForChart(readings)

		let values = readings.map { Int($0.noiseFloor) }
		if let minValue = values.min(), let maxValue = values.max() {
			chartYDomain = min(minValue - 5, -115) ... max(maxValue + 5, -75)
		} else {
			chartYDomain = -130 ... -60
		}

		didLoad = true
	}
}

private struct CopyableLocalStatsField: View {
	let value: String
	let title: String
	let font: Font?
	let fontWeight: Font.Weight?
	let color: Color?

	init(
		_ value: String,
		title: String,
		font: Font? = nil,
		fontWeight: Font.Weight? = nil,
		color: Color? = nil
	) {
		self.value = value
		self.title = title
		self.font = font
		self.fontWeight = fontWeight
		self.color = color
	}

	var body: some View {
		Text(value)
			.font(font)
			.fontWeight(fontWeight)
			.foregroundColor(color)
			.textSelection(.enabled)
			.contextMenu {
				Button {
					UIPasteboard.general.string = value
				} label: {
					Label("Copy \(title)", systemImage: "doc.on.doc")
				}
			}
	}
}

/// A request from the table to scroll the chart to a reading. The serial makes
/// picking the same row again scroll again.
private struct LocalStatsChartScrollTarget: Equatable {
	let date: Date
	let serial: Int
}

/// The noise floor chart with its range picker and Latest button. It owns the scroll
/// position, so scrolling re-runs this view and not the table, toolbar and buttons
/// around it.
private struct LocalStatsChart: View {
	let readings: [LocalStatsChartPoint]
	let yDomain: ClosedRange<Int>
	let scrollTarget: LocalStatsChartScrollTarget?

	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@State private var selectedChartRange: LocalStatsChartRange = .day
	@State private var chartScrollPosition = Date()
	@State private var xAxisTicks: [Date] = []

	/// What the ticks depend on. The scroll position is rounded down to the tick
	/// step, so this only changes when the window crosses a step boundary.
	private struct TickKey: Equatable {
		let visible: TimeInterval
		let labelCount: Int
		let position: Date
		let dataRange: ClosedRange<Date>?
		/// The zone's identifier, so a zone change refreshes the ticks.
		let timeZone: String
	}

	private var dataRange: ClosedRange<Date>? {
		guard let first = readings.first?.time, let last = readings.last?.time else { return nil }
		return min(first, last)...max(first, last)
	}

	private var dataDuration: TimeInterval {
		guard let dataRange else { return LocalStatsChartRange.minimumVisibleDuration }
		return max(dataRange.upperBound.timeIntervalSince(dataRange.lowerBound), LocalStatsChartRange.minimumVisibleDuration)
	}

	private var visibleDuration: TimeInterval {
		visibleDuration(for: selectedChartRange)
	}

	private var xAxisLabelCount: Int {
		horizontalSizeClass == .regular ? 6 : 2
	}

	private var xAxisFormat: Date.FormatStyle {
		let dayDuration = LocalStatsChartRange.day.duration ?? 24 * 60 * 60
		let step = LocalStatsChartTicks.step(visible: visibleDuration, labelCount: xAxisLabelCount)
		if step >= dayDuration {
			return Date.FormatStyle()
				.month(.defaultDigits)
				.day(.defaultDigits)
		}
		// With AM/PM a 12-hour clock tells midnight from noon on the 24h view;
		// a 24-hour clock shows 00:00 and 12:00 either way. Two-digit minutes, or
		// some 24-hour locales show 17:0.
		let time = Date.FormatStyle()
			.hour(.defaultDigits(amPM: .abbreviated))
			.minute(.twoDigits)
		// Ticks less than a day apart on a window longer than a day need the date too,
		// or the same time repeats on each day.
		return visibleDuration <= dayDuration ? time : time.month(.defaultDigits).day(.defaultDigits)
	}

	private var tickKey: TickKey {
		let step = LocalStatsChartTicks.step(visible: visibleDuration, labelCount: xAxisLabelCount)
		return TickKey(
			visible: visibleDuration,
			labelCount: xAxisLabelCount,
			position: LocalStatsChartTicks.quantize(chartScrollPosition, step: step),
			dataRange: dataRange,
			timeZone: TimeZone.current.identifier
		)
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			controlsView
			chart
		}
		.onAppear {
			resetToLatest()
			// iOS 15 fallback for onChange(initial: true)
			if let range = tickKey.dataRange {
				xAxisTicks = LocalStatsChartTicks.ticks(
					visible: tickKey.visible,
					labelCount: tickKey.labelCount,
					scrollPosition: tickKey.position,
					dataRange: range,
					timeZone: .current
				)
			} else {
				xAxisTicks = []
			}
		}
		.onChange(of: tickKey) { _, key in
			guard let range = key.dataRange else {
				xAxisTicks = []
				return
			}
			xAxisTicks = LocalStatsChartTicks.ticks(
				visible: key.visible,
				labelCount: key.labelCount,
				scrollPosition: key.position,
				dataRange: range,
				timeZone: .current
			)
		}
		.onChange(of: selectedChartRange) { _, newRange in
			resetToLatest(for: newRange)
		}
		.onChange(of: scrollTarget) { _, target in
			if let target {
				chartScrollPosition = scrollStart(containing: target.date)
			}
		}
		.onChange(of: dataRange) { _, range in
			// A refresh can move the data out from under the position: with 500 rows
			// the fetch drops the oldest on every new reading, and a reading with a
			// wrong clock can drop off the chart. Keep the position inside the data
			// rather than jumping to the newest reading.
			guard let range else { return }
			let newestStart = max(range.lowerBound, range.upperBound.addingTimeInterval(-visibleDuration))
			let clamped = min(max(chartScrollPosition, range.lowerBound), newestStart)
			if clamped != chartScrollPosition {
				chartScrollPosition = clamped
			}
		}
	}

	private var controlsView: some View {
		HStack(spacing: 8) {
			Picker("Visible Range", selection: $selectedChartRange) {
				ForEach(LocalStatsChartRange.allCases) { range in
					Text(range.title).tag(range)
				}
			}
			.pickerStyle(.segmented)

			Button {
				resetToLatest()
			} label: {
				Label("Latest", systemImage: "forward.end")
					.labelStyle(.iconOnly)
			}
			.buttonStyle(.bordered)
			.ifAvailable(.init(iOS: 16, macOS: 13)) { view in
				view
					.buttonBorderShape(.capsule)
					.controlSize(.small)
			}
			.accessibilityHint(String(localized: "Scrolls the chart to the newest reading", comment: "VoiceOver hint for the scroll-to-latest chart button"))
		}
	}

	private var chart: some View {
		let chartData = readings.map { point in
			ChartDataPoint.fromDate(point.time, value: Double(point.noiseFloor))
		}

		let seriesData = ChartSeriesData(
			id: "noiseFloor",
			name: "Noise Floor",
			color: .accentColor,
			chartType: .line,
			points: chartData,
			lineWidth: 2.0,
			drawCircles: readings.count == 1
		)

		let ruleMarks = [
			DGRuleMark(
				position: -85,
				axis: .y,
				color: .red,
				lineWidth: 1.0,
				dashPattern: [5, 5],
				label: "Busy Floor (-85 dBm)"
			)
		]

		let xAxisConfig = DGChartXAxisConfig(
			position: .bottom,
			labelCount: xAxisLabelCount,
			dateFormat: dateFormatStringForDGCharts(visibleDuration),
			customFormatter: nil,
			granularity: 1,
			granularityEnabled: false
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: 6,
			axisMinimum: Double(yDomain.lowerBound),
			axisMaximum: Double(yDomain.upperBound),
			granularity: 10,
			granularityEnabled: false
		)

		let legendConfig = DGChartLegendConfig(isEnabled: false)

		return LineChartView(
			data: [seriesData],
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: ruleMarks,
			yDomain: Double(yDomain.lowerBound)...Double(yDomain.upperBound),
			visibleXRange: visibleDuration,
			scrollPosition: $chartScrollPosition,
			isScrollable: true,
			legendHidden: true,
			frame: CGSize(width: 0, height: horizontalSizeClass == .regular ? 320 : 240),
			selection: nil,
			onSelectionChanged: nil,
			backgroundColor: .systemBackground,
			gridColor: .systemGray4,
			gridLineWidth: 0.5,
			drawCircles: readings.count == 1,
			circleRadius: 4.0,
			mode: .linear,
			cubicIntensity: 0.2,
			drawFilled: false,
			fillAlpha: 0.3
		)
		.padding(.bottom, 8)
	}

	private func dateFormatStringForDGCharts(_ visibleDuration: TimeInterval) -> String {
		let dayDuration = LocalStatsChartRange.day.duration ?? 24 * 60 * 60
		let step = LocalStatsChartTicks.step(visible: visibleDuration, labelCount: xAxisLabelCount)
		if step >= dayDuration {
			return "MM/dd"
		}
		return "h:mm a"
	}

	private func visibleDuration(for range: LocalStatsChartRange) -> TimeInterval {
		guard let duration = range.duration else {
			return dataDuration
		}
		return min(duration, dataDuration)
	}

	private func resetToLatest(for range: LocalStatsChartRange? = nil) {
		guard let dataRange else { return }
		let duration = visibleDuration(for: range ?? selectedChartRange)
		chartScrollPosition = max(dataRange.lowerBound, dataRange.upperBound.addingTimeInterval(-duration))
	}

	private func scrollStart(containing date: Date) -> Date {
		guard let dataRange else { return date }
		let lowerBound = dataRange.lowerBound
		let upperBound = max(lowerBound, dataRange.upperBound.addingTimeInterval(-visibleDuration))
		let centeredStart = date.addingTimeInterval(-visibleDuration / 2)
		return min(max(centeredStart, lowerBound), upperBound)
	}
}

/// Value snapshot of one local-stats telemetry row. The fetch runs on a background
/// ModelActor, and value types are what may cross back to the main actor.
struct LocalStatsRow: Identifiable, Sendable {
	let id: NSManagedObjectID
	let time: Date?
	let noiseFloor: Int32?
	let uptimeSeconds: Int32?
	let numTxRelay: Int32
	let numTxRelayCanceled: Int32
	let numRxDupe: Int32
	let numPacketsTx: Int32
	let numPacketsRx: Int32
	let numPacketsRxBad: Int32
	let numOnlineNodes: Int32
	let numTotalNodes: Int32
}

/// Fetches the node's local-stats telemetry on a background context so the main actor
/// never blocks on the (unindexed) predicate scan — same pattern as MessageSearchActor.
actor LocalStatsFetchActor {
	let modelContext: NSManagedObjectContext

	init(modelContainer: NSPersistentContainer) {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = modelContainer.persistentStoreCoordinator
		context.automaticallyMergesChangesFromParent = true
		self.modelContext = context
	}

	func rows(nodeNum: Int64) -> [LocalStatsRow] {
		var descriptor = NSFetchRequest<TelemetryEntity>(entityName: "TelemetryEntity")
		descriptor.predicate = TelemetryEntity.predicate(forNode: nodeNum, metricsType: 4)
		descriptor.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		descriptor.fetchLimit = 500
		let entities = (try? modelContext.fetch(descriptor)) ?? []
		return entities.map { telemetry in
			LocalStatsRow(
				id: telemetry.objectID,
				time: telemetry.time,
				noiseFloor: telemetry.noiseFloor,
				uptimeSeconds: telemetry.uptimeSeconds,
				numTxRelay: telemetry.numTxRelay,
				numTxRelayCanceled: telemetry.numTxRelayCanceled,
				numRxDupe: telemetry.numRxDupe,
				numPacketsTx: telemetry.numPacketsTx,
				numPacketsRx: telemetry.numPacketsRx,
				numPacketsRxBad: telemetry.numPacketsRxBad,
				numOnlineNodes: telemetry.numOnlineNodes,
				numTotalNodes: telemetry.numTotalNodes
			)
		}
	}
}

/// Same columns and formatting as `telemetryToCsvFile`'s local-stats branch, built
/// from the value rows this view holds instead of live entities.
private func localStatsCsv(rows: [LocalStatsRow]) -> String {
	var csvString = "Noise Floor, Uptime, Relayed, Canceled, Dupes, Packets Tx, Packets Rx, Bad Rx, Nodes Online, Total Nodes, \("Timestamp".localized)"
	for row in rows {
		csvString += "\n"
		csvString += row.noiseFloor?.formatted(.number.grouping(.never)) ?? ""
		csvString += ", "
		csvString += row.uptimeSeconds?.formatted(.number.grouping(.never)) ?? ""
		csvString += ", "
		csvString += row.numTxRelay.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.numTxRelayCanceled.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.numRxDupe.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.numPacketsTx.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.numPacketsRx.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.numPacketsRxBad.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.numOnlineNodes.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.numTotalNodes.formatted(.number.grouping(.never))
		csvString += ", "
		csvString += row.time?.formatted(date: .numeric, time: .shortened).replacing(",", with: "") ?? ""
	}
	return csvString
}

private enum LocalStatsChartRange: String, CaseIterable, Identifiable {
	case hour
	case sixHours
	case day
	case week
	case all

	static let minimumVisibleDuration: TimeInterval = 15 * 60

	var id: String { rawValue }

	var title: String {
		switch self {
		case .hour:
			return "1h"
		case .sixHours:
			return "6h"
		case .day:
			return "24h"
		case .week:
			return "7d"
		case .all:
			return "All"
		}
	}

	var duration: TimeInterval? {
		switch self {
		case .hour:
			return 60 * 60
		case .sixHours:
			return 6 * 60 * 60
		case .day:
			return 24 * 60 * 60
		case .week:
			return 7 * 24 * 60 * 60
		case .all:
			return nil
		}
	}
}

private struct NoiseFloorInfoView: View {
	var body: some View {
		List {
			Section {
				Label("Lower values usually mean a quieter receiver environment.", systemImage: "speaker.wave.1")
				Label("Readings can vary quickly with nearby transmitters, antenna setup, filters, and local interference.", systemImage: "antenna.radiowaves.left.and.right")
				Label("The red reference line marks a busy -85 dBm floor, not a hard failure threshold.", systemImage: "exclamationmark.triangle")
			} header: {
				Text("How to read it")
			}
		}
	}
}