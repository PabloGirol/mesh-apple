//
//  DGPointChart.swift
//  Meshtastic
//
//  SwiftUI wrapper for DGCharts ScatterChartView replicating Swift Charts PointMark API
//

import SwiftUI
import DGCharts

// MARK: - Point Chart Data Set

/// Data set for point/scatter charts
public struct DGPointChartDataSet<Point: DGChartDataPoint> {
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
    public var symbolSize: CGFloat
    public var symbolStrokeWidth: CGFloat
    public var symbolStrokeColor: UIColor?

    public init(
        id: String = UUID().uuidString,
        label: String,
        data: [Point],
        color: UIColor = .systemBlue,
        gradient: CGGradient? = nil,
        lineStyle: DGLineStyle? = nil,
        markStyle: DGMarkStyle? = nil,
        symbol: DGChartSymbol = .circle,
        isVisible: Bool = true,
        order: Int = 0,
        symbolSize: CGFloat = 10,
        symbolStrokeWidth: CGFloat = 1.5,
        symbolStrokeColor: UIColor? = nil
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
        self.symbolSize = symbolSize
        self.symbolStrokeWidth = symbolStrokeWidth
        self.symbolStrokeColor = symbolStrokeColor
    }
}

// MARK: - Point Chart View

/// SwiftUI wrapper for DGCharts ScatterChartView
public struct DGPointChart<Point: DGChartDataPoint>: UIViewRepresentable {
    public typealias DataSet = DGPointChartDataSet<Point>

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
        self.onSelectionChange = onSelectionChange
        self.onChartGesture = onChartGesture
    }

    public func makeUIView(context: Context) -> ScatterChartView {
        let chartView = ScatterChartView()
        chartView.delegate = context.coordinator
        configureChart(chartView)
        return chartView
    }

    public func updateUIView(_ chartView: ScatterChartView, context: Context) {
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

    private func configureChart(_ chartView: ScatterChartView) {
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

        // Scatter specific
        chartView.maxVisibleCount = 1000

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

    private func updateChartData(_ chartView: ScatterChartView) {
        var chartDataSets: [ScatterChartDataSet] = []

        for dataSet in dataSets.filter({ $0.isVisible }) {
            let entries = dataSet.data.enumerated().map { index, point -> ChartDataEntry in
                let xValue = xValueForPoint(point, index: index)
                let yValue = yValueForPoint(point)
                return ChartDataEntry(x: xValue, y: yValue, data: point)
            }

            let scatterDataSet = ScatterChartDataSet(entries: entries, label: dataSet.label)

            // Color
            scatterDataSet.colors = [dataSet.color]

            // Symbol/Shape
            scatterDataSet.scatterShape = shapeForSymbol(dataSet.symbol)
            scatterDataSet.scatterShapeSize = dataSet.symbolSize
            scatterDataSet.scatterShapeHoleRadius = max(0, dataSet.symbolSize * 0.4)
            scatterDataSet.scatterShapeHoleColor = dataSet.symbolStrokeColor ?? .white

            // Custom shape renderer for custom symbols
            if case .custom(let renderer) = dataSet.symbol {
                scatterDataSet.customScatterShapeRenderer = CustomScatterShapeRenderer(renderer: renderer)
            }

            // Stroke
            if let strokeColor = dataSet.symbolStrokeColor {
                scatterDataSet.scatterShapeHoleColor = strokeColor
            }

            // Values
            scatterDataSet.drawValuesEnabled = false
            scatterDataSet.highlightColor = selectionConfig.highlightColor
            scatterDataSet.highlightLineWidth = selectionConfig.highlightLineWidth

            chartDataSets.append(scatterDataSet)
        }

        let chartData = ScatterChartData(dataSets: chartDataSets)
        chartView.data = chartData
    }

    private func updateChartConfiguration(_ chartView: ScatterChartView) {
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

    private func shapeForSymbol(_ symbol: DGChartSymbol) -> ScatterChartDataSet.Shape {
        switch symbol {
        case .circle: return .circle
        case .square: return .square
        case .triangle: return .triangle
        case .diamond: return .diamond
        case .cross: return .cross
        case .plus: return .plus
        case .custom: return .circle // Will use custom renderer
        case .none: return .circle
        }
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, ChartViewDelegate {
        let parent: DGPointChart

        init(_ parent: DGPointChart) {
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

// MARK: - Custom Scatter Shape Renderer

private class CustomScatterShapeRenderer: NSObject, ShapeRenderer {
    let renderer: (CGContext, CGRect, CGSize) -> Void

    init(renderer: @escaping (CGContext, CGRect, CGSize) -> Void) {
        self.renderer = renderer
    }

    func renderShape(context: CGContext, dataSet: ScatterChartDataSet, viewPortHandler: ViewPortHandler, point: CGPoint, color: NSUIColor) {
        let size = dataSet.scatterShapeSize
        let rect = CGRect(x: point.x - size/2, y: point.y - size/2, width: size, height: size)
        renderer(context, rect, CGSize(width: size, height: size))
    }
}

// MARK: - SwiftUI Modifiers

public extension DGPointChart {
    func xAxisConfig(_ config: DGChartAxisConfig) -> DGPointChart {
        var copy = self
        copy.xAxisConfig = config
        return copy
    }

    func yAxisConfig(_ config: DGChartAxisConfig) -> DGPointChart {
        var copy = self
        copy.yAxisConfig = config
        return copy
    }

    func legendConfig(_ config: DGChartLegendConfig) -> DGPointChart {
        var copy = self
        copy.legendConfig = config
        return copy
    }

    func selectionConfig(_ config: DGChartSelectionConfig) -> DGPointChart {
        var copy = self
        copy.selectionConfig = config
        return copy
    }

    func scrollConfig(_ config: DGChartScrollConfig) -> DGPointChart {
        var copy = self
        copy.scrollConfig = config
        return copy
    }

    func animationConfig(_ config: DGChartAnimationConfig) -> DGPointChart {
        var copy = self
        copy.animationConfig = config
        return copy
    }

    func colorScheme(_ scheme: DGChartColorScheme) -> DGPointChart {
        var copy = self
        copy.colorScheme = scheme
        return copy
    }

    func chartBackground(_ color: UIColor) -> DGPointChart {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    func chartBorder(_ color: UIColor, width: CGFloat = 1) -> DGPointChart {
        var copy = self
        copy.borderColor = color
        copy.borderWidth = width
        return copy
    }

    func onSelectionChange(_ callback: @escaping ([Point]?, Highlight?) -> Void) -> DGPointChart {
        var copy = self
        copy.onSelectionChange = callback
        return copy
    }

    func onChartGesture(_ callback: @escaping (ChartGesture) -> Void) -> DGPointChart {
        var copy = self
        copy.onChartGesture = callback
        return copy
    }
}

// MARK: - Convenience Initializers

public extension DGPointChart where Point == DGChartPoint<Double, Double> {
    init(
        _ data: [DGChartPoint<Double, Double>],
        label: String = "Series",
        color: UIColor = .systemBlue,
        symbol: DGChartSymbol = .circle,
        symbolSize: CGFloat = 10
    ) {
        let dataSet = DGPointChartDataSet(
            label: label,
            data: data,
            color: color,
            symbol: symbol,
            symbolSize: symbolSize
        )
        self.init(dataSets: [dataSet])
    }
}

public extension DGPointChart where Point == DGChartDatePoint<Double> {
    init(
        _ data: [DGChartDatePoint<Double>],
        label: String = "Series",
        color: UIColor = .systemBlue,
        symbol: DGChartSymbol = .circle,
        symbolSize: CGFloat = 10
    ) {
        let dataSet = DGPointChartDataSet(
            label: label,
            data: data,
            color: color,
            symbol: symbol,
            symbolSize: symbolSize
        )
        self.init(dataSets: [dataSet])
    }
}

public extension DGPointChart where Point == DGChartCategoryPoint<Double> {
    init(
        _ data: [DGChartCategoryPoint<Double>],
        label: String = "Series",
        color: UIColor = .systemBlue,
        symbol: DGChartSymbol = .circle,
        symbolSize: CGFloat = 10
    ) {
        let dataSet = DGPointChartDataSet(
            label: label,
            data: data,
            color: color,
            symbol: symbol,
            symbolSize: symbolSize
        )
        self.init(dataSets: [dataSet])
    }
}

