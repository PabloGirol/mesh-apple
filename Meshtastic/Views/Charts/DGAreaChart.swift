//
//  DGAreaChart.swift
//  Meshtastic
//
//  SwiftUI wrapper for DGCharts LineChartView with fill replicating Swift Charts AreaMark API
//

import SwiftUI
import DGCharts

// MARK: - Area Chart Data Set

/// Data set for area charts (line with fill) - uses concrete types to avoid protocol associatedtype issues
public struct DGAreaChartDataSet<Point: DGChartDataPoint> {
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
    public var fillColor: UIColor
    public var fillGradient: CGGradient?
    public var fillAlpha: CGFloat
    public var interpolationMethod: DGChartInterpolationMethod
    public var drawLine: Bool
    public var lineColor: UIColor?

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
        fillColor: UIColor? = nil,
        fillGradient: CGGradient? = nil,
        fillAlpha: CGFloat = 0.3,
        interpolationMethod: DGChartInterpolationMethod = .linear,
        drawLine: Bool = true,
        lineColor: UIColor? = nil
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
        self.fillColor = fillColor ?? color
        self.fillGradient = fillGradient
        self.fillAlpha = fillAlpha
        self.interpolationMethod = interpolationMethod
        self.drawLine = drawLine
        self.lineColor = lineColor
    }
}

// MARK: - Area Chart View

/// SwiftUI wrapper for DGCharts LineChartView with area fill
public struct DGAreaChart<Point: DGChartDataPoint>: UIViewRepresentable {
    public typealias DataSet = DGAreaChartDataSet<Point>

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

    // Stacking
    public var isStacked: Bool

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
        isStacked: Bool = false,
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
        self.isStacked = isStacked
        self.onSelectionChange = onSelectionChange
        self.onChartGesture = onChartGesture
    }

    public func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        chartView.delegate = context.coordinator
        configureChart(chartView)
        return chartView
    }

    public func updateUIView(_ chartView: LineChartView, context: Context) {
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

    private func configureChart(_ chartView: LineChartView) {
        chartView.backgroundColor = backgroundColor
        chartView.layer.borderColor = borderColor.cgColor
        chartView.layer.borderWidth = borderWidth

        // Grid
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.gridColor = xAxisConfig.gridColor
        chartView.xAxis.gridLineWidth = xAxisConfig.gridWidth
        chartView.xAxis.gridLineDashLengths = xAxisConfig.gridDashPattern

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

        axis.drawGridLinesEnabled = true
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

    private func updateChartData(_ chartView: LineChartView) {
        var chartDataSets: [LineChartDataSet] = []

        // Sort by order for proper stacking (bottom to top)
        let sortedDataSets = dataSets.filter { $0.isVisible }.sorted { $0.order < $1.order }

        var baseValues: [Double] = [] // For stacking

        for (dataSetIndex, dataSet) in sortedDataSets.enumerated() {
            let entries = dataSet.data.enumerated().map { index, point -> ChartDataEntry in
                let xValue = xValueForPoint(point, index: index)
                var yValue = yValueForPoint(point)

                // Handle stacking
                if isStacked && dataSetIndex > 0 && index < baseValues.count {
                    yValue += baseValues[index]
                    baseValues[index] = yValue
                } else if isStacked && dataSetIndex == 0 {
                    if index >= baseValues.count {
                        baseValues.append(yValue)
                    } else {
                        baseValues[index] = yValue
                    }
                }

                return ChartDataEntry(x: xValue, y: yValue, data: point)
            }

            let lineDataSet = LineChartDataSet(entries: entries, label: dataSet.label)

            // Line color (if drawing line)
            let lineColor = dataSet.lineColor ?? dataSet.color
            lineDataSet.colors = dataSet.drawLine ? [lineColor] : [UIColor.clear]
            lineDataSet.circleColors = [dataSet.color]

            // Fill configuration
            lineDataSet.fillAlpha = dataSet.fillAlpha
            if let fillGradient = dataSet.fillGradient {
                lineDataSet.fill = Fill.fillWithLinearGradient(fillGradient, angle: 90)
            } else {
                lineDataSet.fill = Fill(color: dataSet.fillColor.withAlphaComponent(dataSet.fillAlpha))
            }
            lineDataSet.drawFilledEnabled = true
            lineDataSet.fillFormatter = DefaultFillFormatter { _, _ in 0 }

            // Line style
            if let lineStyle = dataSet.lineStyle {
                lineDataSet.lineWidth = dataSet.drawLine ? lineStyle.lineWidth : 0
                lineDataSet.lineDashLengths = lineStyle.dashPattern
                lineDataSet.mode = dataSet.interpolationMethod.toDGChartMode()
            } else {
                lineDataSet.lineWidth = dataSet.drawLine ? 2 : 0
                lineDataSet.mode = dataSet.interpolationMethod.toDGChartMode()
            }

            // Symbol/Mark
            lineDataSet.drawCirclesEnabled = dataSet.symbol != .none && dataSet.symbol != .custom
            lineDataSet.circleRadius = 4
            lineDataSet.circleHoleRadius = 2
            lineDataSet.drawCircleHoleEnabled = true

            switch dataSet.symbol {
            case .circle: lineDataSet.shape = .circle
            case .square: lineDataSet.shape = .square
            case .triangle: lineDataSet.shape = .triangle
            case .diamond: lineDataSet.shape = .diamond
            case .cross: lineDataSet.shape = .cross
            case .plus: lineDataSet.shape = .plus
            case .custom: lineDataSet.drawCirclesEnabled = false
            case .none: lineDataSet.drawCirclesEnabled = false
            }

            if let markStyle = dataSet.markStyle {
                lineDataSet.circleRadius = markStyle.size.width / 2
                if let fillColor = markStyle.fillColor {
                    lineDataSet.circleColors = [fillColor]
                }
                if let strokeColor = markStyle.strokeColor {
                    lineDataSet.circleHoleColor = strokeColor
                }
            }

            // Values
            lineDataSet.drawValuesEnabled = false
            lineDataSet.highlightColor = selectionConfig.highlightColor
            lineDataSet.highlightLineWidth = selectionConfig.highlightLineWidth
            lineDataSet.highlightLineDashLengths = selectionConfig.highlightLineDashPattern

            chartDataSets.append(lineDataSet)
        }

        let chartData = LineChartData(dataSets: chartDataSets)
        chartView.data = chartData
    }

    private func updateChartConfiguration(_ chartView: LineChartView) {
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
        let parent: DGAreaChart

        init(_ parent: DGAreaChart) {
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
            parent.onChartGesture?(.scale(scaleX: scaleX, scaleY: scaleY))
        }

        public func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
            parent.onChartGesture?(.pan(dX: dX, dY: dY))
        }
    }
}

// MARK: - SwiftUI Modifiers

public extension DGAreaChart {
    func xAxisConfig(_ config: DGChartAxisConfig) -> DGAreaChart {
        var copy = self
        copy.xAxisConfig = config
        return copy
    }

    func yAxisConfig(_ config: DGChartAxisConfig) -> DGAreaChart {
        var copy = self
        copy.yAxisConfig = config
        return copy
    }

    func legendConfig(_ config: DGChartLegendConfig) -> DGAreaChart {
        var copy = self
        copy.legendConfig = config
        return copy
    }

    func selectionConfig(_ config: DGChartSelectionConfig) -> DGAreaChart {
        var copy = self
        copy.selectionConfig = config
        return copy
    }

    func scrollConfig(_ config: DGChartScrollConfig) -> DGAreaChart {
        var copy = self
        copy.scrollConfig = config
        return copy
    }

    func animationConfig(_ config: DGChartAnimationConfig) -> DGAreaChart {
        var copy = self
        copy.animationConfig = config
        return copy
    }

    func colorScheme(_ scheme: DGChartColorScheme) -> DGAreaChart {
        var copy = self
        copy.colorScheme = scheme
        return copy
    }

    func chartBackground(_ color: UIColor) -> DGAreaChart {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    func chartBorder(_ color: UIColor, width: CGFloat = 1) -> DGAreaChart {
        var copy = self
        copy.borderColor = color
        copy.borderWidth = width
        return copy
    }

    func stacked(_ enabled: Bool = true) -> DGAreaChart {
        var copy = self
        copy.isStacked = enabled
        return copy
    }

    func onSelectionChange(_ callback: @escaping ([Point]?, Highlight?) -> Void) -> DGAreaChart {
        var copy = self
        copy.onSelectionChange = callback
        return copy
    }

    func onChartGesture(_ callback: @escaping (ChartGesture) -> Void) -> DGAreaChart {
        var copy = self
        copy.onChartGesture = callback
        return copy
    }
}

// MARK: - Convenience Initializers

public extension DGAreaChart where Point == DGChartPoint<Double, Double> {
    init(
        _ data: [DGChartPoint<Double, Double>],
        label: String = "Series",
        color: UIColor = .systemBlue,
        fillColor: UIColor? = nil,
        fillAlpha: CGFloat = 0.3
    ) {
        let dataSet = DGAreaChartDataSet(
            label: label,
            data: data,
            color: color,
            fillColor: fillColor,
            fillAlpha: fillAlpha
        )
        self.init(dataSets: [dataSet])
    }
}

public extension DGAreaChart where Point == DGChartDatePoint<Double> {
    init(
        _ data: [DGChartDatePoint<Double>],
        label: String = "Series",
        color: UIColor = .systemBlue,
        fillColor: UIColor? = nil,
        fillAlpha: CGFloat = 0.3
    ) {
        let dataSet = DGAreaChartDataSet(
            label: label,
            data: data,
            color: color,
            fillColor: fillColor,
            fillAlpha: fillAlpha
        )
        self.init(dataSets: [dataSet])
    }
}

public extension DGAreaChart where Point == DGChartCategoryPoint<Double> {
    init(
        _ data: [DGChartCategoryPoint<Double>],
        label: String = "Series",
        color: UIColor = .systemBlue,
        fillColor: UIColor? = nil,
        fillAlpha: CGFloat = 0.3
    ) {
        let dataSet = DGAreaChartDataSet(
            label: label,
            data: data,
            color: color,
            fillColor: fillColor,
            fillAlpha: fillAlpha
        )
        self.init(dataSets: [dataSet])
    }
}

// MARK: - Axis Value Formatters (private)

private class DefaultAxisValueFormatter: NSObject, AxisValueFormatter {
    let block: (Double) -> String
    init(block: @escaping (Double) -> String) { self.block = block }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String { block(value) }
}

private class DateAxisValueFormatter: NSObject, AxisValueFormatter {
    let dateFormatter: DateFormatter
    init(dateFormat: String) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

private class IndexAxisValueFormatter: NSObject, AxisValueFormatter {
    let values: [String]
    init(values: [String]) { self.values = values }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0 && index < values.count else { return "" }
        return values[index]
    }
}

private class DefaultFillFormatter: NSObject, FillFormatter {
    let block: (ChartDataSetBase, ChartDataProvider) -> CGFloat
    init(block: @escaping (ChartDataSetBase, ChartDataProvider) -> CGFloat) {
        self.block = block
    }
    func getFillLinePosition(dataSet: ChartDataSetBase, dataProvider: ChartDataProvider) -> CGFloat {
        block(dataSet, dataProvider)
    }
}


