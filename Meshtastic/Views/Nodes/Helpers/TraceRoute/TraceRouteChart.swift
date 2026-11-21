//
//  TraceRouteChart.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 10/13/26.
//  Updated for DGCharts iOS 15 compatibility
//

import DGCharts
import SwiftUI

/// Hop counts over time, forward and back on the leading axis and the round trip on the trailing
/// axis. Tapping the chart picks the nearest trace route.
struct TraceRouteChart: View {
	let points: [TraceRouteChartPoint]
	@Binding var selectedID: Int64?

	@State private var rawSelection: Date?

	private var scale: TraceRouteChartScale { TraceRouteChartScale(points: points) }
	private var selectedPoint: TraceRouteChartPoint? {
		guard let selectedID else { return nil }
		return points.first { $0.id == selectedID }
	}

	private var forwardName: String { String(localized: "Forward hops", comment: "Trace route: hop count towards the target") }
	private var backName: String { String(localized: "Return hops", comment: "Trace route: hop count on the way back") }
	private var roundTripName: String { String(localized: "Round trip", comment: "Trace route: time from sending the request to getting the response") }

	/// Times of day when the points fall within a day, dates otherwise.
	private var dateFormat: Date.FormatStyle {
		TraceRouteChartPoint.showsTimeOfDay(points) ? .dateTime.hour().minute() : .dateTime.month(.abbreviated).day()
	}

	var body: some View {
		let scale = scale

		// Build chart data
		let forwardPoints = points.compactMap { point -> ChartDataPoint? in
			ChartDataPoint.fromDate(point.date, value: Double(point.forwardHops))
		}

		let backPoints = points.compactMap { point -> ChartDataPoint? in
			guard let backHops = point.backHops else { return nil }
			return ChartDataPoint.fromDate(point.date, value: Double(backHops))
		}

		let roundTripPoints = points.compactMap { point -> ChartDataPoint? in
			guard let roundTrip = point.roundTrip else { return nil }
			return ChartDataPoint.fromDate(point.date, value: scale.plotted(roundTrip: roundTrip))
		}

		let forwardSeries = ChartSeriesData(
			id: "forward",
			name: forwardName,
			color: TraceRouteColors.forward,
			chartType: .line,
			points: forwardPoints,
			lineWidth: 2.0,
			drawCircles: true,
			circleRadius: 4.0,
			mode: .linear
		)

		var seriesData: [ChartSeriesData] = [forwardSeries]

		if !backPoints.isEmpty {
			let backSeries = ChartSeriesData(
				id: "back",
				name: backName,
				color: TraceRouteColors.back,
				chartType: .line,
				points: backPoints,
				lineWidth: 2.0,
				drawCircles: true,
				circleRadius: 4.0,
				mode: .linear,
				dashPattern: [5, 3]
			)
			seriesData.append(backSeries)
		}

		if !roundTripPoints.isEmpty {
			let roundTripSeries = ChartSeriesData(
				id: "roundTrip",
				name: roundTripName,
				color: TraceRouteColors.roundTrip,
				chartType: .line,
				points: roundTripPoints,
				lineWidth: 1.5,
				drawCircles: true,
				circleRadius: 4.0,
				mode: .linear
			)
			seriesData.append(roundTripSeries)
		}

		var ruleMarks: [DGRuleMark] = []
		if let selectedPoint {
			ruleMarks.append(DGRuleMark(
				position: selectedPoint.date.timeIntervalSince1970,
				axis: .x,
				color: .secondary,
				lineWidth: 1.0,
				dashPattern: nil
			))
		}

		let xAxisConfig = DGChartXAxisConfig(
			position: .bottom,
			labelCount: 3,
			dateFormat: dateFormat.format
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: scale.maxHops + 1,
			axisMinimum: 0,
			axisMaximum: Double(scale.maxHops)
		)

		let legendConfig = DGChartLegendConfig(
			isEnabled: true,
			position: .belowChartLeft,
			alignment: .left,
			orientation: .horizontal
		)

		return CombinedChartView(
			data: seriesData,
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: ruleMarks,
			yDomain: 0...Double(scale.maxHops),
			visibleXRange: nil,
			scrollPosition: nil,
			isScrollable: false,
			legendHidden: false,
			frame: CGSize(width: 300, height: 200),
			selection: nil,
			onSelectionChanged: nil,
			backgroundColor: .systemBackground,
			gridColor: .systemGray4,
			gridLineWidth: 0.5,
			drawOrder: [.bar, .bubble, .line, .scatter, .candle]
		)
	}
}