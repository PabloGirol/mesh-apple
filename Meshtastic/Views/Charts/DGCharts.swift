//
//  DGCharts.swift
//  Meshtastic
//
//  Unified export for DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Public API Exports

// Protocols & Base Types
public typealias DGChartDataPoint = DGChartsProtocols.DGChartDataPoint
public typealias DGChartPoint = DGChartsProtocols.DGChartPoint
public typealias DGChartDatePoint = DGChartsProtocols.DGChartDatePoint
public typealias DGChartCategoryPoint = DGChartsProtocols.DGChartCategoryPoint
public typealias DGLineStyle = DGChartsProtocols.DGLineStyle
public typealias DGMarkStyle = DGChartsProtocols.DGMarkStyle
public typealias DGChartSymbol = DGChartsProtocols.DGChartSymbol
public typealias DGChartAxisConfig = DGChartsProtocols.DGChartAxisConfig
public typealias DGDefaultAxisConfig = DGChartsProtocols.DGDefaultAxisConfig
public typealias DGChartAxisPosition = DGChartsProtocols.DGChartAxisPosition
public typealias DGChartAxisScale = DGChartsProtocols.DGChartAxisScale
public typealias DGChartLegendConfig = DGChartsProtocols.DGChartLegendConfig
public typealias DGDefaultLegendConfig = DGChartsProtocols.DGDefaultLegendConfig
public typealias DGChartLegendPosition = DGChartsProtocols.DGChartLegendPosition
public typealias DGChartSelectionConfig = DGChartsProtocols.DGChartSelectionConfig
public typealias DGDefaultSelectionConfig = DGChartsProtocols.DGDefaultSelectionConfig
public typealias DGChartSelectionMode = DGChartsProtocols.DGChartSelectionMode
public typealias DGChartScrollConfig = DGChartsProtocols.DGChartScrollConfig
public typealias DGDefaultScrollConfig = DGChartsProtocols.DGDefaultScrollConfig
public typealias DGChartAnimationConfig = DGChartsProtocols.DGChartAnimationConfig
public typealias DGDefaultAnimationConfig = DGChartsProtocols.DGDefaultAnimationConfig
public typealias DGChartEasingFunction = DGChartsProtocols.DGChartEasingFunction
public typealias DGChartColorScheme = DGChartsProtocols.DGChartColorScheme
public typealias DGDefaultColorScheme = DGChartsProtocols.DGDefaultColorScheme
public typealias DGCategoricalColorScheme = DGChartsProtocols.DGCategoricalColorScheme
public typealias DGSequentialColorScheme = DGChartsProtocols.DGSequentialColorScheme
public typealias DGDivergingColorScheme = DGChartsProtocols.DGDivergingColorScheme
public typealias DGChartDataSet = DGChartsProtocols.DGChartDataSet
public typealias DGChartView = DGChartsProtocols.DGChartView
public typealias ChartGesture = DGChartsProtocols.ChartGesture

// Chart Views
public typealias DGLineChart = DGCharts.DGLineChart
public typealias DGLineChartDataSet = DGCharts.DGLineChartDataSet
public typealias DGChartInterpolationMethod = DGCharts.DGChartInterpolationMethod

public typealias DGBarChart = DGCharts.DGBarChart
public typealias DGBarChartDataSet = DGCharts.DGBarChartDataSet

public typealias DGAreaChart = DGCharts.DGAreaChart
public typealias DGAreaChartDataSet = DGCharts.DGAreaChartDataSet

public typealias DGPointChart = DGCharts.DGPointChart
public typealias DGPointChartDataSet = DGCharts.DGPointChartDataSet

public typealias DGCombinedChart = DGCharts.DGCombinedChart
public typealias DGCombinedChartDataSet = DGCharts.DGCombinedChartDataSet
public typealias DGCombinedChartType = DGCharts.DGCombinedChartType
public typealias DGYAxisSide = DGCharts.DGYAxisSide

// Axis
public typealias DGChartAxisMarkPosition = DGCharts.DGChartAxisMarkPosition
public typealias DGChartAxisScale = DGCharts.DGChartAxisScale
public typealias DGChartAxisValueFormatter = DGCharts.DGChartAxisValueFormatter
public typealias DGChartClosureAxisValueFormatter = DGCharts.DGChartClosureAxisValueFormatter
public typealias DGChartDateAxisValueFormatter = DGCharts.DGChartDateAxisValueFormatter
public typealias DGChartIndexAxisValueFormatter = DGCharts.DGChartIndexAxisValueFormatter
public typealias DGChartMeasurementAxisValueFormatter = DGCharts.DGChartMeasurementAxisValueFormatter

// Legend
public typealias DGChartLegendEntry = DGCharts.DGChartLegendEntry
public typealias DGChartCustomLegendRenderer = DGCharts.DGChartCustomLegendRenderer
public typealias DGChartDefaultLegendRenderer = DGCharts.DGChartDefaultLegendRenderer

// Selection
public typealias DGChartHighlighter = DGChartsProtocols.DGChartHighlighter
public typealias DGChartDefaultHighlighter = DGCharts.DGChartDefaultHighlighter
public typealias DGChartNearestXHighlighter = DGCharts.DGChartNearestXHighlighter
public typealias DGChartNearestYHighlighter = DGCharts.DGChartNearestYHighlighter
public typealias DGChartSelectionInfo = DGCharts.DGChartSelectionInfo
public typealias DGChartSelectionState = DGCharts.DGChartSelectionState

// Scroll
public typealias DGChartViewportJob = DGCharts.DGChartViewportJob
public typealias DGChartViewportJobType = DGCharts.DGChartViewportJobType
public typealias DGChartViewportController = DGCharts.DGChartViewportController

// Color
public typealias DGChartForegroundStyle = DGCharts.DGChartForegroundStyle
public typealias DGChartLinearGradient = DGCharts.DGChartLinearGradient
public typealias DGChartRadialGradient = DGCharts.DGChartRadialGradient
public typealias DGChartColorPalette = DGCharts.DGChartColorPalette

// MARK: - Convenience Functions

/// Create a line chart with simple data
public func DGLineChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue
) -> DGCharts.DGLineChart<Point> {
    DGCharts.DGLineChart(data, label: label, color: color)
}

/// Create a bar chart with simple data
public func DGBarChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue
) -> DGCharts.DGBarChart<Point> {
    DGCharts.DGBarChart(data, label: label, color: color)
}

/// Create an area chart with simple data
public func DGAreaChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue,
    fillColor: UIColor? = nil,
    fillAlpha: CGFloat = 0.3
) -> DGCharts.DGAreaChart<Point> {
    DGCharts.DGAreaChart(data, label: label, color: color, fillColor: fillColor, fillAlpha: fillAlpha)
}

/// Create a point/scatter chart with simple data
public func DGPointChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue,
    symbol: DGChartSymbol = .circle,
    symbolSize: CGFloat = 10
) -> DGCharts.DGPointChart<Point> {
    DGCharts.DGPointChart(data, label: label, color: color, symbol: symbol, symbolSize: symbolSize)
}

/// Create a combined chart with multiple data sets
public func DGCombinedChart<Point: DGChartDataPoint>(
    _ dataSets: [DGCharts.DGCombinedChartDataSet<Point>]
) -> DGCharts.DGCombinedChart<Point> {
    DGCharts.DGCombinedChart(dataSets: dataSets)
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
    public static var sampleLineData: [DGChartPoint<Double, Double>] {
        (0..<20).map { i in
            DGChartPoint(x: Double(i), y: sin(Double(i) * 0.5) * 10 + Double.random(in: -1...1))
        }
    }

    public static var sampleDateData: [DGChartDatePoint<Double>] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<30).map { i in
            DGChartDatePoint(
                x: calendar.date(byAdding: .day, value: -i, to: now)!,
                y: Double.random(in: 10...100)
            )
        }.reversed()
    }

    public static var sampleCategoryData: [DGChartCategoryPoint<Double>] {
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun"].map {
            DGChartCategoryPoint(x: $0, y: Double.random(in: 10...100))
        }
    }

    public static var sampleMultiSeriesData: [[DGChartPoint<Double, Double>]] {
        (0..<3).map { series in
            (0..<20).map { i in
                DGChartPoint(
                    x: Double(i),
                    y: sin(Double(i) * 0.5 + Double(series)) * 10 + Double(series) * 5
                )
            }
        }
    }
}
#endif