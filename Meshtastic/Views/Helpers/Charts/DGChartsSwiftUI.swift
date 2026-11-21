//
//  DGChartsSwiftUI.swift
//  Meshtastic
//
//  SwiftUI-style API wrappers for DGCharts that mimic Swift Charts syntax
//

import SwiftUI
import DGCharts
import UIKit

// MARK: - Mark Types (Swift Charts-like API)

/// Represents a data point for line charts
public struct LineMark: View {
    let x: PlottableValue
    let y: PlottableValue
    let interpolationMethod: InterpolationMethod
    let foregroundStyle: AnyShapeStyle?
    let accessibilityLabel: String?
    let accessibilityValue: String?

    public enum InterpolationMethod {
        case linear
        case catmullRom
        case monotone
        case step
        case stepCenter
        case stepEnd
    }

    public init(
        x: PlottableValue,
        y: PlottableValue,
        interpolationMethod: InterpolationMethod = .linear,
        foregroundStyle: AnyShapeStyle? = nil,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil
    ) {
        self.x = x
        self.y = y
        self.interpolationMethod = interpolationMethod
        self.foregroundStyle = foregroundStyle
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
    }

    public var body: some View {
        EmptyView() // This is a builder component, not rendered directly
    }
}

/// Represents a data point for point/scatter charts
public struct PointMark: View {
    let x: PlottableValue
    let y: PlottableValue
    let foregroundStyle: AnyShapeStyle?

    public init(
        x: PlottableValue,
        y: PlottableValue,
        foregroundStyle: AnyShapeStyle? = nil
    ) {
        self.x = x
        self.y = y
        self.foregroundStyle = foregroundStyle
    }

    public var body: some View {
        EmptyView()
    }
}

/// Represents a rule mark (reference line)
public struct RuleMark: View {
    let x: PlottableValue?
    let y: PlottableValue?
    let foregroundStyle: AnyShapeStyle?
    let lineStyle: StrokeStyle?

    public init(
        x: PlottableValue? = nil,
        y: PlottableValue? = nil,
        foregroundStyle: AnyShapeStyle? = nil,
        lineStyle: StrokeStyle? = nil
    ) {
        self.x = x
        self.y = y
        self.foregroundStyle = foregroundStyle
        self.lineStyle = lineStyle
    }

    public var body: some View {
        EmptyView()
    }
}

/// Represents an area mark (filled area under line)
public struct AreaMark: View {
    let x: PlottableValue
    let y: PlottableValue
    let foregroundStyle: AnyShapeStyle?
    let interpolationMethod: LineMark.InterpolationMethod

    public init(
        x: PlottableValue,
        y: PlottableValue,
        foregroundStyle: AnyShapeStyle? = nil,
        interpolationMethod: LineMark.InterpolationMethod = .linear
    ) {
        self.x = x
        self.y = y
        self.foregroundStyle = foregroundStyle
        self.interpolationMethod = interpolationMethod
    }

    public var body: some View {
        EmptyView()
    }
}

/// Represents a bar mark
public struct BarMark: View {
    let x: PlottableValue
    let y: PlottableValue
    let width: MarkDimension?
    let foregroundStyle: AnyShapeStyle?

    public init(
        x: PlottableValue,
        y: PlottableValue,
        width: MarkDimension? = nil,
        foregroundStyle: AnyShapeStyle? = nil
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.foregroundStyle = foregroundStyle
    }

    public var body: some View {
        EmptyView()
    }
}

// MARK: - Plottable Value

/// Represents a plottable value (mimics Swift Charts PlottableValue)
public struct PlottableValue {
    let label: String
    let value: Double
    let unit: String?

    public init(_ label: String, value: Double, unit: String? = nil) {
        self.label = label
        self.value = value
        self.unit = unit
    }

    public static func value(_ label: String, _ value: some Plottable) -> PlottableValue {
        return PlottableValue(label, value: value.primitivePlottable)
    }

    public static func value(_ label: String, _ value: Date) -> PlottableValue {
        return PlottableValue(label, value: value.timeIntervalSince1970)
    }
}

// MARK: - Plottable Protocol (mimics Swift Charts Plottable)

public protocol Plottable {
    var primitivePlottable: Double { get }
    init?(primitivePlottable: Double)
}

extension Double: Plottable {
    public var primitivePlottable: Double { self }
    public init?(primitivePlottable: Double) { self = primitivePlottable }
}

extension Float: Plottable {
    public var primitivePlottable: Double { Double(self) }
    public init?(primitivePlottable: Double) { self = Float(primitivePlottable) }
}

extension Int: Plottable {
    public var primitivePlottable: Double { Double(self) }
    public init?(primitivePlottable: Double) { self = Int(primitivePlottable) }
}

extension Date: Plottable {
    public var primitivePlottable: Double { timeIntervalSince1970 }
    public init?(primitivePlottable: Double) { self = Date(timeIntervalSince1970: primitivePlottable) }
}

// MARK: - Mark Dimension

public enum MarkDimension {
    case fixed(CGFloat)
    case ratio(CGFloat)
    case automatic
}

// MARK: - Chart Content Builder

@resultBuilder
public struct ChartContentBuilder {
    public static func buildBlock(_ components: Any...) -> [Any] {
        return components
    }

    public static func buildOptional(_ component: [Any]?) -> [Any] {
        return component ?? []
    }

    public static func buildEither(first: [Any]) -> [Any] {
        return first
    }

    public static func buildEither(second: [Any]) -> [Any] {
        return second
    }

    public static func buildArray(_ components: [[Any]]) -> [Any] {
        return components.flatMap { $0 }
    }
}

// MARK: - Chart View Modifiers

/// Chart content container that holds marks
public struct ChartContent {
    var marks: [Any] = []
    var foregroundStyleScale: [String: AnyShapeStyle] = [:]

    mutating func addMark(_ mark: Any) {
        marks.append(mark)
    }

    mutating func setForegroundStyleScale(_ scale: [String: AnyShapeStyle]) {
        foregroundStyleScale = scale
    }
}

/// Main Chart view - entry point for creating charts
public struct Chart<Content: View>: View {
    let content: () -> Content
    @State private var chartContent = ChartContent()

    // Chart configuration
    var xAxisConfig: DGChartXAxisConfig?
    var yAxisConfig: DGChartYAxisConfig?
    var legendConfig: DGChartLegendConfig?
    var ruleMarks: [DGRuleMark] = []

    // Interaction
    @Binding var selection: DGChartSelection?
    var onSelectionChanged: ((DGChartSelection?) -> Void)?
    var pinchZoomEnabled: Bool = true
    var doubleTapToZoomEnabled: Bool = true
    var dragEnabled: Bool = true
    var scaleXEnabled: Bool = true
    var scaleYEnabled: Bool = true

    // Scrolling
    var isScrollableHorizontal: Bool = false
    var visibleXRange: Double?

    // Appearance
    var backgroundColor: UIColor = .systemBackground
    var gridColor: UIColor = .systemGray4
    var gridLineWidth: CGFloat = 0.5
    var frame: CGSize?
    var chartYScaleDomain: ClosedRange<Double>?
    var chartXVisibleDomain: Double?
    var chartScrollPosition: Binding<Date>?
    var chartLegendHidden: Bool = false

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        // This will be replaced by specific chart implementations
        // The actual rendering happens in the specific chart views
        GeometryReader { geometry in
            ZStack {
                Color.clear
                content()
            }
        }
        .frame(width: frame?.width, height: frame?.height)
    }

    // MARK: - Axis Modifiers

    public func chartXAxis(_ config: DGChartXAxisConfig? = nil) -> Chart {
        var copy = self
        copy.xAxisConfig = config
        return copy
    }

    public func chartYAxis(_ config: DGChartYAxisConfig? = nil) -> Chart {
        var copy = self
        copy.yAxisConfig = config
        return copy
    }

    public func chartYScale(domain: ClosedRange<Double>) -> Chart {
        var copy = self
        copy.chartYScaleDomain = domain
        return copy
    }

    public func chartXVisibleDomain(length: Double) -> Chart {
        var copy = self
        copy.chartXVisibleDomain = length
        copy.isScrollableHorizontal = true
        copy.visibleXRange = length
        return copy
    }

    public func chartScrollPosition(x: Binding<Date>) -> Chart {
        var copy = self
        copy.chartScrollPosition = x
        copy.isScrollableHorizontal = true
        return copy
    }

    public func chartScrollableAxes(_ axes: Axis.Set) -> Chart {
        var copy = self
        copy.isScrollableHorizontal = axes.contains(.horizontal)
        return copy
    }

    // MARK: - Foreground Style Scale

    public func chartForegroundStyleScale(_ scale: [String: AnyShapeStyle]) -> Chart {
        var copy = self
        // Store for use in specific chart implementations
        return copy
    }

    // MARK: - Legend

    public func chartLegend(_ visibility: Visibility) -> Chart {
        var copy = self
        copy.chartLegendHidden = visibility == .hidden
        return copy
    }

    public func chartLegend(position: DGChartLegendConfig.LegendPosition, alignment: DGChartLegendConfig.LegendAlignment = .center) -> Chart {
        var copy = self
        copy.legendConfig = DGChartLegendConfig(
            isEnabled: true,
            position: position,
            alignment: alignment
        )
        return copy
    }

    // MARK: - Interaction

    public func chartXSelection(value: Binding<DGChartSelection?>) -> Chart {
        var copy = self
        copy.selection = value
        return copy
    }

    // MARK: - Frame

    public func frame(height: CGFloat) -> Chart {
        var copy = self
        copy.frame = CGSize(width: copy.frame?.width ?? 0, height: height)
        return copy
    }

    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Chart {
        var copy = self
        copy.frame = CGSize(width: width ?? copy.frame?.width ?? 0, height: height ?? copy.frame?.height ?? 0)
        return copy
    }

    public func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> Chart {
        // Padding is handled by parent view
        return self
    }
}

// MARK: - Specific Chart Implementations

/// Line Chart View
public struct LineChartView: View {
    let data: [ChartSeriesData]
    let xAxisConfig: DGChartXAxisConfig?
    let yAxisConfig: DGChartYAxisConfig?
    let legendConfig: DGChartLegendConfig?
    let ruleMarks: [DGRuleMark]
    let yDomain: ClosedRange<Double>?
    let visibleXRange: Double?
    let scrollPosition: Binding<Date>?
    let isScrollable: Bool
    let legendHidden: Bool
    let frame: CGSize?
    let foregroundStyleScale: [String: AnyShapeStyle]
    let selection: Binding<DGChartSelection?>?
    let onSelectionChanged: ((DGChartSelection?) -> Void)?
    let pinchZoomEnabled: Bool
    let doubleTapToZoomEnabled: Bool
    let dragEnabled: Bool
    let scaleXEnabled: Bool
    let scaleYEnabled: Bool
    let backgroundColor: UIColor
    let gridColor: UIColor
    let gridLineWidth: CGFloat
    let drawCircles: Bool
    let circleRadius: CGFloat
    let mode: LineChartDataSet.Mode
    let cubicIntensity: CGFloat
    let drawFilled: Bool
    let fillAlpha: CGFloat

    public init(
        data: [ChartSeriesData],
        xAxisConfig: DGChartXAxisConfig? = nil,
        yAxisConfig: DGChartYAxisConfig? = nil,
        legendConfig: DGChartLegendConfig? = nil,
        ruleMarks: [DGRuleMark] = [],
        yDomain: ClosedRange<Double>? = nil,
        visibleXRange: Double? = nil,
        scrollPosition: Binding<Date>? = nil,
        isScrollable: Bool = false,
        legendHidden: Bool = false,
        frame: CGSize? = nil,
        foregroundStyleScale: [String: AnyShapeStyle] = [:],
        selection: Binding<DGChartSelection?>? = nil,
        onSelectionChanged: ((DGChartSelection?) -> Void)? = nil,
        pinchZoomEnabled: Bool = true,
        doubleTapToZoomEnabled: Bool = true,
        dragEnabled: Bool = true,
        scaleXEnabled: Bool = true,
        scaleYEnabled: Bool = true,
        backgroundColor: UIColor = .systemBackground,
        gridColor: UIColor = .systemGray4,
        gridLineWidth: CGFloat = 0.5,
        drawCircles: Bool = false,
        circleRadius: CGFloat = 4.0,
        mode: LineChartDataSet.Mode = .linear,
        cubicIntensity: CGFloat = 0.2,
        drawFilled: Bool = false,
        fillAlpha: CGFloat = 0.3
    ) {
        self.data = data
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
        self.legendConfig = legendConfig
        self.ruleMarks = ruleMarks
        self.yDomain = yDomain
        self.visibleXRange = visibleXRange
        self.scrollPosition = scrollPosition
        self.isScrollable = isScrollable
        self.legendHidden = legendHidden
        self.frame = frame
        self.foregroundStyleScale = foregroundStyleScale
        self.selection = selection
        self.onSelectionChanged = onSelectionChanged
        self.pinchZoomEnabled = pinchZoomEnabled
        self.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        self.dragEnabled = dragEnabled
        self.scaleXEnabled = scaleXEnabled
        self.scaleYEnabled = scaleYEnabled
        self.backgroundColor = backgroundColor
        self.gridColor = gridColor
        self.gridLineWidth = gridLineWidth
        self.drawCircles = drawCircles
        self.circleRadius = circleRadius
        self.mode = mode
        self.cubicIntensity = cubicIntensity
        self.drawFilled = drawFilled
        self.fillAlpha = fillAlpha
    }

    public var body: some View {
        DGLineChartSwiftUI(
            data: data,
            xAxisConfig: xAxisConfig,
            yAxisConfig: yAxisConfig,
            legendConfig: legendConfig,
            ruleMarks: ruleMarks,
            yDomain: yDomain,
            visibleXRange: visibleXRange,
            scrollPosition: scrollPosition,
            isScrollable: isScrollable,
            legendHidden: legendHidden,
            frame: frame,
            foregroundStyleScale: foregroundStyleScale,
            selection: selection,
            onSelectionChanged: onSelectionChanged,
            pinchZoomEnabled: pinchZoomEnabled,
            doubleTapToZoomEnabled: doubleTapToZoomEnabled,
            dragEnabled: dragEnabled,
            scaleXEnabled: scaleXEnabled,
            scaleYEnabled: scaleYEnabled,
            backgroundColor: backgroundColor,
            gridColor: gridColor,
            gridLineWidth: gridLineWidth,
            drawCircles: drawCircles,
            circleRadius: circleRadius,
            mode: mode,
            cubicIntensity: cubicIntensity,
            drawFilled: drawFilled,
            fillAlpha: fillAlpha
        )
    }
}

/// Bar Chart View
public struct BarChartView: View {
    let data: [ChartSeriesData]
    let xAxisConfig: DGChartXAxisConfig?
    let yAxisConfig: DGChartYAxisConfig?
    let legendConfig: DGChartLegendConfig?
    let ruleMarks: [DGRuleMark]
    let yDomain: ClosedRange<Double>?
    let visibleXRange: Double?
    let scrollPosition: Binding<Date>?
    let isScrollable: Bool
    let legendHidden: Bool
    let frame: CGSize?
    let foregroundStyleScale: [String: AnyShapeStyle]
    let selection: Binding<DGChartSelection?>?
    let onSelectionChanged: ((DGChartSelection?) -> Void)?
    let pinchZoomEnabled: Bool
    let doubleTapToZoomEnabled: Bool
    let dragEnabled: Bool
    let scaleXEnabled: Bool
    let scaleYEnabled: Bool
    let backgroundColor: UIColor
    let gridColor: UIColor
    let gridLineWidth: CGFloat
    let barWidth: CGFloat
    let groupSpace: CGFloat

    public init(
        data: [ChartSeriesData],
        xAxisConfig: DGChartXAxisConfig? = nil,
        yAxisConfig: DGChartYAxisConfig? = nil,
        legendConfig: DGChartLegendConfig? = nil,
        ruleMarks: [DGRuleMark] = [],
        yDomain: ClosedRange<Double>? = nil,
        visibleXRange: Double? = nil,
        scrollPosition: Binding<Date>? = nil,
        isScrollable: Bool = false,
        legendHidden: Bool = false,
        frame: CGSize? = nil,
        foregroundStyleScale: [String: AnyShapeStyle] = [:],
        selection: Binding<DGChartSelection?>? = nil,
        onSelectionChanged: ((DGChartSelection?) -> Void)? = nil,
        pinchZoomEnabled: Bool = true,
        doubleTapToZoomEnabled: Bool = true,
        dragEnabled: Bool = true,
        scaleXEnabled: Bool = true,
        scaleYEnabled: Bool = true,
        backgroundColor: UIColor = .systemBackground,
        gridColor: UIColor = .systemGray4,
        gridLineWidth: CGFloat = 0.5,
        barWidth: CGFloat = 0.8,
        groupSpace: CGFloat = 0.1
    ) {
        self.data = data
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
        self.legendConfig = legendConfig
        self.ruleMarks = ruleMarks
        self.yDomain = yDomain
        self.visibleXRange = visibleXRange
        self.scrollPosition = scrollPosition
        self.isScrollable = isScrollable
        self.legendHidden = legendHidden
        self.frame = frame
        self.foregroundStyleScale = foregroundStyleScale
        self.selection = selection
        self.onSelectionChanged = onSelectionChanged
        self.pinchZoomEnabled = pinchZoomEnabled
        self.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        self.dragEnabled = dragEnabled
        self.scaleXEnabled = scaleXEnabled
        self.scaleYEnabled = scaleYEnabled
        self.backgroundColor = backgroundColor
        self.gridColor = gridColor
        self.gridLineWidth = gridLineWidth
        self.barWidth = barWidth
        self.groupSpace = groupSpace
    }

    public var body: some View {
        DGBarChartSwiftUI(
            data: data,
            xAxisConfig: xAxisConfig,
            yAxisConfig: yAxisConfig,
            legendConfig: legendConfig,
            ruleMarks: ruleMarks,
            yDomain: yDomain,
            visibleXRange: visibleXRange,
            scrollPosition: scrollPosition,
            isScrollable: isScrollable,
            legendHidden: legendHidden,
            frame: frame,
            foregroundStyleScale: foregroundStyleScale,
            selection: selection,
            onSelectionChanged: onSelectionChanged,
            pinchZoomEnabled: pinchZoomEnabled,
            doubleTapToZoomEnabled: doubleTapToZoomEnabled,
            dragEnabled: dragEnabled,
            scaleXEnabled: scaleXEnabled,
            scaleYEnabled: scaleYEnabled,
            backgroundColor: backgroundColor,
            gridColor: gridColor,
            gridLineWidth: gridLineWidth,
            barWidth: barWidth,
            groupSpace: groupSpace
        )
    }
}

/// Combined Chart View (Line + Bar + Area)
public struct CombinedChartView: View {
    let data: [ChartSeriesData]
    let xAxisConfig: DGChartXAxisConfig?
    let yAxisConfig: DGChartYAxisConfig?
    let legendConfig: DGChartLegendConfig?
    let ruleMarks: [DGRuleMark]
    let yDomain: ClosedRange<Double>?
    let visibleXRange: Double?
    let scrollPosition: Binding<Date>?
    let isScrollable: Bool
    let legendHidden: Bool
    let frame: CGSize?
    let foregroundStyleScale: [String: AnyShapeStyle]
    let selection: Binding<DGChartSelection?>?
    let onSelectionChanged: ((DGChartSelection?) -> Void)?
    let pinchZoomEnabled: Bool
    let doubleTapToZoomEnabled: Bool
    let dragEnabled: Bool
    let scaleXEnabled: Bool
    let scaleYEnabled: Bool
    let backgroundColor: UIColor
    let gridColor: UIColor
    let gridLineWidth: CGFloat
    let drawCircles: Bool
    let circleRadius: CGFloat
    let mode: LineChartDataSet.Mode
    let cubicIntensity: CGFloat
    let barWidth: CGFloat
    let groupSpace: CGFloat

    public init(
        data: [ChartSeriesData],
        xAxisConfig: DGChartXAxisConfig? = nil,
        yAxisConfig: DGChartYAxisConfig? = nil,
        legendConfig: DGChartLegendConfig? = nil,
        ruleMarks: [DGRuleMark] = [],
        yDomain: ClosedRange<Double>? = nil,
        visibleXRange: Double? = nil,
        scrollPosition: Binding<Date>? = nil,
        isScrollable: Bool = false,
        legendHidden: Bool = false,
        frame: CGSize? = nil,
        foregroundStyleScale: [String: AnyShapeStyle] = [:],
        selection: Binding<DGChartSelection?>? = nil,
        onSelectionChanged: ((DGChartSelection?) -> Void)? = nil,
        pinchZoomEnabled: Bool = true,
        doubleTapToZoomEnabled: Bool = true,
        dragEnabled: Bool = true,
        scaleXEnabled: Bool = true,
        scaleYEnabled: Bool = true,
        backgroundColor: UIColor = .systemBackground,
        gridColor: UIColor = .systemGray4,
        gridLineWidth: CGFloat = 0.5,
        drawCircles: Bool = false,
        circleRadius: CGFloat = 4.0,
        mode: LineChartDataSet.Mode = .linear,
        cubicIntensity: CGFloat = 0.2,
        barWidth: CGFloat = 0.8,
        groupSpace: CGFloat = 0.1
    ) {
        self.data = data
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
        self.legendConfig = legendConfig
        self.ruleMarks = ruleMarks
        self.yDomain = yDomain
        self.visibleXRange = visibleXRange
        self.scrollPosition = scrollPosition
        self.isScrollable = isScrollable
        self.legendHidden = legendHidden
        self.frame = frame
        self.foregroundStyleScale = foregroundStyleScale
        self.selection = selection
        self.onSelectionChanged = onSelectionChanged
        self.pinchZoomEnabled = pinchZoomEnabled
        self.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        self.dragEnabled = dragEnabled
        self.scaleXEnabled = scaleXEnabled
        self.scaleYEnabled = scaleYEnabled
        self.backgroundColor = backgroundColor
        self.gridColor = gridColor
        self.gridLineWidth = gridLineWidth
        self.drawCircles = drawCircles
        self.circleRadius = circleRadius
        self.mode = mode
        self.cubicIntensity = cubicIntensity
        self.barWidth = barWidth
        self.groupSpace = groupSpace
    }

    public var body: some View {
        DGCombinedChartSwiftUI(
            data: data,
            xAxisConfig: xAxisConfig,
            yAxisConfig: yAxisConfig,
            legendConfig: legendConfig,
            ruleMarks: ruleMarks,
            yDomain: yDomain,
            visibleXRange: visibleXRange,
            scrollPosition: scrollPosition,
            isScrollable: isScrollable,
            legendHidden: legendHidden,
            frame: frame,
            foregroundStyleScale: foregroundStyleScale,
            selection: selection,
            onSelectionChanged: onSelectionChanged,
            pinchZoomEnabled: pinchZoomEnabled,
            doubleTapToZoomEnabled: doubleTapToZoomEnabled,
            dragEnabled: dragEnabled,
            scaleXEnabled: scaleXEnabled,
            scaleYEnabled: scaleYEnabled,
            backgroundColor: backgroundColor,
            gridColor: gridColor,
            gridLineWidth: gridLineWidth,
            drawCircles: drawCircles,
            circleRadius: circleRadius,
            mode: mode,
            cubicIntensity: cubicIntensity,
            barWidth: barWidth,
            groupSpace: groupSpace
        )
    }
}

// MARK: - Chart Series Data

/// Data for a single chart series
public struct ChartSeriesData: Identifiable {
    public let id: String
    public let name: String
    public let color: Color
    public let chartType: ChartType
    public let points: [ChartDataPoint]
    public let lineWidth: CGFloat
    public let dashPattern: [CGFloat]?
    public let fillColor: Color?
    public let fillAlpha: CGFloat
    public let isVisible: Bool

    public enum ChartType {
        case line
        case bar
        case area
        case point
    }

    public init(
        id: String,
        name: String,
        color: Color,
        chartType: ChartType = .line,
        points: [ChartDataPoint],
        lineWidth: CGFloat = 2.0,
        dashPattern: [CGFloat]? = nil,
        fillColor: Color? = nil,
        fillAlpha: CGFloat = 0.3,
        isVisible: Bool = true
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.chartType = chartType
        self.points = points
        self.lineWidth = lineWidth
        self.dashPattern = dashPattern
        self.fillColor = fillColor
        self.fillAlpha = fillAlpha
        self.isVisible = isVisible
    }
}

/// Individual data point
public struct ChartDataPoint: Identifiable {
    public let id = UUID()
    public let x: Double
    public let y: Double
    public let label: String?

    public init(x: Double, y: Double, label: String? = nil) {
        self.x = x
        self.y = y
        self.label = label
    }

    public static func fromDate(_ date: Date, value: Double, label: String? = nil) -> ChartDataPoint {
        return ChartDataPoint(x: date.timeIntervalSince1970, y: value, label: label)
    }
}

// MARK: - SwiftUI Wrapper Views (UIViewRepresentable)

struct DGLineChartSwiftUI: UIViewRepresentable {
    let data: [ChartSeriesData]
    let xAxisConfig: DGChartXAxisConfig?
    let yAxisConfig: DGChartYAxisConfig?
    let legendConfig: DGChartLegendConfig?
    let ruleMarks: [DGRuleMark]
    let yDomain: ClosedRange<Double>?
    let visibleXRange: Double?
    let scrollPosition: Binding<Date>?
    let isScrollable: Bool
    let legendHidden: Bool
    let frame: CGSize?
    let foregroundStyleScale: [String: AnyShapeStyle]
    let selection: Binding<DGChartSelection?>?
    let onSelectionChanged: ((DGChartSelection?) -> Void)?
    let pinchZoomEnabled: Bool
    let doubleTapToZoomEnabled: Bool
    let dragEnabled: Bool
    let scaleXEnabled: Bool
    let scaleYEnabled: Bool
    let backgroundColor: UIColor
    let gridColor: UIColor
    let gridLineWidth: CGFloat
    let drawCircles: Bool
    let circleRadius: CGFloat
    let mode: LineChartDataSet.Mode
    let cubicIntensity: CGFloat
    let drawFilled: Bool
    let fillAlpha: CGFloat

    func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        chartView.delegate = context.coordinator.delegate
        return chartView
    }

    func updateUIView(_ uiView: LineChartView, context: Context) {
        var dataSets: [LineChartDataSet] = []

        for series in data where series.isVisible {
            let entries = series.points.map { point in
                ChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
            }

            let dataSet = LineChartDataSet(entries: entries, label: series.name)
            dataSet.colors = [UIColor(series.color)]
            dataSet.lineWidth = series.lineWidth
            dataSet.drawCirclesEnabled = drawCircles
            dataSet.circleRadius = circleRadius
            dataSet.circleHoleRadius = circleRadius / 2
            dataSet.mode = mode
            dataSet.cubicIntensity = cubicIntensity
            dataSet.drawFilledEnabled = drawFilled || series.fillColor != nil
            dataSet.fillAlpha = series.fillAlpha

            if let fillColor = series.fillColor {
                dataSet.fillColor = UIColor(fillColor)
            } else if drawFilled {
                dataSet.fillColor = UIColor(series.color)
            }

            if let dashPattern = series.dashPattern {
                dataSet.lineDashLengths = dashPattern
            }

            dataSet.highlightEnabled = true
            dataSet.highlightColor = UIColor(series.color)
            dataSet.highlightLineWidth = 1.0

            // Apply foreground style scale if available
            if let style = foregroundStyleScale[series.name] {
                // Note: DGCharts uses solid colors, not ShapeStyles
            }

            dataSets.append(dataSet)
        }

        let lineData = LineChartData(dataSets: dataSets)
        lineData.setDrawValues(false)
        uiView.data = lineData

        // Update axes
        updateXAxis(uiView)
        updateYAxis(uiView)

        // Update legend
        updateLegend(uiView)

        // Update rule marks
        updateRuleMarks(uiView)

        // Update interaction
        updateInteraction(uiView)

        // Update scrolling
        updateScrolling(uiView)

        // Update appearance
        updateAppearance(uiView)

        // Handle scroll position binding
        if let scrollPosition = scrollPosition {
            let targetX = scrollPosition.wrappedValue.timeIntervalSince1970
            uiView.moveViewToX(targetX)
        }

        // Animate on appear
        if context.transaction.animation != nil {
            uiView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuad)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var delegate: DGChartInteractionDelegate?
    }

    // Helper methods
    private func updateXAxis(_ chartView: LineChartView) {
        let config = xAxisConfig ?? DGChartXAxisConfig()
        let xAxis = chartView.xAxis
        xAxis.labelPosition = axisPositionToDGCharts(config.position)
        xAxis.setLabelCount(config.labelCount, force: false)
        xAxis.labelRotationAngle = config.labelRotation
        xAxis.granularity = config.granularity
        xAxis.granularityEnabled = config.granularityEnabled
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = gridColor
        xAxis.gridLineWidth = gridLineWidth

        if let dateFormat = config.dateFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            xAxis.valueFormatter = DateAxisValueFormatter(formatter: formatter)
        } else if let customFormatter = config.customFormatter {
            xAxis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }
    }

    private func updateYAxis(_ chartView: LineChartView) {
        let config = yAxisConfig ?? DGChartYAxisConfig()
        let yAxis = chartView.leftAxis
        let rightAxis = chartView.rightAxis

        switch config.position {
        case .left:
            rightAxis.enabled = false
        case .right:
            yAxis.enabled = false
        case .bothSided:
            rightAxis.enabled = true
        }

        updateYAxisSettings(yAxis)
        if config.position == .bothSided {
            updateYAxisSettings(rightAxis)
        }

        // Apply domain if set
        if let domain = yDomain {
            yAxis.axisMinimum = domain.lowerBound
            yAxis.axisMaximum = domain.upperBound
        }
    }

    private func updateYAxisSettings(_ axis: YAxis) {
        let config = yAxisConfig ?? DGChartYAxisConfig()
        axis.setLabelCount(config.labelCount, force: false)
        axis.granularity = config.granularity
        axis.granularityEnabled = config.granularityEnabled
        axis.drawGridLinesEnabled = true
        axis.gridColor = gridColor
        axis.gridLineWidth = gridLineWidth

        if let customFormatter = config.customFormatter {
            axis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }
    }

    private func updateLegend(_ chartView: LineChartView) {
        let config = legendConfig ?? DGChartLegendConfig()
        let legend = chartView.legend
        legend.enabled = config.isEnabled && !legendHidden

        switch config.position {
        case .belowChartLeft:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
        case .belowChartCenter:
            legend.horizontalAlignment = .center
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
        case .belowChartRight:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
        case .aboveChartLeft:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .top
            legend.orientation = .horizontal
        case .aboveChartCenter:
            legend.horizontalAlignment = .center
            legend.verticalAlignment = .top
            legend.orientation = .horizontal
        case .aboveChartRight:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .horizontal
        case .rightOfChartCenter:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .center
            legend.orientation = .vertical
        case .rightOfChartTop:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .vertical
        case .leftOfChartCenter:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .center
            legend.orientation = .vertical
        case .leftOfChartTop:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .top
            legend.orientation = .vertical
        }

        legend.font = config.font
        legend.textColor = config.textColor
        legend.drawInside = false
    }

    private func updateRuleMarks(_ chartView: LineChartView) {
        chartView.leftAxis.removeAllLimitLines()
        chartView.rightAxis.removeAllLimitLines()
        chartView.xAxis.removeAllLimitLines()

        for ruleMark in ruleMarks {
            let limitLine = ChartLimitLine(limit: ruleMark.position)
            limitLine.lineColor = UIColor(ruleMark.color)
            limitLine.lineWidth = ruleMark.lineWidth
            if let dashPattern = ruleMark.dashPattern {
                limitLine.lineDashLengths = dashPattern
            }
            if let label = ruleMark.label {
                limitLine.label = label
            }

            switch ruleMark.axis {
            case .x:
                chartView.xAxis.addLimitLine(limitLine)
            case .y:
                chartView.leftAxis.addLimitLine(limitLine)
            }
        }
    }

    private func updateInteraction(_ chartView: LineChartView) {
        chartView.pinchZoomEnabled = pinchZoomEnabled
        chartView.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        chartView.dragEnabled = dragEnabled
        chartView.scaleXEnabled = scaleXEnabled
        chartView.scaleYEnabled = scaleYEnabled
        chartView.highlightPerTapEnabled = true
        chartView.highlightPerDragEnabled = true

        // Set delegate for selection
        let delegate = DGChartInteractionDelegate()
        delegate.onSelectionChanged = { selection in
            self.selection?.wrappedValue = selection
            self.onSelectionChanged?(selection)
        }
        delegate.onNothingSelected = {
            self.selection?.wrappedValue = nil
        }
        chartView.delegate = delegate
    }

    private func updateScrolling(_ chartView: LineChartView) {
        if isScrollable, let visibleRange = visibleXRange {
            chartView.setVisibleXRangeMaximum(visibleRange)
            chartView.setVisibleXRangeMinimum(visibleRange)
        }
    }

    private func updateAppearance(_ chartView: LineChartView) {
        chartView.backgroundColor = backgroundColor
        chartView.drawGridBackgroundEnabled = false
        chartView.gridBackgroundColor = backgroundColor
        chartView.noDataText = "No Data"
        chartView.noDataFont = UIFont.systemFont(ofSize: 14)
        chartView.noDataTextColor = .secondaryLabel
    }

    private func axisPositionToDGCharts(_ position: DGChartXAxisConfig.AxisPosition) -> XAxis.LabelPosition {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .bothSided: return .bottom
        }
    }
}

struct DGBarChartSwiftUI: UIViewRepresentable {
    let data: [ChartSeriesData]
    let xAxisConfig: DGChartXAxisConfig?
    let yAxisConfig: DGChartYAxisConfig?
    let legendConfig: DGChartLegendConfig?
    let ruleMarks: [DGRuleMark]
    let yDomain: ClosedRange<Double>?
    let visibleXRange: Double?
    let scrollPosition: Binding<Date>?
    let isScrollable: Bool
    let legendHidden: Bool
    let frame: CGSize?
    let foregroundStyleScale: [String: AnyShapeStyle]
    let selection: Binding<DGChartSelection?>?
    let onSelectionChanged: ((DGChartSelection?) -> Void)?
    let pinchZoomEnabled: Bool
    let doubleTapToZoomEnabled: Bool
    let dragEnabled: Bool
    let scaleXEnabled: Bool
    let scaleYEnabled: Bool
    let backgroundColor: UIColor
    let gridColor: UIColor
    let gridLineWidth: CGFloat
    let barWidth: CGFloat
    let groupSpace: CGFloat

    func makeUIView(context: Context) -> BarChartView {
        let chartView = BarChartView()
        chartView.delegate = context.coordinator.delegate
        return chartView
    }

    func updateUIView(_ uiView: BarChartView, context: Context) {
        var dataSets: [BarChartDataSet] = []

        for series in data where series.isVisible && series.chartType == .bar {
            let entries = series.points.map { point in
                BarChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
            }

            let dataSet = BarChartDataSet(entries: entries, label: series.name)
            dataSet.colors = [UIColor(series.color)]
            dataSet.valueTextColor = UIColor(series.color)
            dataSet.highlightEnabled = true
            dataSet.highlightColor = UIColor(series.color)
            dataSet.highlightAlpha = 0.5

            dataSets.append(dataSet)
        }

        let barData = BarChartData(dataSets: dataSets)
        barData.setDrawValues(false)
        barData.barWidth = barWidth

        if dataSets.count > 1 {
            barData.groupBars(fromX: dataSets.first?.entryForIndex(0)?.x ?? 0, groupSpace: groupSpace, barSpace: 0.02)
        }

        uiView.data = barData

        // Update axes (similar to line chart)
        updateAxesAndAppearance(uiView)

        if context.transaction.animation != nil {
            uiView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuad)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var delegate: DGChartInteractionDelegate?
    }

    private func updateAxesAndAppearance(_ chartView: BarChartView) {
        let xConfig = xAxisConfig ?? DGChartXAxisConfig()
        let yConfig = yAxisConfig ?? DGChartYAxisConfig()
        let lConfig = legendConfig ?? DGChartLegendConfig()

        // X axis
        chartView.xAxis.labelPosition = axisPositionToDGCharts(xConfig.position)
        chartView.xAxis.setLabelCount(xConfig.labelCount, force: false)
        chartView.xAxis.labelRotationAngle = xConfig.labelRotation
        chartView.xAxis.granularity = xConfig.granularity
        chartView.xAxis.granularityEnabled = xConfig.granularityEnabled
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.gridColor = gridColor
        chartView.xAxis.gridLineWidth = gridLineWidth

        if let dateFormat = xConfig.dateFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            chartView.xAxis.valueFormatter = DateAxisValueFormatter(formatter: formatter)
        } else if let customFormatter = xConfig.customFormatter {
            chartView.xAxis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }

        // Y axis
        let yAxis = chartView.leftAxis
        let rightAxis = chartView.rightAxis

        switch yConfig.position {
        case .left:
            rightAxis.enabled = false
        case .right:
            yAxis.enabled = false
        case .bothSided:
            rightAxis.enabled = true
        }

        yAxis.setLabelCount(yConfig.labelCount, force: false)
        yAxis.granularity = yConfig.granularity
        yAxis.granularityEnabled = yConfig.granularityEnabled
        yAxis.drawGridLinesEnabled = true
        yAxis.gridColor = gridColor
        yAxis.gridLineWidth = gridLineWidth

        if let domain = yDomain {
            yAxis.axisMinimum = domain.lowerBound
            yAxis.axisMaximum = domain.upperBound
        }

        if let customFormatter = yConfig.customFormatter {
            yAxis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }

        if yConfig.position == .bothSided {
            rightAxis.setLabelCount(yConfig.labelCount, force: false)
            rightAxis.granularity = yConfig.granularity
            rightAxis.granularityEnabled = yConfig.granularityEnabled
            rightAxis.drawGridLinesEnabled = true
            rightAxis.gridColor = gridColor
            rightAxis.gridLineWidth = gridLineWidth
        }

        // Legend
        let legend = chartView.legend
        legend.enabled = lConfig.isEnabled && !legendHidden
        legend.font = lConfig.font
        legend.textColor = lConfig.textColor

        // Rule marks
        chartView.leftAxis.removeAllLimitLines()
        chartView.rightAxis.removeAllLimitLines()
        chartView.xAxis.removeAllLimitLines()

        for ruleMark in ruleMarks {
            let limitLine = ChartLimitLine(limit: ruleMark.position)
            limitLine.lineColor = UIColor(ruleMark.color)
            limitLine.lineWidth = ruleMark.lineWidth
            if let dashPattern = ruleMark.dashPattern {
                limitLine.lineDashLengths = dashPattern
            }
            if let label = ruleMark.label {
                limitLine.label = label
            }

            switch ruleMark.axis {
            case .x:
                chartView.xAxis.addLimitLine(limitLine)
            case .y:
                chartView.leftAxis.addLimitLine(limitLine)
            }
        }

        // Interaction
        chartView.pinchZoomEnabled = pinchZoomEnabled
        chartView.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        chartView.dragEnabled = dragEnabled
        chartView.scaleXEnabled = scaleXEnabled
        chartView.scaleYEnabled = scaleYEnabled
        chartView.highlightPerTapEnabled = true
        chartView.highlightPerDragEnabled = true

        // Scrolling
        if isScrollable, let visibleRange = visibleXRange {
            chartView.setVisibleXRangeMaximum(visibleRange)
            chartView.setVisibleXRangeMinimum(visibleRange)
        }

        // Appearance
        chartView.backgroundColor = backgroundColor
        chartView.drawGridBackgroundEnabled = false
        chartView.gridBackgroundColor = backgroundColor
        chartView.noDataText = "No Data"
    }

    private func axisPositionToDGCharts(_ position: DGChartXAxisConfig.AxisPosition) -> XAxis.LabelPosition {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .bothSided: return .bottom
        }
    }
}

struct DGCombinedChartSwiftUI: UIViewRepresentable {
    let data: [ChartSeriesData]
    let xAxisConfig: DGChartXAxisConfig?
    let yAxisConfig: DGChartYAxisConfig?
    let legendConfig: DGChartLegendConfig?
    let ruleMarks: [DGRuleMark]
    let yDomain: ClosedRange<Double>?
    let visibleXRange: Double?
    let scrollPosition: Binding<Date>?
    let isScrollable: Bool
    let legendHidden: Bool
    let frame: CGSize?
    let foregroundStyleScale: [String: AnyShapeStyle]
    let selection: Binding<DGChartSelection?>?
    let onSelectionChanged: ((DGChartSelection?) -> Void)?
    let pinchZoomEnabled: Bool
    let doubleTapToZoomEnabled: Bool
    let dragEnabled: Bool
    let scaleXEnabled: Bool
    let scaleYEnabled: Bool
    let backgroundColor: UIColor
    let gridColor: UIColor
    let gridLineWidth: CGFloat
    let drawCircles: Bool
    let circleRadius: CGFloat
    let mode: LineChartDataSet.Mode
    let cubicIntensity: CGFloat
    let barWidth: CGFloat
    let groupSpace: CGFloat

    func makeUIView(context: Context) -> CombinedChartView {
        let chartView = CombinedChartView()
        chartView.delegate = context.coordinator.delegate
        chartView.drawOrder = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.area.rawValue]
        return chartView
    }

    func updateUIView(_ uiView: CombinedChartView, context: Context) {
        var lineDataSets: [LineChartDataSet] = []
        var barDataSets: [BarChartDataSet] = []

        for series in data where series.isVisible {
            let entries = series.points.map { point in
                ChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
            }

            switch series.chartType {
            case .line, .area:
                let dataSet = LineChartDataSet(entries: entries, label: series.name)
                dataSet.colors = [UIColor(series.color)]
                dataSet.lineWidth = series.lineWidth
                dataSet.drawCirclesEnabled = drawCircles && series.chartType == .line
                dataSet.circleRadius = circleRadius
                dataSet.circleHoleRadius = circleRadius / 2
                dataSet.mode = mode
                dataSet.cubicIntensity = cubicIntensity

                if series.chartType == .area {
                    dataSet.drawFilledEnabled = true
                    dataSet.fillAlpha = series.fillAlpha
                    dataSet.fillColor = UIColor(series.fillColor ?? series.color)
                }

                if let dashPattern = series.dashPattern {
                    dataSet.lineDashLengths = dashPattern
                }

                dataSet.highlightEnabled = true
                dataSet.highlightColor = UIColor(series.color)

                lineDataSets.append(dataSet)

            case .bar:
                let barEntries = series.points.map { point in
                    BarChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
                }

                let dataSet = BarChartDataSet(entries: barEntries, label: series.name)
                dataSet.colors = [UIColor(series.color)]
                dataSet.valueTextColor = UIColor(series.color)
                dataSet.highlightEnabled = true
                dataSet.highlightColor = UIColor(series.color)

                barDataSets.append(dataSet)

            case .point:
                // Points rendered as line with circles
                let dataSet = LineChartDataSet(entries: entries, label: series.name)
                dataSet.colors = [UIColor(series.color)]
                dataSet.lineWidth = 0
                dataSet.drawCirclesEnabled = true
                dataSet.circleRadius = circleRadius
                dataSet.circleHoleRadius = circleRadius / 2
                dataSet.highlightEnabled = true
                dataSet.highlightColor = UIColor(series.color)

                lineDataSets.append(dataSet)
            }
        }

        let combinedData = CombinedChartData()
        combinedData.lineData = LineChartData(dataSets: lineDataSets)
        combinedData.lineData?.setDrawValues(false)
        combinedData.barData = BarChartData(dataSets: barDataSets)
        combinedData.barData?.setDrawValues(false)
        combinedData.barData?.barWidth = barWidth

        if barDataSets.count > 1 {
            combinedData.barData?.groupBars(fromX: barDataSets.first?.entryForIndex(0)?.x ?? 0, groupSpace: groupSpace, barSpace: 0.02)
        }

        uiView.data = combinedData

        // Update axes, legend, etc.
        updateAxesAndAppearance(uiView)

        if context.transaction.animation != nil {
            uiView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuad)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var delegate: DGChartInteractionDelegate?
    }

    private func updateAxesAndAppearance(_ chartView: CombinedChartView) {
        let xConfig = xAxisConfig ?? DGChartXAxisConfig()
        let yConfig = yAxisConfig ?? DGChartYAxisConfig()
        let lConfig = legendConfig ?? DGChartLegendConfig()

        // X axis
        chartView.xAxis.labelPosition = axisPositionToDGCharts(xConfig.position)
        chartView.xAxis.setLabelCount(xConfig.labelCount, force: false)
        chartView.xAxis.labelRotationAngle = xConfig.labelRotation
        chartView.xAxis.granularity = xConfig.granularity
        chartView.xAxis.granularityEnabled = xConfig.granularityEnabled
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.gridColor = gridColor
        chartView.xAxis.gridLineWidth = gridLineWidth

        if let dateFormat = xConfig.dateFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            chartView.xAxis.valueFormatter = DateAxisValueFormatter(formatter: formatter)
        } else if let customFormatter = xConfig.customFormatter {
            chartView.xAxis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }

        // Y axis
        let yAxis = chartView.leftAxis
        let rightAxis = chartView.rightAxis

        switch yConfig.position {
        case .left:
            rightAxis.enabled = false
        case .right:
            yAxis.enabled = false
        case .bothSided:
            rightAxis.enabled = true
        }

        yAxis.setLabelCount(yConfig.labelCount, force: false)
        yAxis.granularity = yConfig.granularity
        yAxis.granularityEnabled = yConfig.granularityEnabled
        yAxis.drawGridLinesEnabled = true
        yAxis.gridColor = gridColor
        yAxis.gridLineWidth = gridLineWidth

        if let domain = yDomain {
            yAxis.axisMinimum = domain.lowerBound
            yAxis.axisMaximum = domain.upperBound
        }

        if let customFormatter = yConfig.customFormatter {
            yAxis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }

        if yConfig.position == .bothSided {
            rightAxis.setLabelCount(yConfig.labelCount, force: false)
            rightAxis.granularity = yConfig.granularity
            rightAxis.granularityEnabled = yConfig.granularityEnabled
            rightAxis.drawGridLinesEnabled = true
            rightAxis.gridColor = gridColor
            rightAxis.gridLineWidth = gridLineWidth
        }

        // Legend
        let legend = chartView.legend
        legend.enabled = lConfig.isEnabled && !legendHidden
        legend.font = lConfig.font
        legend.textColor = lConfig.textColor

        // Rule marks
        chartView.leftAxis.removeAllLimitLines()
        chartView.rightAxis.removeAllLimitLines()
        chartView.xAxis.removeAllLimitLines()

        for ruleMark in ruleMarks {
            let limitLine = ChartLimitLine(limit: ruleMark.position)
            limitLine.lineColor = UIColor(ruleMark.color)
            limitLine.lineWidth = ruleMark.lineWidth
            if let dashPattern = ruleMark.dashPattern {
                limitLine.lineDashLengths = dashPattern
            }
            if let label = ruleMark.label {
                limitLine.label = label
            }

            switch ruleMark.axis {
            case .x:
                chartView.xAxis.addLimitLine(limitLine)
            case .y:
                chartView.leftAxis.addLimitLine(limitLine)
            }
        }

        // Interaction
        chartView.pinchZoomEnabled = pinchZoomEnabled
        chartView.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        chartView.dragEnabled = dragEnabled
        chartView.scaleXEnabled = scaleXEnabled
        chartView.scaleYEnabled = scaleYEnabled
        chartView.highlightPerTapEnabled = true
        chartView.highlightPerDragEnabled = true

        // Scrolling
        if isScrollable, let visibleRange = visibleXRange {
            chartView.setVisibleXRangeMaximum(visibleRange)
            chartView.setVisibleXRangeMinimum(visibleRange)
        }

        // Appearance
        chartView.backgroundColor = backgroundColor
        chartView.drawGridBackgroundEnabled = false
        chartView.gridBackgroundColor = backgroundColor
        chartView.noDataText = "No Data"
    }

    private func axisPositionToDGCharts(_ position: DGChartXAxisConfig.AxisPosition) -> XAxis.LabelPosition {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .bothSided: return .bottom
        }
    }
}

// MARK: - Re-export key types from DGChartsWrapper

public typealias DGChartXAxisConfig = DGChartsWrapper.DGChartXAxisConfig
public typealias DGChartYAxisConfig = DGChartsWrapper.DGChartYAxisConfig
public typealias DGChartLegendConfig = DGChartsWrapper.DGChartLegendConfig
public typealias DGRuleMark = DGChartsWrapper.DGRuleMark
public typealias DGChartSelection = DGChartsWrapper.DGChartSelection
public typealias DGChartInteractionDelegate = DGChartsWrapper.DGChartInteractionDelegate