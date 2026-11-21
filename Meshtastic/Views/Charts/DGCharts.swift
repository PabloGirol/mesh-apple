//
//  DGCharts.swift
//  Meshtastic
//
//  Unified export for DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Public API Exports

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

// Axis (from DGChartAxis)
public typealias DGChartAxisScaleType = DGChartAxisScale
public typealias DGChartAxisValueFormatter = DGChartAxisValueFormatter
public typealias DGChartClosureAxisValueFormatter = DGChartClosureAxisValueFormatter
public typealias DGChartDateAxisValueFormatter = DGChartDateAxisValueFormatter
public typealias DGChartIndexAxisValueFormatter = DGChartIndexAxisValueFormatter
public typealias DGChartMeasurementAxisValueFormatter = DGChartMeasurementAxisValueFormatter

// Legend (from DGChartLegend)
public typealias DGChartLegendEntry = DGChartLegendEntry
public typealias DGChartCustomLegendRenderer = DGChartCustomLegendRenderer
public typealias DGChartDefaultLegendRenderer = DGChartDefaultLegendRenderer

// Selection (from DGChartSelection)
public typealias DGChartSelectionInfo = DGChartSelectionInfo
public typealias DGChartSelectionState = DGChartSelectionState

// Scroll (from DGChartScroll)
public typealias DGChartViewportJob = DGChartViewportJob
public typealias DGChartViewportJobType = DGChartViewportJobType
public typealias DGChartViewportController = DGChartViewportController

// Color (from DGChartColor)
public typealias DGChartForegroundStyle = DGChartForegroundStyle
public typealias DGChartLinearGradient = DGChartLinearGradient
public typealias DGChartRadialGradient = DGChartRadialGradient
public typealias DGChartColorPalette = DGChartColorPalette

// Protocols & Base Types (from DGChartsProtocols) are already accessible in this module.
// No typealiases needed: DGChartDataPoint, DGChartPoint, DGChartDatePoint, DGChartCategoryPoint,
// DGLineStyle, DGMarkStyle, DGChartSymbol, DGChartInterpolationMethod, DGChartAxisConfig,
// DGDefaultAxisConfig, DGChartAxisPosition, DGChartAxisScale, DGChartLegendConfig,
// DGDefaultLegendConfig, DGChartLegendPosition, DGChartSelectionConfig, DGDefaultSelectionConfig,
// DGChartSelectionMode, DGChartScrollConfig, DGDefaultScrollConfig, DGChartAnimationConfig,
// DGDefaultAnimationConfig, DGChartEasingFunction, DGChartColorScheme, DGDefaultColorScheme,
// DGCategoricalColorScheme, DGSequentialColorScheme, DGDivergingColorScheme, DGSemanticColorScheme,
// DGChartDataSet, DGChartView, ChartGesture, DGChartFillFormatter, DGDefaultFillFormatter,
// DGChartHighlighter, DGChartViewBase

// MARK: - Convenience Functions

/// Create a line chart with simple data
public func DGLineChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue
) -> DGLineChart<Point> {
    DGLineChart(data, label: label, color: color)
}

/// Create a bar chart with simple data
public func DGBarChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue
) -> DGBarChart<Point> {
    DGBarChart(data, label: label, color: color)
}

/// Create an area chart with simple data
public func DGAreaChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue,
    fillColor: UIColor? = nil,
    fillAlpha: CGFloat = 0.3
) -> DGAreaChart<Point> {
    DGAreaChart(data, label: label, color: color, fillColor: fillColor, fillAlpha: fillAlpha)
}

/// Create a point/scatter chart with simple data
public func DGPointChart<Point: DGChartDataPoint>(
    _ data: [Point],
    label: String = "Series",
    color: UIColor = .systemBlue,
    symbol: DGChartSymbol = .circle,
    symbolSize: CGFloat = 10
) -> DGPointChart<Point> {
    DGPointChart(data, label: label, color: color, symbol: symbol, symbolSize: symbolSize)
}

/// Create a combined chart with multiple data sets
public func DGCombinedChart<Point: DGChartDataPoint>(
    _ dataSets: [DGCombinedChartDataSet<Point>]
) -> DGCombinedChart<Point> {
    DGCombinedChart(dataSets: dataSets)
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