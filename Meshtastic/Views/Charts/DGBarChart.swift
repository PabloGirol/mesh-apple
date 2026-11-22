//
//  DGBarChart.swift
//  Meshtastic
//
//  SwiftUI wrapper for DGCharts BarChartView replicating Swift Charts BarMark API
//

import SwiftUI
import DGCharts

// Disambiguate ChartGesture from DGCharts framework
typealias ChartGesture = DGChartsProtocols.ChartGesture

// MARK: - Bar Chart Data Set

/// Data set for bar charts
public struct DGBarChartDataSet<Point: DGChartDataPoint> {
    public let id: String
    public let label: String
    public var data: [Point]
    public var color: UIColor
    public var gradient: CGGradient?
    public var lineStyle: DGLineStyle?
    public var markStyle: DGMarkStyle?
    public var symbol: DGChartSymbol
    public var isVisible: Bool
    public var order: Int
    public var barWidth: Double
    public var cornerRadius: CGFloat
    public var isStacked: Bool
    public var stackLabel: String?

    public init(
        id: String = UUID().uuidString,
        label: String,
        data: [Point],
        color: UIColor = .systemBlue,
        gradient: CGGradient? = nil,
        lineStyle: DGLineStyle? = nil,
        markStyle: DGMarkStyle? = nil,
        symbol: DGChartSymbol = .none,
        isVisible: Bool = true,
        order: Int = 0,
        barWidth: Double = 0.8,
        cornerRadius: CGFloat = 0,
        isStacked: Bool = false,
        stackLabel: String? = nil
    ) {
        self.id = id
        self.label = label
        self.data = data
        self.color = color
        self.gradient = gradient
        self.lineStyle = lineStyle
        self.markStyle = markStyle
        self.symbol = symbol
        self.isVisible = isVisible
        self.order = order
        self.barWidth = barWidth
        self.cornerRadius = cornerRadius
        self.isStacked = isStacked
        self.stackLabel = stackLabel
    }
}

// MARK: - Bar Chart View

/// SwiftUI wrapper for DGCharts BarChartView
public struct DGBarChart<Point: DGChartDataPoint>: UIViewRepresentable {
    public typealias DataSet = DGBarChartDataSet<Point>

    // Data
    public var dataSets: [DataSet]

    // Configuration
    public var xAxisConfig: DGChartAxisConfig
    public var yAxisConfig: DGChartAxisConfig
    public var legendConfig: DGChartLegendConfig
    public var selectionConfig: DGChartSelectionConfig
    public var scrollConfig: DGChartScrollConfig
    public var animationConfig: DGChartAnimationConfig
    public var colorScheme: DGChartColorScheme
    public var backgroundColor: UIColor
    public var borderColor: UIColor
    public var borderWidth: CGFloat

    // Layout
    public var isHorizontal: Bool
    public var groupSpacing: Double
    public var barSpacing: Double

    // Callbacks
    public var onSelectionChange: (([Point]?, Highlight?) -> Void)?
    public var onChartGesture: ((ChartGesture) -> Void)?

    public init(
        dataSets: [DataSet],
        xAxisConfig: DGChartAxisConfig = DGDefaultAxisConfig(),
        yAxisConfig: DGChartAxisConfig = DGDefaultAxisConfig(),
        legendConfig: DGChartLegendConfig = DGDefaultLegendConfig(),
        selectionConfig: DGChartSelectionConfig = DGDefaultSelectionConfig(),
        scrollConfig: DGChartScrollConfig = DGDefaultScrollConfig(),
        animationConfig: DGChartAnimationConfig = DGDefaultAnimationConfig(),
        colorScheme: DGChartColorScheme = DGDefaultColorScheme(),
        backgroundColor: UIColor = .clear,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0,
        isHorizontal: Bool = false,
        groupSpacing: Double = 0.3,
        barSpacing: Double = 0.05,
        onSelectionChange: (([Point]?, Highlight?) -> Void)? = nil,
        onChartGesture: ((ChartGesture) -> Void)? = nil
    ) {
        self.dataSets = dataSets
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
        self.legendConfig = legendConfig
        self.selectionConfig = selectionConfig
        self.scrollConfig = scrollConfig
        self.animationConfig = animationConfig
        self.colorScheme = colorScheme
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.isHorizontal = isHorizontal
        self.groupSpacing = groupSpacing
        self.barSpacing = barSpacing
        self.onSelectionChange = onSelectionChange
        self.onChartGesture = onChartGesture
    }

    public func makeUIView(context: Context) -> BarChartView {
        let chartView = BarChartView()
        chartView.delegate = context.coordinator
        configureChart(chartView)
        return chartView
    }

    public func updateUIView(_ chartView: BarChartView, context: Context) {
        updateChartData(chartView)
        updateChartConfiguration(chartView)

        if animationConfig.enabled {
            chartView.animate(
                xAxisDuration: animationConfig.duration,
                yAxisDuration: animationConfig.duration,
                easingOption: animationConfig.easing.toDGChartEasing()
            )
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Configuration

    private func configureChart(_ chartView: BarChartView) {
        chartView.backgroundColor = backgroundColor
        chartView.layer.borderColor = borderColor.cgColor
        chartView.layer.borderWidth = borderWidth

        // Grid
        chartView.xAxis.drawGridLinesEnabled = false // Usually no grid on X for bars
        chartView.xAxis.gridColor = xAxisConfig.gridColor
        chartView.xAxis.gridLineWidth = xAxisConfig.gridWidth

        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.gridColor = yAxisConfig.gridColor
        chartView.leftAxis.gridLineWidth = yAxisConfig.gridWidth
        chartView.leftAxis.gridLineDashLengths = yAxisConfig.gridDashPattern

        chartView.rightAxis.drawGridLinesEnabled = false

        // Axes
        configureAxis(chartView.xAxis, config: xAxisConfig, isXAxis: true)
        configureAxis(chartView.leftAxis, config: yAxisConfig, isXAxis: false)
        configureAxis(chartView.rightAxis, config: yAxisConfig, isXAxis: false)
        chartView.rightAxis.enabled = false

        // Legend
        configureLegend(chartView.legend, config: legendConfig)

        // Interaction
        chartView.scaleXEnabled = scrollConfig.scaleXEnabled
        chartView.scaleYEnabled = scrollConfig.scaleYEnabled
        chartView.dragEnabled = scrollConfig.dragEnabled
        chartView.dragXEnabled = scrollConfig.dragXEnabled
        chartView.dragYEnabled = scrollConfig.dragYEnabled
        chartView.pinchZoomEnabled = scrollConfig.pinchZoomEnabled
        chartView.doubleTapToZoomEnabled = scrollConfig.doubleTapToZoomEnabled
        chartView.highlightPerDragEnabled = scrollConfig.highlightPerDragEnabled

        chartView.setScaleMinima(scrollConfig.minScaleX, minScaleY: scrollConfig.minScaleY)
        chartView.setScaleMaxima(scrollConfig.maxScaleX, maxScaleY: scrollConfig.maxScaleY)

        if let xRange = scrollConfig.visibleXRange {
            chartView.setVisibleXRange(minXRange: xRange.lowerBound, maxXRange: xRange.upperBound)
        }
        if let yRange = scrollConfig.visibleYRange {
            chartView.setVisibleYRange(minYRange: yRange.lowerBound, maxYRange: yRange.upperBound, axis: .left)
        }

        // Selection
        chartView.highlightColor = selectionConfig.highlightColor
        chartView.highlightLineWidth = selectionConfig.highlightLineWidth
        chartView.drawHorizontalHighlightIndicatorEnabled = selectionConfig.drawHorizontalHighlightIndicator
        chartView.drawVerticalHighlightIndicatorEnabled = selectionConfig.drawVerticalHighlightIndicator
        if let highlighter = selectionConfig.highlighter {
            chartView.highlighter = highlighter
        }

        // Bar specific
        chartView.maxVisibleCount = 1000
        chartView.drawValueAboveBarEnabled = true
        chartView.drawBarShadowEnabled = false
        chartView.fitBars = true

        chartView.extraTopOffset = 10
        chartView.extraBottomOffset = 10
        chartView.extraLeftOffset = 10
        chartView.extraRightOffset = 10
    }

    private func configureAxis(_ axis: AxisBase, config: DGChartAxisConfig, isXAxis: Bool) {
        axis.enabled = true
        axis.labelTextColor = config.labelColor
        axis.labelFont = config.labelFont
        axis.drawLabelsEnabled = true
        axis.drawAxisLineEnabled = true
        axis.axisLineColor = config.gridColor
        axis.axisLineWidth = config.gridWidth

        axis.drawGridLinesEnabled = isXAxis ? false : true
        axis.gridColor = config.gridColor
        axis.gridLineWidth = config.gridWidth
        axis.gridLineDashLengths = config.gridDashPattern

        axis.labelCount = config.labelCount
        axis.forceLabelsEnabled = config.forceLabelsEnabled

        if let minVal = config.minValue {
            axis.axisMinimum = minVal
        }
        if let maxVal = config.maxValue {
            axis.axisMaximum = maxVal
        }

        if let granularity = config.granularity {
            axis.granularity = granularity
        }

        if let formatter = config.valueFormatter {
            axis.valueFormatter = DefaultAxisValueFormatter(block: formatter)
        } else if config.scale == .date, let dateFormat = config.dateFormat {
            axis.valueFormatter = DateAxisValueFormatter(dateFormat: dateFormat)
        } else if config.scale == .category {
            axis.valueFormatter = IndexAxisValueFormatter(values: [])
        }

        if !isXAxis {
            axis.axisMinimum = config.minValue ?? 0
        }
    }

    private func configureLegend(_ legend: Legend, config: DGChartLegendConfig) {
        legend.enabled = config.enabled
        legend.horizontalAlignment = Legend.HorizontalAlignment(rawValue: config.horizontalAlignment.rawValue) ?? .center
        legend.verticalAlignment = Legend.VerticalAlignment(rawValue: config.verticalAlignment.rawValue) ?? .bottom
        legend.orientation = Legend.Orientation(rawValue: config.orientation.rawValue) ?? .horizontal
        legend.drawInside = config.drawInside
        legend.direction = Legend.Direction(rawValue: config.direction.rawValue) ?? .leftToRight
        legend.textColor = config.textColor
        legend.font = config.font
        legend.form = Legend.Form(rawValue: config.form.rawValue) ?? .default
        legend.formSize = config.formSize
        legend.formToTextSpace = config.formToTextSpace
        legend.xEntrySpace = config.xEntrySpace
        legend.yEntrySpace = config.yEntrySpace
        legend.xOffset = config.xOffset
        legend.yOffset = config.yOffset

        if let bgColor = config.backgroundColor {
            legend.backgroundColor = bgColor
        }
        if let borderColor = config.borderColor {
            legend.borderColor = borderColor
            legend.borderLineWidth = config.borderWidth
        }

        legend.wordWrapEnabled = config.wordWrapEnabled
        legend.maxSizePercent = config.maxSizePercent

        switch config.position {
        case .top: legend.verticalAlignment = .top; legend.horizontalAlignment = .center
        case .bottom: legend.verticalAlignment = .bottom; legend.horizontalAlignment = .center
        case .left: legend.verticalAlignment = .center; legend.horizontalAlignment = .left
        case .right: legend.verticalAlignment = .center; legend.horizontalAlignment = .right
        case .topLeft: legend.verticalAlignment = .top; legend.horizontalAlignment = .left
        case .topRight: legend.verticalAlignment = .top; legend.horizontalAlignment = .right
        case .bottomLeft: legend.verticalAlignment = .bottom; legend.horizontalAlignment = .left
        case .bottomRight: legend.verticalAlignment = .bottom; legend.horizontalAlignment = .right
        case .insideTopLeft: legend.verticalAlignment = .top; legend.horizontalAlignment = .left; legend.drawInside = true
        case .insideTopRight: legend.verticalAlignment = .top; legend.horizontalAlignment = .right; legend.drawInside = true
        case .insideBottomLeft: legend.verticalAlignment = .bottom; legend.horizontalAlignment = .left; legend.drawInside = true
        case .insideBottomRight: legend.verticalAlignment = .bottom; legend.horizontalAlignment = .right; legend.drawInside = true
        case .automatic: break
        }
    }

    private func updateChartData(_ chartView: BarChartView) {
        var chartDataSets: [BarChartDataSet] = []

        // Group data sets by stack label for stacking
        let groupedDataSets = Dictionary(grouping: dataSets.filter { $0.isVisible }) { $0.stackLabel ?? $0.id }

        var globalIndex = 0
        for (_, stackedSets) in groupedDataSets {
            let isStacked = stackedSets.first?.isStacked ?? false

            for (setIndex, dataSet) in stackedSets.enumerated() {
                let entries = dataSet.data.enumerated().map { index, point -> BarChartDataEntry in
                    let xValue = xValueForPoint(point, index: index)
                    let yValue = yValueForPoint(point)
                    return BarChartDataEntry(x: xValue, y: yValue, data: point)
                }

                let barDataSet = BarChartDataSet(entries: entries, label: dataSet.label)

                // Color
                barDataSet.colors = [dataSet.color]

                // Gradient
                if let gradient = dataSet.gradient {
                    barDataSet.gradientColor = gradient
                }

                // Bar width
                barDataSet.barWidth = dataSet.barWidth

                // Corner radius (via custom renderer or annotation in newer DGCharts)
                // Note: DGCharts doesn't natively support corner radius on bars
                // This would require a custom BarChartRenderer

                // Stacking
                if isStacked {
                    barDataSet.stackLabels = [dataSet.stackLabel ?? dataSet.label]
                }

                // Values
                barDataSet.drawValuesEnabled = false
                barDataSet.highlightColor = selectionConfig.highlightColor
                barDataSet.highlightAlpha = 120

                chartDataSets.append(barDataSet)
                globalIndex += 1
            }
        }

        let chartData = BarChartData(dataSets: chartDataSets)
        chartData.barWidth = 0.8 // Default, overridden per dataset

        // Set group spacing for grouped bars
        if !isStacked && chartDataSets.count > 1 {
            chartData.groupBars(fromX: 0, groupSpace: groupSpacing, barSpace: barSpacing)
        }

        chartView.data = chartData
    }

    private func updateChartConfiguration(_ chartView: BarChartView) {
        configureAxis(chartView.xAxis, config: xAxisConfig, isXAxis: true)
        configureAxis(chartView.leftAxis, config: yAxisConfig, isXAxis: false)
        configureLegend(chartView.legend, config: legendConfig)
    }

    private func xValueForPoint(_ point: Point, index: Int) -> Double {
        if let date = point.x as? Date {
            return date.timeIntervalSince1970
        } else if let double = point.x as? Double {
            return double
        } else if let int = point.x as? Int {
            return Double(int)
        } else if let float = point.x as? Float {
            return Double(float)
        } else if let string = point.x as? String {
            // For categorical, use index
            return Double(index)
        }
        return Double(index)
    }

    private func yValueForPoint(_ point: Point) -> Double {
        if let double = point.y as? Double {
            return double
        } else if let int = point.y as? Int {
            return Double(int)
        } else if let float = point.y as? Float {
            return Double(float)
        }
        return 0
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, ChartViewDelegate {
        let parent: DGBarChart

        init(_ parent: DGBarChart) {
            self.parent = parent
        }

        public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            if let point = entry.data as? Point {
                parent.onSelectionChange?([point], highlight)
            }
        }

        public func chartValueNothingSelected(_ chartView: ChartViewBase) {
            parent.onSelectionChange?(nil, nil)
        }

        public func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
            parent.onChartGesture?(ChartGesture.scale(scaleX: scaleX, scaleY: scaleY))
        }

        public func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
            parent.onChartGesture?(ChartGesture.pan(dX: dX, dY: dY))
        }
    }
}

// MARK: - SwiftUI Modifiers

public extension DGBarChart {
    func xAxisConfig(_ config: DGChartAxisConfig) -> DGBarChart {
        var copy = self
        copy.xAxisConfig = config
        return copy
    }

    func yAxisConfig(_ config: DGChartAxisConfig) -> DGBarChart {
        var copy = self
        copy.yAxisConfig = config
        return copy
    }

    func legendConfig(_ config: DGChartLegendConfig) -> DGBarChart {
        var copy = self
        copy.legendConfig = config
        return copy
    }

    func selectionConfig(_ config: DGChartSelectionConfig) -> DGBarChart {
        var copy = self
        copy.selectionConfig = config
        return copy
    }

    func scrollConfig(_ config: DGChartScrollConfig) -> DGBarChart {
        var copy = self
        copy.scrollConfig = config
        return copy
    }

    func animationConfig(_ config: DGChartAnimationConfig) -> DGBarChart {
        var copy = self
        copy.animationConfig = config
        return copy
    }

    func colorScheme(_ scheme: DGChartColorScheme) -> DGBarChart {
        var copy = self
        copy.colorScheme = scheme
        return copy
    }

    func chartBackground(_ color: UIColor) -> DGBarChart {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    func chartBorder(_ color: UIColor, width: CGFloat = 1) -> DGBarChart {
        var copy = self
        copy.borderColor = color
        copy.borderWidth = width
        return copy
    }

    func horizontal(_ enabled: Bool = true) -> DGBarChart {
        var copy = self
        copy.isHorizontal = enabled
        return copy
    }

    func groupSpacing(_ spacing: Double) -> DGBarChart {
        var copy = self
        copy.groupSpacing = spacing
        return copy
    }

    func barSpacing(_ spacing: Double) -> DGBarChart {
        var copy = self
        copy.barSpacing = spacing
        return copy
    }

    func onSelectionChange(_ callback: @escaping ([Point]?, Highlight?) -> Void) -> DGBarChart {
        var copy = self
        copy.onSelectionChange = callback
        return copy
    }

    func onChartGesture(_ callback: @escaping (ChartGesture) -> Void) -> DGBarChart {
        var copy = self
        copy.onChartGesture = callback
        return copy
    }
}

// MARK: - Convenience Initializers

public extension DGBarChart where Point == DGChartPoint<Double, Double> {
    init(
        _ data: [DGChartPoint<Double, Double>],
        label: String = "Series",
        color: UIColor = .systemBlue
    ) {
        let dataSet = DGBarChartDataSet(label: label, data: data, color: color)
        self.init(dataSets: [dataSet])
    }
}

public extension DGBarChart where Point == DGChartDatePoint<Double> {
    init(
        _ data: [DGChartDatePoint<Double>],
        label: String = "Series",
        color: UIColor = .systemBlue
    ) {
        let dataSet = DGBarChartDataSet(label: label, data: data, color: color)
        self.init(dataSets: [dataSet])
    }
}

public extension DGBarChart where Point == DGChartCategoryPoint<Double> {
    init(
        _ data: [DGChartCategoryPoint<Double>],
        label: String = "Series",
        color: UIColor = .systemBlue
    ) {
        let dataSet = DGBarChartDataSet(label: label, data: data, color: color)
        self.init(dataSets: [dataSet])
    }
}

