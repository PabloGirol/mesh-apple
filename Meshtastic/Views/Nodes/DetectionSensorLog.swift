//
//  DetectionSensorLog.swift
//  Meshtastic
//
//  Created by Ben on 8/22/23.
//

import CoreData
import DGCharts
import MeshtasticProtobufs
import OSLog
import SwiftUI

struct DetectionSensorLog: View {
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
	@State private var detections: [MessageEntity] = []
	@State private var chartData: [MessageEntity] = []

	init(node: NodeInfoEntity) {
		self.node = node
	}

	var body: some View {
		VStack {
			if chartData.count > 0 {
				GroupBox(label: Label("\(chartData.count) Total Detection Events", systemImage: "sensor")) {
					chartView
				}
				.frame(minHeight: 250)
			}
			if showsWideTable {
				Table(detections) {
					TableColumn("Detection event") { d in
						Text(d.messagePayload ?? "Detected")
					}

					TableColumn("Timestamp") { d in
						Text(d.timestamp.formatted(date: .numeric, time: .shortened))
					}
					.width(min: 180)
				}
			} else {
				ScrollView {
					let columns = [
						GridItem(),
						GridItem()
					]
					LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
						GridRow {
							Text("Detection")
								.font(.caption)
								.fontWeight(.bold)
							Text("Timestamp")
								.font(.caption)
								.fontWeight(.bold)
						}
						ForEach(detections) { d in
							GridRow {
								Text(d.messagePayload ?? "Detected")
									.font(.caption)
								Text(d.timestamp.formatted(date: .numeric, time: .shortened))
									.font(.caption)
							}
						}
					}
					.padding(.leading, 15)
					.padding(.trailing, 5)
				}
			}
		}
		.onAppear {
			refreshDetections()
		}
		.onChange(of: node.lastHeard) {
			refreshDetections()
		}
		HStack {
			Button {
				exportString = detectionsToCsv(detections: chartData)
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
		.navigationTitle("Detection Sensor Log")
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
			defaultFilename: CsvDocument.exportFilename("\(node.user?.longName ?? "Node") \("Detection Sensor Log".localized) \(Date.now.exportTimestamp)"),
			onCompletion: { result in
				switch result {
				case .success:
					self.isExporting = false
					Logger.services.info("Detection Sensor metrics log download succeeded.")
				case .failure(let error):
					Logger.services.error("Detection Sensor log download failed: \(error.localizedDescription, privacy: .public).")
				}
			}
			)
	}

	private var chartView: some View {
		// Group by hour and count
		let calendar = Calendar.current
		let hourlyCounts = Dictionary(grouping: chartData) { message in
			calendar.dateInterval(of: .hour, for: message.timestamp)?.start ?? message.timestamp
		}.mapValues { $0.count }

		let sortedHours = hourlyCounts.keys.sorted()
		let points = sortedHours.map { hour in
			ChartDataPoint.fromDate(hour, value: Double(hourlyCounts[hour] ?? 0))
		}

		let seriesData = ChartSeriesData(
			id: "detections",
			name: "Detection events".localized,
			color: .green,
			chartType: .bar,
			points: points,
			lineWidth: 0,
			barWidth: 0.8
		)

		let xAxisConfig = DGChartXAxisConfig(
			position: .top,
			labelCount: 6,
			dateFormat: "MM/dd HH:mm"
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: 6,
			axisMinimum: 0
		)

		let legendConfig = DGChartLegendConfig(
			isEnabled: true,
			position: .belowChartCenter,
			alignment: .center,
			orientation: .horizontal
		)

		return BarChartView(
			data: [seriesData],
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: [],
			yDomain: nil,
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
		)
	}

	private func refreshDetections() {
		guard let nodeNum = node.user?.num else {
			detections = []
			chartData = []
			return
		}
		let portNum: Int32 = 10
		let sevenDaysAgoTimestamp = Int32((Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date.distantPast).timeIntervalSince1970)
		let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
		request.predicate = NSPredicate(format: "portNum == %d AND messageTimestamp >= %d AND fromUser.num == %lld", portNum, sevenDaysAgoTimestamp, nodeNum)
		request.sortDescriptors = [NSSortDescriptor(key: "messageTimestamp", ascending: false)]
		request.fetchLimit = 500
		detections = (try? context.fetch(request)) ?? []
		let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date.distantPast
		chartData = detections
			.filter { $0.timestamp >= oneDayAgo }
			.sorted { $0.timestamp < $1.timestamp }
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
	DetectionSensorLog(node: node)
		.environmentObject(AccessoryManager.shared)
		.modelContainer(PersistenceController.preview.container)
}
*/