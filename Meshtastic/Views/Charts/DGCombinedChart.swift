//
//  DGCombinedChart.swift
//  Meshtastic
//
//  SwiftUI wrapper for DGCharts CombinedChartView replicating Swift Charts mixed mark types API
//

import SwiftUI
import DGCharts

// MARK: - Combined Chart Data Types

/// Chart type for each data series in combined chart
public enum DGCombinedChartType: Int {
    case line = 0
    case bar = 1
    case area = 2  // Line with fill
    case scatter = 3
    case bubble = 4
    case candleStick = 5
}

/// Data set for combined charts - supports multiple chart types
public struct DGCombinedChartDataSet<Point: DGChartDataPoint> {
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

    // Type-specific properties
    public var chartType: DGCombinedChartType
    public var yAxisSide: DGYAxisSide

    // Line/Area specific
    public var lineWidth: CGFloat
    public var interpolationMethod: DGChartInterpolationMethod
    public var fillEnabled: Bool
    public var fillColor: UIColor?
    public var fillGradient: CGGradient?
    public var fillAlpha: CGFloat
    public var drawLine: Bool
    public var lineColor: UIColor?

    // Bar specific
    public var barWidth: Double
    public var cornerRadius: CGFloat
    public var isStacked: Bool
    public var stackLabel: String?

    // Scatter/Bubble specific
    public var symbolSize: CGFloat
    public var symbolStrokeWidth: CGFloat
    public var symbolStrokeColor: UIColor?

    // Bubble specific
    public var bubbleSizeScale: CGFloat
    public var bubbleMaxSize: CGFloat

    // CandleStick specific
    public var shadowColor: UIColor
    public var shadowWidth: CGFloat
    public var decreasingColor: UIColor
    public var increasingColor: UIColor
    public var neutralColor: UIColor

    public init(
        id: String = UUID().uuidString,
        label: String,
        data: [Point],
        chartType: DGCombinedChartType = .line,
        yAxisSide: DGYAxisSide = .left,
        color: UIColor = .systemBlue,
        gradient: CGGradient? = nil,
        lineStyle: DGLineStyle? = nil,
        markStyle: DGMarkStyle? = nil,
        symbol: DGChartSymbol = .circle,
        isVisible: Bool = true,
        order: Int = 0,
        // Line/Area
        lineWidth: CGFloat = 2,
        interpolationMethod: DGChartInterpolationMethod = .linear,
        fillEnabled: Bool = false,
        fillColor: UIColor? = nil,
        fillGradient: CGGradient? = nil,
        fillAlpha: CGFloat = 0.3,
        drawLine: Bool = true,
        lineColor: UIColor? = nil,
        // Bar
        barWidth: Double = 0.8,
        cornerRadius: CGFloat = 0,
        isStacked: Bool = false,
        stackLabel: String? = nil,
        // Scatter/Bubble
        symbolSize: CGFloat = 10,
        symbolStrokeWidth: CGFloat = 1.5,
        symbolStrokeColor: UIColor? = nil,
        // Bubble
        bubbleSizeScale: CGFloat = 1.0,
        bubbleMaxSize: CGFloat = 50,
        // CandleStick
        shadowColor: UIColor = .label,
        shadowWidth: CGFloat = 1,
        decreasingColor: UIColor = .systemRed,
        increasingColor: UIColor = .systemGreen,
        neutralColor: UIColor = .systemGray
    ) {
        self.id = id
        self.label = label
        self.data = data
        self.chartType = chartType
        self.yAxisSide = yAxisSide
        self.color = color
        self.gradient = gradient
        self.lineStyle = lineStyle
        self.markStyle = markStyle
        self.symbol = symbol
        self.isVisible = isVisible
        self.order = order
        self.lineWidth = lineWidth
        self.interpolationMethod = interpolationMethod
        self.fillEnabled = fillEnabled
        self.fillColor = fillColor
        self.fillGradient = fillGradient
        self.fillAlpha = fillAlpha
        self.drawLine = drawLine
        self.lineColor = lineColor
        self.barWidth = barWidth
        self.cornerRadius = cornerRadius
        self.isStacked = isStacked
        self.stackLabel = stackLabel
        self.symbolSize = symbolSize
        self.symbolStrokeWidth = symbolStrokeWidth
        self.symbolStrokeColor = symbolStrokeColor
        self.bubbleSizeScale = bubbleSizeScale
        self.bubbleMaxSize = bubbleMaxSize
        self.shadowColor = shadowColor
        self.shadowWidth = shadowWidth
        self.decreasingColor = decreasingColor
        self.increasingColor = increasingColor
        self.neutralColor = neutralColor
    }
}

/// Y-axis side for dual-axis charts
public enum DGYAxisSide {
    case left
    case right
}

// MARK: - Combined Chart View

/// SwiftUI wrapper for DGCharts CombinedChartView
public struct DGCombinedChart<Point: DGChartDataPoint>: UIViewRepresentable {
    public typealias DataSet = DGCombinedChartDataSet<Point>

    // Data
    public var dataSets: [DataSet]

    // Configuration
    public var xAxisConfig: DGChartAxisConfig
    public var leftYAxisConfig: DGChartAxisConfig
    public var rightYAxisConfig: DGChartAxisConfig
    public var legendConfig: DGChartLegendConfig
    public var selectionConfig: DGChartSelectionConfig
    public var scrollConfig: DGChartScrollConfig
    public var animationConfig: DGChartAnimationConfig
    public var colorScheme: DGChartColorScheme
    public var backgroundColor: UIColor
    public var borderColor: UIColor
    public var borderWidth: CGFloat

    // Layout
    public var drawOrder: [DGCombinedChartType]
    public var groupSpacing: Double
    public var barSpacing: Double

    // Callbacks
    public var onSelectionChange: (([Point]?, Highlight?) -> Void)?
    public var onChartGesture: ((ChartGesture) -> Void)?

    public init(
        dataSets: [DataSet],
        xAxisConfig: DGChartAxisConfig = DGDefaultAxisConfig(),
        leftYAxisConfig: DGChartAxisConfig = DGDefaultAxisConfig(),
        rightYAxisConfig: DGChartAxisConfig = DGDefaultAxisConfig(),
        legendConfig: DGChartLegendConfig = DGDefaultLegendConfig(),
        selectionConfig: DGChartSelectionConfig = DGDefaultSelectionConfig(),
        scrollConfig: DGChartScrollConfig = DGDefaultScrollConfig(),
        animationConfig: DGChartAnimationConfig = DGDefaultAnimationConfig(),
        colorScheme: DGChartColorScheme = DGDefaultColorScheme(),
        backgroundColor: UIColor = .clear,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0,
        drawOrder: [DGCombinedChartType] = [.bar, .bubble, .line, .candleStick, .scatter],
        groupSpacing: Double = 0.3,
        barSpacing: Double = 0.05,
        onSelectionChange: (([Point]?, Highlight?) -> Void)? = nil,
        onChartGesture: ((ChartGesture) -> Void)? = nil
    ) {
        self.dataSets = dataSets
        self.xAxisConfig = xAxisConfig
        self.leftYAxisConfig = leftYAxisConfig
        self.rightYAxisConfig = rightYAxisConfig
        self.legendConfig = legendConfig
        self.selectionConfig = selectionConfig
        self.scrollConfig = scrollConfig
        self.animationConfig = animationConfig
        self.colorScheme = colorScheme
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.drawOrder = drawOrder
        self.groupSpacing = groupSpacing
        self.barSpacing = barSpacing
        self.onSelectionChange = onSelectionChange
        self.onChartGesture = onChartGesture
    }

    public func makeUIView(context: Context) -> CombinedChartView {
        let chartView = CombinedChartView()
        chartView.delegate = context.coordinator
        configureChart(chartView)
        return chartView
    }

    public func updateUIView(_ chartView: CombinedChartView, context: Context) {
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

    private func configureChart(_ chartView: CombinedChartView) {
        chartView.backgroundColor = backgroundColor
        chartView.layer.borderColor = borderColor.cgColor
        chartView.layer.borderWidth = borderWidth

        // Draw order
        chartView.drawOrder = drawOrder.map { type in
            switch type {
            case .bar: return CombinedChartView.DrawOrder.bar.rawValue
            case .bubble: return CombinedChartView.DrawOrder.bubble.rawValue
            case .line: return CombinedChartView.DrawOrder.line.rawValue
            case .candleStick: return CombinedChartView.DrawOrder.candle.rawValue
            case .scatter: return CombinedChartView.DrawOrder.scatter.rawValue
            case .area: return CombinedChartView.DrawOrder.line.rawValue
            }
        }

        // Grid
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.gridColor = xAxisConfig.gridColor
        chartView.xAxis.gridLineWidth = xAxisConfig.gridWidth

        // Left Y Axis
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.gridColor = leftYAxisConfig.gridColor
        chartView.leftAxis.gridLineWidth = leftYAxisConfig.gridWidth
        chartView.leftAxis.gridLineDashLengths = leftYAxisConfig.gridDashPattern

        // Right Y Axis
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.gridColor = rightYAxisConfig.gridColor
        chartView.rightAxis.gridLineWidth = rightYAxisConfig.gridWidth

        // Axes
        configureAxis(chartView.xAxis, config: xAxisConfig, isXAxis: true)
        configureAxis(chartView.leftAxis, config: leftYAxisConfig, isXAxis: false)
        configureAxis(chartView.rightAxis, config: rightYAxisConfig, isXAxis: false)

        // Right axis enabled if any data set uses it
        chartView.rightAxis.enabled = dataSets.contains { $0.yAxisSide == .right && $0.isVisible }

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

        // Combined specific
        chartView.maxVisibleCount = 1000
        chartView.drawValueAboveBarEnabled = true
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

    private func updateChartData(_ chartView: CombinedChartView) {
        var lineDataSets: [LineChartDataSet] = []
        var barDataSets: [BarChartDataSet] = []
        var scatterDataSets: [ScatterChartDataSet] = []
        var bubbleDataSets: [BubbleChartDataSet] = []
        var candleDataSets: [CandleChartDataSet] = []

        // Sort by order
        let sortedDataSets = dataSets.filter { $0.isVisible }.sorted { $0.order < $1.order }

        var baseValues: [Double] = [] // For area stacking

        for dataSet in sortedDataSets {
            switch dataSet.chartType {
            case .line, .area:
                let lineDataSet = createLineDataSet(from: dataSet, baseValues: &baseValues)
                lineDataSets.append(lineDataSet)

            case .bar:
                let barDataSet = createBarDataSet(from: dataSet)
                barDataSets.append(barDataSet)

            case .scatter:
                let scatterDataSet = createScatterDataSet(from: dataSet)
                scatterDataSets.append(scatterDataSet)

            case .bubble:
                let bubbleDataSet = createBubbleDataSet(from: dataSet)
                bubbleDataSets.append(bubbleDataSet)

            case .candleStick:
                let candleDataSet = createCandleDataSet(from: dataSet)
                candleDataSets.append(candleDataSet)
            }
        }

        let combinedData = CombinedChartData()
        combinedData.lineData = lineDataSets.isEmpty ? nil : LineChartData(dataSets: lineDataSets)
        combinedData.barData = barDataSets.isEmpty ? nil : BarChartData(dataSets: barDataSets)
        combinedData.scatterData = scatterDataSets.isEmpty ? nil : ScatterChartData(dataSets: scatterDataSets)
        combinedData.bubbleData = bubbleDataSets.isEmpty ? nil : BubbleChartData(dataSets: bubbleDataSets)
        combinedData.candleData = candleDataSets.isEmpty ? nil : CandleChartData(dataSets: candleDataSets)

        // Group bars
        if !barDataSets.isEmpty && barDataSets.count > 1 {
            combinedData.barData?.groupBars(fromX: 0, groupSpace: groupSpacing, barSpace: barSpacing)
        }

        chartView.data = combinedData
    }

    private func createLineDataSet(from dataSet: DataSet, baseValues: inout [Double]) -> LineChartDataSet {
        let entries = dataSet.data.enumerated().map { index, point -> ChartDataEntry in
            let xValue = xValueForPoint(point, index: index)
            var yValue = yValueForPoint(point)

            // Handle area stacking
            if dataSet.chartType == .area && dataSet.fillEnabled && dataSet.isStacked {
                if dataSet.order > 0 && index < baseValues.count {
                    yValue += baseValues[index]
                    baseValues[index] = yValue
                } else if dataSet.order == 0 {
                    if index >= baseValues.count {
                        baseValues.append(yValue)
                    } else {
                        baseValues[index] = yValue
                    }
                }
            }

            return ChartDataEntry(x: xValue, y: yValue, data: point)
        }

        let lineDataSet = LineChartDataSet(entries: entries, label: dataSet.label)

        // Axis dependency
        lineDataSet.axisDependency = dataSet.yAxisSide == .left ? .left : .right

        // Colors
        let lineColor = dataSet.lineColor ?? dataSet.color
        lineDataSet.colors = dataSet.drawLine ? [lineColor] : [UIColor.clear]
        lineDataSet.circleColors = [dataSet.color]

        // Fill (for area)
        if dataSet.chartType == .area && dataSet.fillEnabled {
            lineDataSet.fillAlpha = dataSet.fillAlpha
            if let fillGradient = dataSet.fillGradient {
                lineDataSet.fill = Fill.fillWithLinearGradient(fillGradient, angle: 90)
            } else if let fillColor = dataSet.fillColor {
                lineDataSet.fill = Fill(color: fillColor.withAlphaComponent(dataSet.fillAlpha))
            } else {
                lineDataSet.fill = Fill(color: dataSet.color.withAlphaComponent(dataSet.fillAlpha))
            }
            lineDataSet.drawFilledEnabled = true
            lineDataSet.fillFormatter = DefaultFillFormatter { _, _ in 0 }
        }

        // Line style
        if let lineStyle = dataSet.lineStyle {
            lineDataSet.lineWidth = dataSet.drawLine ? lineStyle.lineWidth : 0
            lineDataSet.lineDashLengths = lineStyle.dashPattern
            lineDataSet.mode = dataSet.interpolationMethod.toDGChartMode()
        } else {
            lineDataSet.lineWidth = dataSet.drawLine ? dataSet.lineWidth : 0
            lineDataSet.mode = dataSet.interpolationMethod.toDGChartMode()
        }

        // Symbol
        lineDataSet.drawCirclesEnabled = dataSet.symbol != .none && dataSet.symbol != .custom
        lineDataSet.circleRadius = dataSet.symbolSize / 2
        lineDataSet.circleHoleRadius = max(0, dataSet.symbolSize * 0.3)
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

        lineDataSet.drawValuesEnabled = false
        lineDataSet.highlightColor = selectionConfig.highlightColor
        lineDataSet.highlightLineWidth = selectionConfig.highlightLineWidth

        return lineDataSet
    }

    private func createBarDataSet(from dataSet: DataSet) -> BarChartDataSet {
        let entries = dataSet.data.enumerated().map { index, point -> BarChartDataEntry in
            let xValue = xValueForPoint(point, index: index)
            let yValue = yValueForPoint(point)
            return BarChartDataEntry(x: xValue, y: yValue, data: point)
        }

        let barDataSet = BarChartDataSet(entries: entries, label: dataSet.label)
        barDataSet.axisDependency = dataSet.yAxisSide == .left ? .left : .right
        barDataSet.colors = [dataSet.color]

        if let gradient = dataSet.gradient {
            barDataSet.gradientColor = gradient
        }

        barDataSet.barWidth = dataSet.barWidth

        if dataSet.isStacked {
            barDataSet.stackLabels = [dataSet.stackLabel ?? dataSet.label]
        }

        barDataSet.drawValuesEnabled = false
        barDataSet.highlightColor = selectionConfig.highlightColor
        barDataSet.highlightAlpha = 120

        return barDataSet
    }

    private func createScatterDataSet(from dataSet: DataSet) -> ScatterChartDataSet {
        let entries = dataSet.data.enumerated().map { index, point -> ChartDataEntry in
            let xValue = xValueForPoint(point, index: index)
            let yValue = yValueForPoint(point)
            return ChartDataEntry(x: xValue, y: yValue, data: point)
        }

        let scatterDataSet = ScatterChartDataSet(entries: entries, label: dataSet.label)
        scatterDataSet.axisDependency = dataSet.yAxisSide == .left ? .left : .right
        scatterDataSet.colors = [dataSet.color]
        scatterDataSet.scatterShape = shapeForSymbol(dataSet.symbol)
        scatterDataSet.scatterShapeSize = dataSet.symbolSize
        scatterDataSet.scatterShapeHoleRadius = max(0, dataSet.symbolSize * 0.4)
        scatterDataSet.scatterShapeHoleColor = dataSet.symbolStrokeColor ?? .white

        if case .custom(let renderer) = dataSet.symbol {
            scatterDataSet.customScatterShapeRenderer = CustomScatterShapeRenderer(renderer: renderer)
        }

        scatterDataSet.drawValuesEnabled = false
        scatterDataSet.highlightColor = selectionConfig.highlightColor
        scatterDataSet.highlightLineWidth = selectionConfig.highlightLineWidth

        return scatterDataSet
    }

    private func createBubbleDataSet(from dataSet: DataSet) -> BubbleChartDataSet {
        let entries = dataSet.data.enumerated().map { index, point -> BubbleChartDataEntry in
            let xValue = xValueForPoint(point, index: index)
            let yValue = yValueForPoint(point)
            // For bubble, we need a size - use y value scaled or a fixed size
            let size = abs(yValue) * dataSet.bubbleSizeScale
            let clampedSize = min(max(size, 1), dataSet.bubbleMaxSize)
            return BubbleChartDataEntry(x: xValue, y: yValue, size: clampedSize, data: point)
        }

        let bubbleDataSet = BubbleChartDataSet(entries: entries, label: dataSet.label)
        bubbleDataSet.axisDependency = dataSet.yAxisSide == .left ? .left : .right
        bubbleDataSet.colors = [dataSet.color]
        bubbleDataSet.setCircleColor(dataSet.color)
        bubbleDataSet.highlightCircleWidth = 2
        bubbleDataSet.drawValuesEnabled = false

        return bubbleDataSet
    }

    private func createCandleDataSet(from dataSet: DataSet) -> CandleChartDataSet {
        let entries = dataSet.data.enumerated().map { index, point -> CandleChartDataEntry in
            let xValue = xValueForPoint(point, index: index)
            let yValue = yValueForPoint(point)
            // For candle, we'd need OHLC data - using y as close, simulating others
            let high = yValue * 1.02
            let low = yValue * 0.98
            let open = yValue * 0.99
            let close = yValue
            return CandleChartDataEntry(x: xValue, shadowH: high, shadowL: low, open: open, close: close, data: point)
        }

        let candleDataSet = CandleChartDataSet(entries: entries, label: dataSet.label)
        candleDataSet.axisDependency = dataSet.yAxisSide == .left ? .left : .right
        candleDataSet.shadowColor = dataSet.shadowColor
        candleDataSet.shadowWidth = dataSet.shadowWidth
        candleDataSet.decreasingColor = dataSet.decreasingColor
        candleDataSet.increasingColor = dataSet.increasingColor
        candleDataSet.neutralColor = dataSet.neutralColor
        candleDataSet.drawValuesEnabled = false

        return candleDataSet
    }

    private func updateChartConfiguration(_ chartView: CombinedChartView) {
        configureAxis(chartView.xAxis, config: xAxisConfig, isXAxis: true)
        configureAxis(chartView.leftAxis, config: leftYAxisConfig, isXAxis: false)
        configureAxis(chartView.rightAxis, config: rightYAxisConfig, isXAxis: false)
        chartView.rightAxis.enabled = dataSets.contains { $0.yAxisSide == .right && $0.isVisible }
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
        case .custom: return .circle
        case .none: return .circle
        }
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, ChartViewDelegate {
        let parent: DGCombinedChart

        init(_ parent: DGCombinedChart) {
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

public extension DGCombinedChart {
    func xAxisConfig(_ config: DGChartAxisConfig) -> DGCombinedChart {
        var copy = self
        copy.xAxisConfig = config
        return copy
    }

    func leftYAxisConfig(_ config: DGChartAxisConfig) -> DGCombinedChart {
        var copy = self
        copy.leftYAxisConfig = config
        return copy
    }

    func rightYAxisConfig(_ config: DGChartAxisConfig) -> DGCombinedChart {
        var copy = self
        copy.rightYAxisConfig = config
        return copy
    }

    func yAxisConfig(_ config: DGChartAxisConfig) -> DGCombinedChart {
        var copy = self
        copy.leftYAxisConfig = config
        copy.rightYAxisConfig = config
        return copy
    }

    func legendConfig(_ config: DGChartLegendConfig) -> DGCombinedChart {
        var copy = self
        copy.legendConfig = config
        return copy
    }

    func selectionConfig(_ config: DGChartSelectionConfig) -> DGCombinedChart {
        var copy = self
        copy.selectionConfig = config
        return copy
    }

    func scrollConfig(_ config: DGChartScrollConfig) -> DGCombinedChart {
        var copy = self
        copy.scrollConfig = config
        return copy
    }

    func animationConfig(_ config: DGChartAnimationConfig) -> DGCombinedChart {
        var copy = self
        copy.animationConfig = config
        return copy
    }

    func colorScheme(_ scheme: DGChartColorScheme) -> DGCombinedChart {
        var copy = self
        copy.colorScheme = scheme
        return copy
    }

    func chartBackground(_ color: UIColor) -> DGCombinedChart {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    func chartBorder(_ color: UIColor, width: CGFloat = 1) -> DGCombinedChart {
        var copy = self
        copy.borderColor = color
        copy.borderWidth = width
        return copy
    }

    func drawOrder(_ order: [DGCombinedChartType]) -> DGCombinedChart {
        var copy = self
        copy.drawOrder = order
        return copy
    }

    func groupSpacing(_ spacing: Double) -> DGCombinedChart {
        var copy = self
        copy.groupSpacing = spacing
        return copy
    }

    func barSpacing(_ spacing: Double) -> DGCombinedChart {
        var copy = self
        copy.barSpacing = spacing
        return copy
    }

    func onSelectionChange(_ callback: @escaping ([Point]?, Highlight?) -> Void) -> DGCombinedChart {
        var copy = self
        copy.onSelectionChange = callback
        return copy
    }

    func onChartGesture(_ callback: @escaping (ChartGesture) -> Void) -> DGCombinedChart {
        var copy = self
        copy.onChartGesture = callback
        return copy
    }
}

// MARK: - Convenience Initializers

public extension DGCombinedChart where Point == DGChartPoint<Double, Double> {
    init(
        _ dataSets: [DataSet]
    ) {
        self.init(dataSets: dataSets)
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

