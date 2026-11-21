//
//  MetricsChartSeries.swift
//  Meshtastic
//
//  Created by Jake Bordens on 12/11/24.
//  Updated for DGCharts iOS 15 compatibility
//

import Foundation
import SwiftUI
import DGCharts

// MetricsChartSeries stores metadata about an attribute in TelemetryEntity.
// Given a keypath, this class holds information about how to render the attribute in a
// the chart. MetricsChartSeries objects are collected in a MetricsSeriesList
class MetricsChartSeries: ObservableObject, Identifiable {

	// Uniquely identify this column for persistence and iteration
	// Recommend using CoreData Attribute Name on TelemetryEntity
	let id: String

	// Heading for areas that have the room
	let name: String

	// Heading for space-constrained areas
	let abbreviatedName: String

	// Optional unit symbol (e.g. "°", "%", "hPa", "µg/m³") appended to VoiceOver values so the
	// spoken reading includes its units. nil for unitless/index series.
	let unit: String?

	// Should this column appear in the chart
	var visible: Bool

	// Chart type for this series
	let chartType: ChartSeriesType

	// Line/bar styling
	let lineWidth: CGFloat
	let dashPattern: [CGFloat]?
	let strokeStyle: StrokeStyle

	// Fill styling (for area charts)
	let fillColor: Color?
	let fillAlpha: CGFloat

	// A closure that will provide the foreground style given the data set and overall chart range
	let foregroundStyle: (ClosedRange<Float>?) -> AnyShapeStyle?

	// A closure that will provide the value of a TelemetryEntity for this series
	// Possibly converted to the proper units
	let valueClosure: (TelemetryEntity) -> Float?

	// Used for scaling the Y-axis
	let initialYAxisRange: ClosedRange<Float>?
	let minimumYAxisSpan: Float?

	// Chart series types supported
	enum ChartSeriesType {
		case line
		case area
		case bar
		case point
		case combinedLineArea // Line with area fill
	}

	// Main initializer
	init<Value>(
		id: String,
		keyPath: KeyPath<TelemetryEntity, Value>,
		name: String,
		abbreviatedName: String,
		unit: String? = nil,
		initialYAxisRange: ClosedRange<Float>? = nil,
		minimumYAxisSpan: Float? = nil,
		conversion: ((Value) -> Float)? = nil,
		visible: Bool = true,
		chartType: ChartSeriesType = .line,
		lineWidth: CGFloat = 2.0,
		dashPattern: [CGFloat]? = nil,
		fillColor: Color? = nil,
		fillAlpha: CGFloat = 0.3,
		foregroundStyle: @escaping ((ClosedRange<Float>?) -> AnyShapeStyle?) = { _ in nil },
		valueExtractor: @escaping (TelemetryEntity) -> Float? = { _ in nil }
	) {

		self.id = id
		self.name = name
		self.abbreviatedName = abbreviatedName
		self.unit = unit
		self.initialYAxisRange = initialYAxisRange
		self.minimumYAxisSpan = minimumYAxisSpan
		self.visible = visible
		self.chartType = chartType
		self.lineWidth = lineWidth
		self.dashPattern = dashPattern
		self.fillColor = fillColor
		self.fillAlpha = fillAlpha
		self.strokeStyle = StrokeStyle(lineWidth: lineWidth, dash: dashPattern ?? [])

		// By saving these closures, MetricsChartSeries can be type agnostic
		self.foregroundStyle = { range in foregroundStyle(range).map({ AnyShapeStyle($0) }) }
		self.valueClosure = { entity in
			return valueExtractor(entity)
		}
	}

	// Convenience initializer for simple series
	convenience init(
		id: String,
		keyPath: KeyPath<TelemetryEntity, Float?>,
		name: String,
		abbreviatedName: String,
		unit: String? = nil,
		initialYAxisRange: ClosedRange<Float>? = nil,
		minimumYAxisSpan: Float? = nil,
		visible: Bool = true,
		chartType: ChartSeriesType = .line,
		lineWidth: CGFloat = 2.0,
		dashPattern: [CGFloat]? = nil,
		fillColor: Color? = nil,
		fillAlpha: CGFloat = 0.3,
		foregroundStyle: @escaping ((ClosedRange<Float>?) -> AnyShapeStyle?) = { _ in nil }
	) {
		self.init(
			id: id,
			keyPath: keyPath,
			name: name,
			abbreviatedName: abbreviatedName,
			unit: unit,
			initialYAxisRange: initialYAxisRange,
			minimumYAxisSpan: minimumYAxisSpan,
			conversion: { $0 },
			visible: visible,
			chartType: chartType,
			lineWidth: lineWidth,
			dashPattern: dashPattern,
			fillColor: fillColor,
			fillAlpha: fillAlpha,
			foregroundStyle: foregroundStyle,
			valueExtractor: { entity in
				return entity[keyPath: keyPath]
			}
		)
	}

	// Get value for a telemetry entity
	func valueFor(_ entity: TelemetryEntity) -> Float? {
		return valueClosure(entity)
	}
}

// MARK: - DGCharts Series Data Conversion

extension MetricsChartSeries {
	/// Convert this series configuration to a DGCharts ChartSeriesData
	func toChartSeriesData(points: [ChartDataPoint]) -> ChartSeriesData {
		return ChartSeriesData(
			id: id,
			name: name,
			color: foregroundStyle(nil)?.resolve(in: EnvironmentValues()) ?? .primary,
			chartType: chartType.toDGChartsType(),
			points: points,
			lineWidth: lineWidth,
			dashPattern: dashPattern,
			fillColor: fillColor,
			fillAlpha: fillAlpha,
			isVisible: visible
		)
	}
}

extension MetricsChartSeries.ChartSeriesType {
	func toDGChartsType() -> ChartSeriesData.ChartType {
		switch self {
		case .line: return .line
		case .area: return .area
		case .bar: return .bar
		case .point: return .point
		case .combinedLineArea: return .area
		}
	}
}

// Extension to combine windspeed and direction into one attribute for rendering
// for rendering on the chart.
@objc class WindSpeedAndDirection: NSObject {

	let windSpeed: Float
	let windDirection: Int32?
	init(windSpeed: Float, windDirection: Int32?) {
		self.windSpeed = windSpeed
		self.windDirection = windDirection
	}

	var primitivePlottable: Float { windSpeed }
}

@objc extension TelemetryEntity {
	var windSpeedAndDirection: WindSpeedAndDirection? {
		guard let windSpeed = self.windSpeed else { return nil }

		return WindSpeedAndDirection(windSpeed: windSpeed, windDirection: self.windDirection)
	}
}

// From: https://github.com/meshtastic/Meshtastic-Apple/pull/1013/commits/bc932567c742c8fa9fd30752237b10cb762c5ef3
// Set up gradient stops relative to the scale of the temperature chart
func generateStops(minTemp: Double, maxTemp: Double, tempUnit: UnitTemperature, opacity: Double) -> [Gradient.Stop] {
	var gradientStops = [Gradient.Stop]()

	let stopTargets: [(Double, Color)] = [
		((tempUnit == .celsius ? 0 : 32), .blue),
		((tempUnit == .celsius ? 20 : 68), .yellow),
		((tempUnit == .celsius ? 30 : 86), .orange),
		((tempUnit == .celsius ? 55 : 125), .red)
	]
	for (stopValue, color) in stopTargets {
		let stopLocation = transform(stopValue, from: minTemp...maxTemp, to: 0...1)
		gradientStops.append(Gradient.Stop(color: color.opacity(opacity), location: stopLocation))
	}
	return gradientStops
}

// Map inputRange to outputRange
func transform<T: FloatingPoint>(_ input: T, from inputRange: ClosedRange<T>, to outputRange: ClosedRange<T>) -> T {
	// need to determine what that value would be in (to.low, to.high)
	// difference in output range / difference in input range = slope
	let slope = (outputRange.upperBound - outputRange.lowerBound) / (inputRange.upperBound - inputRange.lowerBound)
	// slope * normalized input + output lower
	let output = slope * (input - inputRange.lowerBound) + outputRange.lowerBound
	return output
}