//
//  DGChartAxis.swift
//  Meshtastic
//
//  Axis configuration and modifiers for DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Axis Mark Position

/// Position of axis marks - mirrors Swift Charts AxisMarkPosition
public enum DGChartAxisMarkPosition {
    case automatic
    case leading
    case trailing
    case center
}

// MARK: - Axis Scale

/// Scale type for axis
public enum DGChartAxisScale {
    case linear
    case log
    case date
    case category
    case time // Alias for date
}

// MARK: - Axis Value Formatter

/// Custom axis value formatter protocol
public protocol DGChartAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String
}

/// Closure-based axis value formatter
public struct DGChartClosureAxisValueFormatter: DGChartAxisValueFormatter {
    let formatter: (Double, AxisBase?) -> String

    public init(_ formatter: @escaping (Double, AxisBase?) -> String) {
        self.formatter = formatter
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        formatter(value, axis)
    }
}

/// Date axis value formatter
public struct DGChartDateAxisValueFormatter: DGChartAxisValueFormatter {
    let dateFormatter: DateFormatter

    public init(dateFormat: String, timeZone: TimeZone = .current, locale: Locale = .current) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale
    }

    public init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timeZone: TimeZone = .current, locale: Locale = .current) {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

/// Index-based axis value formatter (for categorical data)
public struct DGChartIndexAxisValueFormatter: DGChartAxisValueFormatter {
    let values: [String]

    public init(values: [String]) {
        self.values = values
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0 && index < values.count else { return "" }
        return values[index]
    }
}

/// Measurement axis value formatter
public struct DGChartMeasurementAxisValueFormatter<Unit: Dimension>: DGChartAxisValueFormatter {
    let unit: Unit
    let measurementFormatter: MeasurementFormatter

    public init(unit: Unit, numberFormatStyle: MeasurementFormatter.UnitWidth = .wide, locale: Locale = .current) {
        self.unit = unit
        measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.unitStyle = numberFormatStyle
        measurementFormatter.locale = locale
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let measurement = Measurement(value: value, unit: unit)
        return measurementFormatter.string(from: measurement)
    }
}

// MARK: - Axis Configuration Builder

/// Builder for creating axis configurations fluently
@resultBuilder
public struct DGChartAxisConfigBuilder {
    public static func buildBlock(_ components: DGChartAxisConfig...) -> [DGChartAxisConfig] {
        components
    }

    public static func buildOptional(_ component: [DGChartAxisConfig]?) -> [DGChartAxisConfig] {
        component ?? []
    }

    public static func buildEither(first component: [DGChartAxisConfig]) -> [DGChartAxisConfig] {
        component
    }

    public static func buildEither(second component: [DGChartAxisConfig]) -> [DGChartAxisConfig] {
        component
    }

    public static func buildArray(_ components: [[DGChartAxisConfig]]) -> [DGChartAxisConfig] {
        components.flatMap { $0 }
    }
}

// MARK: - Axis Modifiers (SwiftUI-style)

/// Modifier for applying axis configuration to chart views
public struct DGChartAxisModifier<Content: View>: View {
    let content: Content
    let xAxisConfig: DGChartAxisConfig?
    let yAxisConfig: DGChartAxisConfig?

    public init(
        _ content: Content,
        xAxisConfig: DGChartAxisConfig? = nil,
        yAxisConfig: DGChartAxisConfig? = nil
    ) {
        self.content = content
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
    }

    public var body: some View {
        // This is a marker view - actual application happens in chart view initializers
        content
    }
}

public extension View {
    func chartXAxis(_ config: DGChartAxisConfig?) -> some View {
        DGChartAxisModifier(self, xAxisConfig: config)
    }

    func chartYAxis(_ config: DGChartAxisConfig?) -> some View {
        DGChartAxisModifier(self, yAxisConfig: config)
    }

    func chartXAxis(@DGChartAxisConfigBuilder _ config: () -> DGChartAxisConfig) -> some View {
        chartXAxis(config())
    }

    func chartYAxis(@DGChartAxisConfigBuilder _ config: () -> DGChartAxisConfig) -> some View {
        chartYAxis(config())
    }
}

// MARK: - Convenience Axis Configuration Extensions

public extension DGChartAxisConfig {
    /// Create a linear axis config
    static func linear(
        label: String? = nil,
        min: Double? = nil,
        max: Double? = nil,
        labelCount: Int = 6,
        formatter: DGChartAxisValueFormatter? = nil
    ) -> DGDefaultAxisConfig {
        var config = DGDefaultAxisConfig()
        config.scale = .linear
        config.label = label
        config.minValue = min
        config.maxValue = max
        config.labelCount = labelCount
        if let formatter = formatter {
            config.valueFormatter = { value, _ in formatter.stringForValue(value, nil) }
        }
        return config
    }

    /// Create a date axis config
    static func date(
        label: String? = nil,
        min: Date? = nil,
        max: Date? = nil,
        dateFormat: String = "MMM d",
        labelCount: Int = 6
    ) -> DGDefaultAxisConfig {
        var config = DGDefaultAxisConfig()
        config.scale = .date
        config.label = label
        config.minValue = min?.timeIntervalSince1970
        config.maxValue = max?.timeIntervalSince1970
        config.dateFormat = dateFormat
        config.labelCount = labelCount
        return config
    }

    /// Create a time axis config (alias for date with time format)
    static func time(
        label: String? = nil,
        min: Date? = nil,
        max: Date? = nil,
        dateFormat: String = "HH:mm",
        labelCount: Int = 6
    ) -> DGDefaultAxisConfig {
        date(label: label, min: min, max: max, dateFormat: dateFormat, labelCount: labelCount)
    }

    /// Create a categorical axis config
    static func category(
        label: String? = nil,
        values: [String],
        labelCount: Int? = nil
    ) -> DGDefaultAxisConfig {
        var config = DGDefaultAxisConfig()
        config.scale = .category
        config.label = label
        config.labelCount = labelCount ?? values.count
        config.valueFormatter = { value, _ in
            let index = Int(value)
            guard index >= 0 && index < values.count else { return "" }
            return values[index]
        }
        return config
    }

    /// Create a log axis config
    static func log(
        label: String? = nil,
        min: Double? = nil,
        max: Double? = nil,
        labelCount: Int = 6
    ) -> DGDefaultAxisConfig {
        var config = DGDefaultAxisConfig()
        config.scale = .log
        config.label = label
        config.minValue = min
        config.maxValue = max
        config.labelCount = labelCount
        return config
    }
}

// MARK: - Axis Appearance Modifiers

public extension DGDefaultAxisConfig {
    func labelColor(_ color: UIColor) -> DGDefaultAxisConfig {
        var copy = self
        copy.labelColor = color
        return copy
    }

    func labelFont(_ font: UIFont) -> DGDefaultAxisConfig {
        var copy = self
        copy.labelFont = font
        return copy
    }

    func gridColor(_ color: UIColor) -> DGDefaultAxisConfig {
        var copy = self
        copy.gridColor = color
        return copy
    }

    func gridWidth(_ width: CGFloat) -> DGDefaultAxisConfig {
        var copy = self
        copy.gridWidth = width
        return copy
    }

    func gridDashPattern(_ pattern: [CGFloat]?) -> DGDefaultAxisConfig {
        var copy = self
        copy.gridDashPattern = pattern
        return copy
    }

    func tickColor(_ color: UIColor) -> DGDefaultAxisConfig {
        var copy = self
        copy.tickColor = color
        return copy
    }

    func tickLength(_ length: CGFloat) -> DGDefaultAxisConfig {
        var copy = self
        copy.tickLength = length
        return copy
    }

    func tickWidth(_ width: CGFloat) -> DGDefaultAxisConfig {
        var copy = self
        copy.tickWidth = width
        return copy
    }

    func labelCount(_ count: Int) -> DGDefaultAxisConfig {
        var copy = self
        copy.labelCount = count
        return copy
    }

    func forceLabelsEnabled(_ enabled: Bool) -> DGDefaultAxisConfig {
        var copy = self
        copy.forceLabelsEnabled = enabled
        return copy
    }

    func granularity(_ granularity: Double) -> DGDefaultAxisConfig {
        var copy = self
        copy.granularity = granularity
        return copy
    }

    func valueFormatter(_ formatter: @escaping (Double) -> String) -> DGDefaultAxisConfig {
        var copy = self
        copy.valueFormatter = { value, _ in formatter(value) }
        return copy
    }

    func dateFormat(_ format: String) -> DGDefaultAxisConfig {
        var copy = self
        copy.dateFormat = format
        return copy
    }

    func position(_ position: DGChartAxisPosition) -> DGDefaultAxisConfig {
        var copy = self
        copy.position = position
        return copy
    }
}

// MARK: - Axis Position Extension

public extension DGChartAxisConfig {
    var isXAxis: Bool {
        // This would be set by the chart view based on context
        false
    }
}