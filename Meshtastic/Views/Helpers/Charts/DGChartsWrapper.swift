//
//  DGChartsWrapper.swift
//  Meshtastic
//
//  SwiftUI wrappers for DGCharts (Daniel Gindi Charts) for iOS 15 compatibility
//

import SwiftUI
import DGCharts
import UIKit

// MARK: - Chart Data Points

/// Simple data point for line/area charts
public struct DGLineChartPoint: Identifiable {
    public let id = UUID()
    public let x: Double
    public let y: Double
    public let label: String?

    public init(x: Double, y: Double, label: String? = nil) {
        self.x = x
        self.y = y
        self.label = label
    }
}

/// Data point for bar charts
public struct DGBarChartPoint: Identifiable {
    public let id = UUID()
    public let x: Double
    public let y: Double
    public let label: String?

    public init(x: Double, y: Double, label: String? = nil) {
        self.x = x
        self.y = y
        self.label = label
    }
}

/// Data point for combined charts (line + bar, etc.)
public struct DGCombinedChartPoint: Identifiable {
    public let id = UUID()
    public let x: Double
    public let y: Double
    public let label: String?
    public let type: ChartType

    public enum ChartType {
        case line
        case bar
        case area
    }

    public init(x: Double, y: Double, label: String? = nil, type: ChartType = .line) {
        self.x = x
        self.y = y
        self.label = label
        self.type = type
    }
}

// MARK: - Chart Series Configuration

/// Configuration for a single data series in the chart
public struct DGChartSeries: Identifiable {
    public let id: String
    public let name: String
    public let abbreviatedName: String
    public let color: Color
    public let isVisible: Bool
    public let chartType: DGCombinedChartPoint.ChartType
    public let lineWidth: CGFloat
    public let dashPattern: [CGFloat]?
    public let fillColor: Color?
    public let fillAlpha: CGFloat

    public init(
        id: String,
        name: String,
        abbreviatedName: String,
        color: Color,
        isVisible: Bool = true,
        chartType: DGCombinedChartPoint.ChartType = .line,
        lineWidth: CGFloat = 2.0,
        dashPattern: [CGFloat]? = nil,
        fillColor: Color? = nil,
        fillAlpha: CGFloat = 0.3
    ) {
        self.id = id
        self.name = name
        self.abbreviatedName = abbreviatedName
        self.color = color
        self.isVisible = isVisible
        self.chartType = chartType
        self.lineWidth = lineWidth
        self.dashPattern = dashPattern
        self.fillColor = fillColor
        self.fillAlpha = fillAlpha
    }
}

// MARK: - Chart Axis Configuration

/// X-axis configuration
public struct DGChartXAxisConfig {
    public let position: AxisPosition
    public let labelCount: Int
    public let labelRotation: CGFloat
    public let dateFormat: String?
    public let customFormatter: ((Double) -> String)?
    public let granularity: Double
    public let granularityEnabled: Bool

    public enum AxisPosition {
        case top
        case bottom
        case bothSided
    }

    public init(
        position: AxisPosition = .bottom,
        labelCount: Int = 6,
        labelRotation: CGFloat = 0,
        dateFormat: String? = nil,
        customFormatter: ((Double) -> String)? = nil,
        granularity: Double = 1.0,
        granularityEnabled: Bool = false
    ) {
        self.position = position
        self.labelCount = labelCount
        self.labelRotation = labelRotation
        self.dateFormat = dateFormat
        self.customFormatter = customFormatter
        self.granularity = granularity
        self.granularityEnabled = granularityEnabled
    }
}

/// Y-axis configuration
public struct DGChartYAxisConfig {
    public let position: AxisPosition
    public let labelCount: Int
    public let axisMinimum: Double?
    public let axisMaximum: Double?
    public let axisMinCustom: Bool
    public let axisMaxCustom: Bool
    public let granularity: Double
    public let granularityEnabled: Bool
    public let customFormatter: ((Double) -> String)?

    public enum AxisPosition {
        case left
        case right
        case bothSided
    }

    public init(
        position: AxisPosition = .left,
        labelCount: Int = 6,
        axisMinimum: Double? = nil,
        axisMaximum: Double? = nil,
        granularity: Double = 1.0,
        granularityEnabled: Bool = false,
        customFormatter: ((Double) -> String)? = nil
    ) {
        self.position = position
        self.labelCount = labelCount
        self.axisMinimum = axisMinimum
        self.axisMaximum = axisMaximum
        self.axisMinCustom = axisMinimum != nil
        self.axisMaxCustom = axisMaximum != nil
        self.granularity = granularity
        self.granularityEnabled = granularityEnabled
        self.customFormatter = customFormatter
    }
}

// MARK: - Chart Selection/Interaction

/// Represents a selected data point in the chart
public struct DGChartSelection: Equatable {
    public let x: Double
    public let y: Double
    public let dataSetIndex: Int
    public let entryIndex: Int

    public init(x: Double, y: Double, dataSetIndex: Int, entryIndex: Int) {
        self.x = x
        self.y = y
        self.dataSetIndex = dataSetIndex
        self.entryIndex = entryIndex
    }
}

/// Chart interaction delegate for SwiftUI
public class DGChartInteractionDelegate: NSObject, ChartViewDelegate {
    public var onSelectionChanged: ((DGChartSelection?) -> Void)?
    public var onNothingSelected: (() -> Void)?

    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let selection = DGChartSelection(
            x: entry.x,
            y: entry.y,
            dataSetIndex: highlight.dataSetIndex,
            entryIndex: Int(highlight.xPx)
        )
        onSelectionChanged?(selection)
    }

    public func chartValueNothingSelected(_ chartView: ChartViewBase) {
        onNothingSelected?()
    }
}

// MARK: - Rule Mark (Reference Lines)

/// Configuration for a rule mark (horizontal/vertical reference line)
public struct DGRuleMark {
    public let position: Double
    public let axis: Axis
    public let color: Color
    public let lineWidth: CGFloat
    public let dashPattern: [CGFloat]?
    public let label: String?

    public enum Axis {
        case x
        case y
    }

    public init(
        position: Double,
        axis: Axis,
        color: Color = .primary,
        lineWidth: CGFloat = 1.0,
        dashPattern: [CGFloat]? = nil,
        label: String? = nil
    ) {
        self.position = position
        self.axis = axis
        self.color = color
        self.lineWidth = lineWidth
        self.dashPattern = dashPattern
        self.label = label
    }
}

// MARK: - Legend Configuration

public struct DGChartLegendConfig {
    public let isEnabled: Bool
    public let position: LegendPosition
    public let alignment: LegendAlignment
    public let orientation: LegendOrientation
    public let font: UIFont
    public let textColor: UIColor

    public enum LegendPosition {
        case belowChartLeft
        case belowChartCenter
        case belowChartRight
        case aboveChartLeft
        case aboveChartCenter
        case aboveChartRight
        case rightOfChartCenter
        case rightOfChartTop
        case leftOfChartCenter
        case leftOfChartTop
    }

    public enum LegendAlignment {
        case left
        case center
        case right
    }

    public enum LegendOrientation {
        case horizontal
        case vertical
    }

    public init(
        isEnabled: Bool = true,
        position: LegendPosition = .belowChartCenter,
        alignment: LegendAlignment = .center,
        orientation: LegendOrientation = .horizontal,
        font: UIFont = UIFont.systemFont(ofSize: 10),
        textColor: UIColor = .label
    ) {
        self.isEnabled = isEnabled
        self.position = position
        self.alignment = alignment
        self.orientation = orientation
        self.font = font
        self.textColor = textColor
    }
}

// MARK: - Main Chart View Protocol

public protocol DGChartViewRepresentable: UIViewRepresentable {
    associatedtype ChartType: ChartViewBase
    func makeChartView(context: Context) -> ChartType
    func updateChartView(_ chartView: ChartType, context: Context)
}

// MARK: - Base Chart View

/// Base class for all DGCharts SwiftUI wrappers
open class DGBaseChartView<ChartViewType: ChartViewBase>: UIViewRepresentable {
    public typealias UIViewType = ChartViewType

    // Data
    public var series: [DGChartSeries] = []
    public var seriesData: [String: [Any]] = [:]

    // Configuration
    public var xAxisConfig: DGChartXAxisConfig = DGChartXAxisConfig()
    public var yAxisConfig: DGChartYAxisConfig = DGChartYAxisConfig()
    public var legendConfig: DGChartLegendConfig = DGChartLegendConfig()
    public var ruleMarks: [DGRuleMark] = []

    // Interaction
    public var selection: Binding<DGChartSelection?>?
    public var onSelectionChanged: ((DGChartSelection?) -> Void)?
    public var pinchZoomEnabled: Bool = true
    public var doubleTapToZoomEnabled: Bool = true
    public var dragEnabled: Bool = true
    public var scaleXEnabled: Bool = true
    public var scaleYEnabled: Bool = true

    // Scrolling
    public var isScrollableHorizontal: Bool = false
    public var visibleXRange: Double?

    // Appearance
    public var backgroundColor: UIColor = .systemBackground
    public var gridColor: UIColor = .systemGray4
    public var gridLineWidth: CGFloat = 0.5
    public var drawGridBackground: Bool = false

    // Animation
    public var animateOnAppear: Bool = true
    public var animationDuration: TimeInterval = 1.0
    public var easingOption: ChartEasingOption = .easeInOutQuad

    public init() {}

    open func makeChartView(context: Context) -> ChartViewType {
        fatalError("Subclasses must implement makeChartView")
    }

    open func updateChartView(_ chartView: ChartViewType, context: Context) {
        // Update data
        updateData(chartView)

        // Update axes
        updateXAxis(chartView)
        updateYAxis(chartView)

        // Update legend
        updateLegend(chartView)

        // Update rule marks (limit lines)
        updateRuleMarks(chartView)

        // Update interaction
        updateInteraction(chartView)

        // Update scrolling
        updateScrolling(chartView)

        // Update appearance
        updateAppearance(chartView)

        // Animate if needed
        if animateOnAppear && context.transaction.animation != nil {
            chartView.animate(xAxisDuration: animationDuration, yAxisDuration: animationDuration, easingOption: easingOption)
        }
    }

    open func makeUIView(context: Context) -> ChartViewType {
        let chartView = makeChartView(context: context)

        // Set delegate for interaction
        let delegate = DGChartInteractionDelegate()
        delegate.onSelectionChanged = { [weak self] selection in
            self?.selection?.wrappedValue = selection
            self?.onSelectionChanged?(selection)
        }
        delegate.onNothingSelected = { [weak self] in
            self?.selection?.wrappedValue = nil
        }
        chartView.delegate = delegate
        context.coordinator.delegate = delegate

        return chartView
    }

    open func updateUIView(_ uiView: ChartViewType, context: Context) {
        updateChartView(uiView, context: context)
    }

    open func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator {
        var delegate: DGChartInteractionDelegate?
    }

    // MARK: - Update Methods (to be overridden by subclasses)

    open func updateData(_ chartView: ChartViewType) {
        // Override in subclasses
    }

    open func updateXAxis(_ chartView: ChartViewType) {
        let xAxis = chartView.xAxis
        xAxis.labelPosition = axisPositionToDGCharts(xAxisConfig.position)
        xAxis.setLabelCount(xAxisConfig.labelCount, force: false)
        xAxis.labelRotationAngle = xAxisConfig.labelRotation
        xAxis.granularity = xAxisConfig.granularity
        xAxis.granularityEnabled = xAxisConfig.granularityEnabled
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = gridColor
        xAxis.gridLineWidth = gridLineWidth

        if let dateFormat = xAxisConfig.dateFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            xAxis.valueFormatter = DateAxisValueFormatter(formatter: formatter)
        } else if let customFormatter = xAxisConfig.customFormatter {
            xAxis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }
    }

    open func updateYAxis(_ chartView: ChartViewType) {
        let yAxis = chartView.leftAxis
        let rightAxis = chartView.rightAxis

        let targetAxis: YAxis
        switch yAxisConfig.position {
        case .left:
            targetAxis = yAxis
            rightAxis.enabled = false
        case .right:
            targetAxis = rightAxis
            yAxis.enabled = false
        case .bothSided:
            targetAxis = yAxis
            rightAxis.enabled = true
            // Mirror left axis settings to right
            updateYAxisSettings(rightAxis)
        }

        updateYAxisSettings(targetAxis)
    }

    private func updateYAxisSettings(_ axis: YAxis) {
        axis.setLabelCount(yAxisConfig.labelCount, force: false)
        axis.granularity = yAxisConfig.granularity
        axis.granularityEnabled = yAxisConfig.granularityEnabled
        axis.drawGridLinesEnabled = true
        axis.gridColor = gridColor
        axis.gridLineWidth = gridLineWidth

        if yAxisConfig.axisMinCustom {
            axis.axisMinimum = yAxisConfig.axisMinimum ?? 0
        }
        if yAxisConfig.axisMaxCustom {
            axis.axisMaximum = yAxisConfig.axisMaximum ?? 0
        }

        if let customFormatter = yAxisConfig.customFormatter {
            axis.valueFormatter = CustomAxisValueFormatter(block: customFormatter)
        }
    }

    open func updateLegend(_ chartView: ChartViewType) {
        let legend = chartView.legend
        legend.enabled = legendConfig.isEnabled

        switch legendConfig.position {
        case .belowChartLeft:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
            legend.drawInside = false
        case .belowChartCenter:
            legend.horizontalAlignment = .center
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
            legend.drawInside = false
        case .belowChartRight:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
            legend.drawInside = false
        case .aboveChartLeft:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .top
            legend.orientation = .horizontal
            legend.drawInside = false
        case .aboveChartCenter:
            legend.horizontalAlignment = .center
            legend.verticalAlignment = .top
            legend.orientation = .horizontal
            legend.drawInside = false
        case .aboveChartRight:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .horizontal
            legend.drawInside = false
        case .rightOfChartCenter:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .center
            legend.orientation = .vertical
            legend.drawInside = false
        case .rightOfChartTop:
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .vertical
            legend.drawInside = false
        case .leftOfChartCenter:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .center
            legend.orientation = .vertical
            legend.drawInside = false
        case .leftOfChartTop:
            legend.horizontalAlignment = .left
            legend.verticalAlignment = .top
            legend.orientation = .vertical
            legend.drawInside = false
        }

        legend.font = legendConfig.font
        legend.textColor = legendConfig.textColor
    }

    open func updateRuleMarks(_ chartView: ChartViewType) {
        // Clear existing limit lines
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

    open func updateInteraction(_ chartView: ChartViewType) {
        chartView.pinchZoomEnabled = pinchZoomEnabled
        chartView.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        chartView.dragEnabled = dragEnabled
        chartView.scaleXEnabled = scaleXEnabled
        chartView.scaleYEnabled = scaleYEnabled
        chartView.highlightPerTapEnabled = true
        chartView.highlightPerDragEnabled = true
    }

    open func updateScrolling(_ chartView: ChartViewType) {
        if isScrollableHorizontal, let visibleRange = visibleXRange {
            chartView.setVisibleXRangeMaximum(visibleRange)
            chartView.setVisibleXRangeMinimum(visibleRange)
        } else {
            chartView.setVisibleXRangeMaximum(chartView.xAxis.axisMaximum - chartView.xAxis.axisMinimum)
        }
    }

    open func updateAppearance(_ chartView: ChartViewType) {
        chartView.backgroundColor = backgroundColor
        chartView.drawGridBackgroundEnabled = drawGridBackground
        chartView.gridBackgroundColor = backgroundColor
        chartView.noDataText = "No Data"
        chartView.noDataFont = UIFont.systemFont(ofSize: 14)
        chartView.noDataTextColor = .secondaryLabel
    }

    private func axisPositionToDGCharts(_ position: DGChartXAxisConfig.AxisPosition) -> XAxis.LabelPosition {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .bothSided: return .bottom // DGCharts doesn't support both natively
        }
    }
}

// MARK: - Custom Value Formatters

/// Custom axis value formatter using a closure
private class CustomAxisValueFormatter: NSObject, AxisValueFormatter {
    let block: (Double) -> String

    init(block: @escaping (Double) -> String) {
        self.block = block
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return block(value)
    }
}

/// Date-based axis value formatter
private class DateAxisValueFormatter: NSObject, AxisValueFormatter {
    let formatter: DateFormatter

    init(formatter: DateFormatter) {
        self.formatter = formatter
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return formatter.string(from: date)
    }
}

// MARK: - Line Chart View

/// SwiftUI wrapper for DGCharts LineChartView
public final class DGLineChartView: DGBaseChartView<LineChartView>, DGChartViewRepresentable {
    public typealias ChartType = LineChartView

    // Line specific
    public var drawCircles: Bool = false
    public var circleRadius: CGFloat = 4.0
    public var circleHoleRadius: CGFloat = 2.0
    public var mode: LineChartDataSet.Mode = .linear
    public var cubicIntensity: CGFloat = 0.2
    public var drawFilled: Bool = false
    public var fillAlpha: CGFloat = 0.3
    public var gradientPositions: [CGFloat]? = nil

    public override init() {
        super.init()
    }

    public override func makeChartView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        chartView.delegate = context.coordinator.delegate
        return chartView
    }

    public override func updateChartView(_ chartView: LineChartView, context: Context) {
        // Update data
        var dataSets: [LineChartDataSet] = []

        for seriesItem in series where seriesItem.isVisible {
            guard let points = seriesData[seriesItem.id] as? [DGLineChartPoint], !points.isEmpty else { continue }

            let entries = points.map { point in
                ChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
            }

            let dataSet = LineChartDataSet(entries: entries, label: seriesItem.name)
            dataSet.colors = [UIColor(seriesItem.color)]
            dataSet.lineWidth = seriesItem.lineWidth
            dataSet.drawCirclesEnabled = drawCircles
            dataSet.circleRadius = circleRadius
            dataSet.circleHoleRadius = circleHoleRadius
            dataSet.mode = mode
            dataSet.cubicIntensity = cubicIntensity
            dataSet.drawFilledEnabled = drawFilled || seriesItem.fillColor != nil
            dataSet.fillAlpha = seriesItem.fillAlpha

            if let fillColor = seriesItem.fillColor {
                dataSet.fillColor = UIColor(fillColor)
            }

            if let dashPattern = seriesItem.dashPattern {
                dataSet.lineDashLengths = dashPattern
            }

            dataSet.highlightEnabled = true
            dataSet.highlightColor = UIColor(seriesItem.color)
            dataSet.highlightLineWidth = 1.0

            // Gradient fill
            if let gradientPositions = gradientPositions, drawFilled {
                let colors = [UIColor(seriesItem.color).cgColor, UIColor.clear.cgColor]
                if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: gradientPositions) {
                    dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
                }
            }

            dataSets.append(dataSet)
        }

        let data = LineChartData(dataSets: dataSets)
        data.setDrawValues(false)
        chartView.data = data

        // Call base class update methods for common configuration
        super.updateChartView(chartView, context: context)
    }
}

// MARK: - Bar Chart View

/// SwiftUI wrapper for DGCharts BarChartView
public final class DGBarChartView: DGBaseChartView<BarChartView>, DGChartViewRepresentable {
    public typealias ChartType = BarChartView

    // Bar specific
    public var barWidth: CGFloat = 0.8
    public var groupSpace: CGFloat = 0.1
    public var drawValueAboveBar: Bool = false

    public override init() {
        super.init()
    }

    public override func makeChartView(context: Context) -> BarChartView {
        let chartView = BarChartView()
        chartView.delegate = context.coordinator.delegate
        return chartView
    }

    public override func updateChartView(_ chartView: BarChartView, context: Context) {
        var dataSets: [BarChartDataSet] = []

        for seriesItem in series where seriesItem.isVisible {
            guard let points = seriesData[seriesItem.id] as? [DGBarChartPoint], !points.isEmpty else { continue }

            let entries = points.map { point in
                BarChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
            }

            let dataSet = BarChartDataSet(entries: entries, label: seriesItem.name)
            dataSet.colors = [UIColor(seriesItem.color)]
            dataSet.valueTextColor = UIColor(seriesItem.color)
            dataSet.highlightEnabled = true
            dataSet.highlightColor = UIColor(seriesItem.color)
            dataSet.highlightAlpha = 0.5

            dataSets.append(dataSet)
        }

        let data = BarChartData(dataSets: dataSets)
        data.setDrawValues(drawValueAboveBar)
        data.barWidth = barWidth

        if dataSets.count > 1 {
            data.groupBars(fromX: dataSets.first?.entryForIndex(0)?.x ?? 0, groupSpace: groupSpace, barSpace: 0.02)
        }

        chartView.data = data

        // Call base class update methods for common configuration
        super.updateChartView(chartView, context: context)
    }
}

// MARK: - Combined Chart View (Line + Bar + Area)

/// SwiftUI wrapper for DGCharts CombinedChartView - supports multiple chart types in one view
public final class DGCombinedChartView: DGBaseChartView<CombinedChartView>, DGChartViewRepresentable {
    public typealias ChartType = CombinedChartView

    // Line specific
    public var drawCircles: Bool = false
    public var circleRadius: CGFloat = 4.0
    public var circleHoleRadius: CGFloat = 2.0
    public var mode: LineChartDataSet.Mode = .linear
    public var cubicIntensity: CGFloat = 0.2

    // Bar specific
    public var barWidth: CGFloat = 0.8
    public var groupSpace: CGFloat = 0.1

    public override init() {
        super.init()
    }

    public override func makeChartView(context: Context) -> CombinedChartView {
        let chartView = CombinedChartView()
        chartView.delegate = context.coordinator.delegate
        // Order of drawing: bar, bubble, line, candle, scatter, area
        chartView.drawOrder = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.area.rawValue]
        return chartView
    }

    public override func updateChartView(_ chartView: CombinedChartView, context: Context) {
        var lineDataSets: [LineChartDataSet] = []
        var barDataSets: [BarChartDataSet] = []
        var areaDataSets: [LineChartDataSet] = [] // Area uses LineChartDataSet with fill

        for seriesItem in series where seriesItem.isVisible {
            guard let points = seriesData[seriesItem.id] as? [DGCombinedChartPoint], !points.isEmpty else { continue }

            switch seriesItem.chartType {
            case .line:
                let entries = points.map { point in
                    ChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
                }

                let dataSet = LineChartDataSet(entries: entries, label: seriesItem.name)
                dataSet.colors = [UIColor(seriesItem.color)]
                dataSet.lineWidth = seriesItem.lineWidth
                dataSet.drawCirclesEnabled = drawCircles
                dataSet.circleRadius = circleRadius
                dataSet.circleHoleRadius = circleHoleRadius
                dataSet.mode = mode
                dataSet.cubicIntensity = cubicIntensity
                dataSet.drawFilledEnabled = false
                dataSet.highlightEnabled = true
                dataSet.highlightColor = UIColor(seriesItem.color)

                if let dashPattern = seriesItem.dashPattern {
                    dataSet.lineDashLengths = dashPattern
                }

                lineDataSets.append(dataSet)

            case .bar:
                let entries = points.map { point in
                    BarChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
                }

                let dataSet = BarChartDataSet(entries: entries, label: seriesItem.name)
                dataSet.colors = [UIColor(seriesItem.color)]
                dataSet.valueTextColor = UIColor(seriesItem.color)
                dataSet.highlightEnabled = true
                dataSet.highlightColor = UIColor(seriesItem.color)

                barDataSets.append(dataSet)

            case .area:
                let entries = points.map { point in
                    ChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
                }

                let dataSet = LineChartDataSet(entries: entries, label: seriesItem.name)
                dataSet.colors = [UIColor(seriesItem.color)]
                dataSet.lineWidth = seriesItem.lineWidth
                dataSet.drawCirclesEnabled = false
                dataSet.mode = mode
                dataSet.cubicIntensity = cubicIntensity
                dataSet.drawFilledEnabled = true
                dataSet.fillAlpha = seriesItem.fillAlpha
                dataSet.fillColor = UIColor(seriesItem.fillColor ?? seriesItem.color)
                dataSet.highlightEnabled = true
                dataSet.highlightColor = UIColor(seriesItem.color)

                areaDataSets.append(dataSet)
            }
        }

        let data = CombinedChartData()
        data.lineData = LineChartData(dataSets: lineDataSets)
        data.lineData?.setDrawValues(false)
        data.barData = BarChartData(dataSets: barDataSets)
        data.barData?.setDrawValues(false)
        data.barData?.barWidth = barWidth
        if barDataSets.count > 1 {
            data.barData?.groupBars(fromX: barDataSets.first?.entryForIndex(0)?.x ?? 0, groupSpace: groupSpace, barSpace: 0.02)
        }
        // Area is rendered as filled line data
        if !areaDataSets.isEmpty {
            // Add area data to line data for rendering
            var allLineSets = lineDataSets
            allLineSets.append(contentsOf: areaDataSets)
            data.lineData = LineChartData(dataSets: allLineSets)
        }

        chartView.data = data

        // Call base class update methods for common configuration
        super.updateChartView(chartView, context: context)
    }
}

// MARK: - Scatter/Point Chart View

/// SwiftUI wrapper for DGCharts ScatterChartView
public final class DGScatterChartView: DGBaseChartView<ScatterChartView>, DGChartViewRepresentable {
    public typealias ChartType = ScatterChartView

    // Scatter specific
    public var scatterShape: ScatterChartDataSet.Shape = .circle
    public var scatterShapeSize: CGFloat = 8.0
    public var drawValuesEnabled: Bool = false

    public override init() {
        super.init()
    }

    public override func makeChartView(context: Context) -> ScatterChartView {
        let chartView = ScatterChartView()
        chartView.delegate = context.coordinator.delegate
        return chartView
    }

    public override func updateChartView(_ chartView: ScatterChartView, context: Context) {
        var dataSets: [ScatterChartDataSet] = []

        for seriesItem in series where seriesItem.isVisible {
            guard let points = seriesData[seriesItem.id] as? [DGLineChartPoint], !points.isEmpty else { continue }

            let entries = points.map { point in
                ChartDataEntry(x: point.x, y: point.y, data: point.label as Any?)
            }

            let dataSet = ScatterChartDataSet(entries: entries, label: seriesItem.name)
            dataSet.colors = [UIColor(seriesItem.color)]
            dataSet.setScatterShape(scatterShape)
            dataSet.scatterShapeSize = scatterShapeSize
            dataSet.valueTextColor = UIColor(seriesItem.color)
            dataSet.highlightEnabled = true
            dataSet.highlightColor = UIColor(seriesItem.color)

            dataSets.append(dataSet)
        }

        let data = ScatterChartData(dataSets: dataSets)
        data.setDrawValues(drawValuesEnabled)
        chartView.data = data

        // Call base class update methods for common configuration
        super.updateChartView(chartView, context: context)
    }
}

// MARK: - Convenience Extensions


// Helper for creating date-based x values
public func dateToChartX(_ date: Date) -> Double {
    return date.timeIntervalSince1970
}

public func chartXToDate(_ x: Double) -> Date {
    return Date(timeIntervalSince1970: x)
}