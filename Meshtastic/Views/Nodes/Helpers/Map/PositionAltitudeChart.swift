//
//  PositionAltitudeChart.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 11/17/23.
//  Updated for DGCharts iOS 15 compatibility
//

import CoreData
import DGCharts
import MapKit
import SwiftUI

struct PositionAltitude {
	let time: Date
	var altitude: Measurement<UnitLength>
}

struct PositionAltitudeChart: View {
	private let visiblePositionLimit = 1_000

	@Environment(\.managedObjectContext) private var context
	@Environment(\.dismiss) private var dismiss
	var node: NodeInfoEntity
	@State private var lineWidth = 2.0
	@State private var data: [PositionAltitude] = []

	var body: some View {
		GroupBox(label: Label("Altitude", systemImage: "mountain.2")) {
			chartView
		}
		.background(Color(UIColor.secondarySystemBackground))
		.opacity(0.8)
		.onAppear {
			loadChartData()
		}
	}

	@ViewBuilder
	private var chartView: some View {
		let points = data.map { position in
			ChartDataPoint.fromDate(position.time, value: position.altitude.converted(to: .meters).value)
		}

		let seriesData = ChartSeriesData(
			id: "altitude",
			name: "Altitude",
			color: .blue,
			chartType: .line,
			points: points,
			lineWidth: lineWidth,
			drawCircles: true,
			circleRadius: 4.0,
			mode: .linear
		)

		let isMetric = Locale.current.measurementSystem == .metric
		let unit = isMetric ? UnitLength.meters : UnitLength.feet

		let xAxisConfig = DGChartXAxisConfig(
			position: .bottom,
			labelCount: 6,
			dateFormat: "MM/dd HH:mm"
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: 6,
			axisValueFormatter: { value, _ in
				let measurement = Measurement(value: value, unit: .meters).converted(to: unit)
				return measurement.formatted(.measurement(width: .wide, numberFormatStyle: .number.precision(.fractionLength(0))))
			}
		)

		let legendConfig = DGChartLegendConfig(
			isEnabled: false
		)

		return LineChartView(
			data: [seriesData],
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: [],
			yDomain: nil,
			visibleXRange: nil,
			scrollPosition: nil,
			isScrollable: false,
			legendHidden: true,
			frame: nil,
			selection: nil,
			onSelectionChanged: nil,
			backgroundColor: .systemBackground,
			gridColor: .systemGray4,
			gridLineWidth: 0.5,
			drawCircles: true,
			circleRadius: 4.0,
			mode: .linear,
			cubicIntensity: 0.2,
			drawFilled: false,
			fillAlpha: 0.3
		)
	}

	private func loadChartData() {
		let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date.distantPast
		data = node.positionsSortedByTime(context: context, ascending: false, limit: visiblePositionLimit)
			.reversed()
			.compactMap { position in
				guard let time = position.time, time > fiveYearsAgo else { return nil }
				return PositionAltitude(
					time: time,
					altitude: Measurement(value: Double(position.altitude), unit: .meters)
				)
			}
	}
}