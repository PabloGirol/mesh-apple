//
//  DGCharts.swift
//  Meshtastic
//
//  Unified export for DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Public API Exports

// Protocols & Base Types (from DGChartsProtocols)
public typealias DGChartDataPoint = DGChartDataPoint
public typealias DGChartDatePoint = DGChartDatePoint
public typealias DGChartCategoryPoint = DGChartCategoryPoint
public typealias DGLineStyle = DGLineStyle
public typealias DGMarkStyle = DGMarkStyle
public typealias DGChartSymbol = DGChartSymbol
public typealias DGChartAxisConfig = DGChartAxisConfig
public typealias DGDefaultAxisConfig = DGDefaultAxisConfig
public typealias DGChartAxisPosition = DGChartAxisPosition
public typealias DGChartAxisScale = DGChartAxisScale
public typealias DGChartLegendConfig = DGChartLegendConfig
public typealias DGDefaultLegendConfig = DGDefaultLegendConfig
public typealias DGChartLegendPosition = DGChartLegendPosition
public typealias DGChartSelectionConfig = DGChartSelectionConfig
public typealias DGDefaultSelectionConfig = DGDefaultSelectionConfig
public typealias DGChartSelectionMode = DGChartSelectionMode
public typealias DGChartScrollConfig = DGChartScrollConfig
public typealias DGDefaultScrollConfig = DGDefaultScrollConfig
public typealias DGChartAnimationConfig = DGChartAnimationConfig
public typealias DGDefaultAnimationConfig = DGDefaultAnimationConfig
public typealias DGChartEasingFunction = DGChartEasingFunction
public typealias DGChartColorScheme = DGChartColorScheme
public typealias DGDefaultColorScheme = DGDefaultColorScheme
public typealias DGCategoricalColorScheme = DGCategoricalColorScheme
public typealias DGSequentialColorScheme = DGSequentialColorScheme
public typealias DGDivergingColorScheme = DGDivergingColorScheme
public typealias DGChartDataSet = DGChartDataSet
public typealias DGChartView = DGChartView
public typealias DGChartFillFormatter = DGChartFillFormatter
public typealias DGDefaultFillFormatter = DGDefaultFillFormatter
public typealias DGChartHighlighter = DGChartHighlighter
public typealias DGChartViewBase = DGChartViewBase

// Chart Views (from DGChartsWrapper in Helpers/Charts - using actual DGCharts UIView types)
public typealias DGLineChartView = DGChartsWrapper.DGLineChartView
public typealias DGBarChartView = DGChartsWrapper.DGBarChartView
public typealias DGCombinedChartView = DGChartsWrapper.DGCombinedChartView
public typealias DGScatterChartView = DGChartsWrapper.DGScatterChartView
public typealias DGBaseChartView = DGChartsWrapper.DGBaseChartView
public typealias DGChartViewRepresentable = DGChartsWrapper.DGChartViewRepresentable

// Chart Series/Data (from DGChartsWrapper)
public typealias DGChartSeries = DGChartsWrapper.DGChartSeries
public typealias DGLineChartPoint = DGChartsWrapper.DGLineChartPoint
public typealias DGBarChartPoint = DGChartsWrapper.DGBarChartPoint
public typealias DGCombinedChartPoint = DGChartsWrapper.DGCombinedChartPoint
public typealias DGChartSelection = DGChartsWrapper.DGChartSelection
public typealias DGChartInteractionDelegate = DGChartsWrapper.DGChartInteractionDelegate
public typealias DGChartXAxisConfig = DGChartsWrapper.DGChartXAxisConfig
public typealias DGChartYAxisConfig = DGChartsWrapper.DGChartYAxisConfig
public typealias DGRuleMark = DGChartsWrapper.DGRuleMark
public typealias DGChartLegendConfig = DGChartsWrapper.DGChartLegendConfig

// Swift Charts-like API (from DGChartsSwiftUI)
public typealias LineChartView = DGChartsSwiftUI.LineChartView
public typealias BarChartView = DGChartsSwiftUI.BarChartView
public typealias CombinedChartView = DGChartsSwiftUI.CombinedChartView
public typealias ChartSeriesData = DGChartsSwiftUI.ChartSeriesData
public typealias ChartDataPoint = DGChartsSwiftUI.ChartDataPoint
public typealias LineMark = DGChartsSwiftUI.LineMark
public typealias PointMark = DGChartsSwiftUI.PointMark
public typealias RuleMark = DGChartsSwiftUI.RuleMark
public typealias AreaMark = DGChartsSwiftUI.AreaMark
public typealias BarMark = DGChartsSwiftUI.BarMark
public typealias PlottableValue = DGChartsSwiftUI.PlottableValue
public typealias Plottable = DGChartsSwiftUI.Plottable
public typealias MarkDimension = DGChartsSwiftUI.MarkDimension
public typealias ChartContentBuilder = DGChartsSwiftUI.ChartContentBuilder
public typealias ChartContent = DGChartsSwiftUI.ChartContent
public typealias Chart = DGChartsSwiftUI.Chart

// MARK: - Convenience Functions

/// Create a line chart with simple data points
public func makeLineChart(
    _ points: [DGLineChartPoint],
    label: String = "Series",
    color: Color = .blue,
    lineWidth: CGFloat = 2.0
) -> DGLineChartView {
    let chart = DGLineChartView()
    chart.series = [DGChartSeries(
        id: UUID().uuidString,
        name: label,
        abbreviatedName: String(label.prefix(3)),
        color: color,
        isVisible: true,
        chartType: .line,
        lineWidth: lineWidth
    )]
    chart.seriesData = [chart.series[0].id: points]
    return chart
}

/// Create a bar chart with simple data points
public func makeBarChart(
    _ points: [DGBarChartPoint],
    label: String = "Series",
    color: Color = .blue,
    barWidth: CGFloat = 0.8
) -> DGBarChartView {
    let chart = DGBarChartView()
    chart.series = [DGChartSeries(
        id: UUID().uuidString,
        name: label,
        abbreviatedName: String(label.prefix(3)),
        color: color,
        isVisible: true,
        chartType: .bar,
        lineWidth: 0
    )]
    chart.seriesData = [chart.series[0].id: points]
    chart.barWidth = barWidth
    return chart
}

/// Create an area chart with simple data points
public func makeAreaChart(
    _ points: [DGLineChartPoint],
    label: String = "Series",
    color: Color = .blue,
    lineWidth: CGFloat = 2.0,
    fillColor: Color? = nil,
    fillAlpha: CGFloat = 0.3
) -> DGCombinedChartView {
    let chart = DGCombinedChartView()
    chart.series = [DGChartSeries(
        id: UUID().uuidString,
        name: label,
        abbreviatedName: String(label.prefix(3)),
        color: color,
        isVisible: true,
        chartType: .area,
        lineWidth: lineWidth,
        fillColor: fillColor,
        fillAlpha: fillAlpha
    )]
    chart.seriesData = [chart.series[0].id: points.map { DGCombinedChartPoint(x: $0.x, y: $0.y, label: $0.label, type: .area) }]
    return chart
}

/// Create a point/scatter chart with simple data points
public func makePointChart(
    _ points: [DGLineChartPoint],
    label: String = "Series",
    color: Color = .blue,
    scatterShape: ScatterChartDataSet.Shape = .circle,
    scatterShapeSize: CGFloat = 8.0
) -> DGScatterChartView {
    let chart = DGScatterChartView()
    chart.series = [DGChartSeries(
        id: UUID().uuidString,
        name: label,
        abbreviatedName: String(label.prefix(3)),
        color: color,
        isVisible: true,
        chartType: .line,
        lineWidth: 0
    )]
    chart.seriesData = [chart.series[0].id: points]
    chart.scatterShape = scatterShape
    chart.scatterShapeSize = scatterShapeSize
    return chart
}

/// Create a combined chart with multiple data sets
public func makeCombinedChart(
    series: [DGChartSeries],
    seriesData: [String: [DGCombinedChartPoint]]
) -> DGCombinedChartView {
    let chart = DGCombinedChartView()
    chart.series = series
    chart.seriesData = seriesData
    return chart
}

// MARK: - Chart Container

/// A container view that provides common chart configuration via environment
public struct DGChartContainer<Content: View>: View {
    let content: Content

    public init(
        xAxisConfig: DGChartAxisConfig? = nil,
        yAxisConfig: DGChartAxisConfig? = nil,
        legendConfig: DGChartLegendConfig? = nil,
        selectionConfig: DGChartSelectionConfig? = nil,
        scrollConfig: DGChartScrollConfig? = nil,
        animationConfig: DGChartAnimationConfig? = nil,
        colorScheme: DGChartColorScheme? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}

// MARK: - Preview Helpers

#if DEBUG
public struct DGChartsPreview {
    public static var sampleLineData: [DGLineChartPoint] {
        (0..<20).map { i in
            DGLineChartPoint(x: Double(i), y: sin(Double(i) * 0.5) * 10 + Double.random(in: -1...1))
        }
    }

    public static var sampleDateData: [DGLineChartPoint] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<30).map { i in
            DGLineChartPoint(
                x: calendar.date(byAdding: .day, value: -i, to: now)!.timeIntervalSince1970,
                y: Double.random(in: 10...100)
            )
        }.reversed()
    }

    public static var sampleCategoryData: [DGBarChartPoint] {
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun"].enumerated().map { index, name in
            DGBarChartPoint(x: Double(index), y: Double.random(in: 10...100))
        }
    }

    public static var sampleMultiSeriesData: [[DGLineChartPoint]] {
        (0..<3).map { series in
            (0..<20).map { i in
                DGLineChartPoint(
                    x: Double(i),
                    y: sin(Double(i) * 0.5 + Double(series)) * 10 + Double(series) * 5
                )
            }
        }
    }
}
#endif