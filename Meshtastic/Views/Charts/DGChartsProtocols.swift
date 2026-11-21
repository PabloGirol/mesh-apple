//
//  DGChartsProtocols.swift
//  Meshtastic
//
//  SwiftUI wrapper protocols for DGCharts that replicate Swift Charts API surface
//

import SwiftUI
import DGCharts

// MARK: - Chart Data Protocols

/// Protocol for chart data points - matches Swift Charts' Plottable concept
public protocol DGChartDataPoint: Identifiable {
    associatedtype XValue: Comparable
    associatedtype YValue: Comparable

    var x: XValue { get }
    var y: YValue { get }
}

/// Simple tuple-based data point for quick charts
public struct DGChartPoint<X: Comparable, Y: Comparable>: DGChartDataPoint {
    public let id = UUID()
    public let x: X
    public let y: Y

    public init(x: X, y: Y) {
        self.x = x
        self.y = y
    }
}

/// Date-based data point
public struct DGChartDatePoint<Y: Comparable>: DGChartDataPoint {
    public let id = UUID()
    public let x: Date
    public let y: Y

    public init(x: Date, y: Y) {
        self.x = x
        self.y = y
    }
}

/// String-based data point (for categorical data)
public struct DGChartCategoryPoint<Y: Comparable>: DGChartDataPoint {
    public let id = UUID()
    public let x: String
    public let y: Y

    public init(x: String, y: Y) {
        self.x = x
        self.y = y
    }
}

// MARK: - Chart Style Protocols

/// Protocol for line styling - mirrors Swift Charts LineStyle
public protocol DGLineStyle {
    var lineWidth: CGFloat { get }
    var dashPattern: [CGFloat]? { get }
    var lineCap: CGLineCap { get }
    var lineJoin: CGLineJoin { get }
    var miterLimit: CGFloat { get }
}

extension StrokeStyle: DGLineStyle {
    public var lineWidth: CGFloat { self.lineWidth }
    public var dashPattern: [CGFloat]? { self.dash.isEmpty ? nil : self.dash }
    public var lineCap: CGLineCap { self.lineCap }
    public var lineJoin: CGLineJoin { self.lineJoin }
    public var miterLimit: CGFloat { self.miterLimit }
}

/// Protocol for mark styling
public protocol DGMarkStyle {
    var size: CGSize { get }
    var fillColor: UIColor? { get }
    var strokeColor: UIColor? { get }
    var strokeWidth: CGFloat { get }
}

/// Symbol shapes for point marks
public enum DGChartSymbol: Equatable {
    case circle
    case square
    case triangle
    case diamond
    case cross
    case plus
    case custom((CGContext, CGRect, CGSize) -> Void)

    public static func == (lhs: DGChartSymbol, rhs: DGChartSymbol) -> Bool {
        switch (lhs, rhs) {
        case (.circle, .circle), (.square, .square), (.triangle, .triangle),
             (.diamond, .diamond), (.cross, .cross), (.plus, .plus):
            return true
        case (.custom, .custom):
            return false // Can't compare closures
        default:
            return false
        }
    }
}

// MARK: - Axis Configuration Protocols

/// Axis position - matches Swift Charts AxisMarkPosition
public enum DGChartAxisPosition {
    case automatic
    case leading
    case trailing
    case center
}

/// Axis scale type
public enum DGChartAxisScale {
    case linear
    case log
    case date
    case category
}

/// Axis configuration matching Swift Charts AxisMark
public protocol DGChartAxisConfig {
    var position: DGChartAxisPosition { get }
    var scale: DGChartAxisScale { get }
    var label: String? { get }
    var labelColor: UIColor { get }
    var labelFont: UIFont { get }
    var gridColor: UIColor { get }
    var gridWidth: CGFloat { get }
    var gridDashPattern: [CGFloat]? { get }
    var tickColor: UIColor { get }
    var tickLength: CGFloat { get }
    var tickWidth: CGFloat { get }
    var minValue: Double? { get }
    var maxValue: Double? { get }
    var labelCount: Int { get }
    var forceLabelsEnabled: Bool { get }
    var valueFormatter: ((Double) -> String)? { get }
    var dateFormat: String? { get }
    var granularity: Double? { get }
}

/// Default axis configuration
public struct DGDefaultAxisConfig: DGChartAxisConfig {
    public var position: DGChartAxisPosition = .automatic
    public var scale: DGChartAxisScale = .linear
    public var label: String? = nil
    public var labelColor: UIColor = .label
    public var labelFont: UIFont = .systemFont(ofSize: 11)
    public var gridColor: UIColor = .separator
    public var gridWidth: CGFloat = 0.5
    public var gridDashPattern: [CGFloat]? = nil
    public var tickColor: UIColor = .separator
    public var tickLength: CGFloat = 5
    public var tickWidth: CGFloat = 0.5
    public var minValue: Double? = nil
    public var maxValue: Double? = nil
    public var labelCount: Int = 6
    public var forceLabelsEnabled: Bool = false
    public var valueFormatter: ((Double) -> String)? = nil
    public var dateFormat: String? = nil
    public var granularity: Double? = nil

    public init() {}
}

// MARK: - Legend Configuration

/// Legend position
public enum DGChartLegendPosition {
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case insideTopLeft
    case insideTopRight
    case insideBottomLeft
    case insideBottomRight
}

/// Legend configuration
public protocol DGChartLegendConfig {
    var enabled: Bool { get }
    var position: DGChartLegendPosition { get }
    var horizontalAlignment: DGChartLegendHorizontalAlignment { get }
    var verticalAlignment: DGChartLegendVerticalAlignment { get }
    var orientation: DGChartLegendOrientation { get }
    var drawInside: Bool { get }
    var direction: DGChartLegendDirection { get }
    var textColor: UIColor { get }
    var font: UIFont { get }
    var form: DGChartLegendForm { get }
    var formSize: CGFloat { get }
    var formToTextSpace: CGFloat { get }
    var xEntrySpace: CGFloat { get }
    var yEntrySpace: CGFloat { get }
    var xOffset: CGFloat { get }
    var yOffset: CGFloat { get }
    var backgroundColor: UIColor? { get }
    var borderColor: UIColor? { get }
    var borderWidth: CGFloat { get }
    var wordWrapEnabled: Bool { get }
    var maxSizePercent: CGFloat { get }
}

public enum DGChartLegendHorizontalAlignment: Int {
    case left = 0, center = 1, right = 2
}

public enum DGChartLegendVerticalAlignment: Int {
    case top = 0, center = 1, bottom = 2
}

public enum DGChartLegendOrientation: Int {
    case horizontal = 0, vertical = 1
}

public enum DGChartLegendDirection: Int {
    case leftToRight = 0, rightToLeft = 1
}

public enum DGChartLegendForm: Int {
    case none = 0, empty = 1, defaultForm = 2, square = 3, circle = 4, line = 5
}

/// Default legend configuration
public struct DGDefaultLegendConfig: DGChartLegendConfig {
    public var enabled: Bool = true
    public var position: DGChartLegendPosition = .bottom
    public var horizontalAlignment: DGChartLegendHorizontalAlignment = .center
    public var verticalAlignment: DGChartLegendVerticalAlignment = .bottom
    public var orientation: DGChartLegendOrientation = .horizontal
    public var drawInside: Bool = false
    public var direction: DGChartLegendDirection = .leftToRight
    public var textColor: UIColor = .label
    public var font: UIFont = .systemFont(ofSize: 11)
    public var form: DGChartLegendForm = .defaultForm
    public var formSize: CGFloat = 12
    public var formToTextSpace: CGFloat = 5
    public var xEntrySpace: CGFloat = 14
    public var yEntrySpace: CGFloat = 4
    public var xOffset: CGFloat = 0
    public var yOffset: CGFloat = 0
    public var backgroundColor: UIColor? = nil
    public var borderColor: UIColor? = nil
    public var borderWidth: CGFloat = 0
    public var wordWrapEnabled: Bool = false
    public var maxSizePercent: CGFloat = 0.95

    public init() {}
}

// MARK: - Selection/Interaction Protocols

/// Selection mode
public enum DGChartSelectionMode {
    case none
    case single
    case multiple
    case nearestX
    case nearestY
    case nearestXY
}

/// Selection configuration
public protocol DGChartSelectionConfig {
    var mode: DGChartSelectionMode { get }
    var highlightColor: UIColor { get }
    var highlightLineWidth: CGFloat { get }
    var highlightLineDashPattern: [CGFloat]? { get }
    var drawHorizontalHighlightIndicator: Bool { get }
    var drawVerticalHighlightIndicator: Bool { get }
    var highlighter: DGChartHighlighter? { get }
}

/// Default selection configuration
public struct DGDefaultSelectionConfig: DGChartSelectionConfig {
    public var mode: DGChartSelectionMode = .single
    public var highlightColor: UIColor = .systemBlue
    public var highlightLineWidth: CGFloat = 1
    public var highlightLineDashPattern: [CGFloat]? = nil
    public var drawHorizontalHighlightIndicator: Bool = true
    public var drawVerticalHighlightIndicator: Bool = true
    public var highlighter: DGChartHighlighter? = nil

    public init() {}
}

/// Custom highlighter protocol
public protocol DGChartHighlighter {
    func getHighlight(x: Double, y: Double, dataSets: [IChartDataSet]) -> Highlight?
}

// MARK: - Scroll/Zoom Protocols

/// Scroll/zoom configuration
public protocol DGChartScrollConfig {
    var scaleXEnabled: Bool { get }
    var scaleYEnabled: Bool { get }
    var dragEnabled: Bool { get }
    var dragXEnabled: Bool { get }
    var dragYEnabled: Bool { get }
    var pinchZoomEnabled: Bool { get }
    var doubleTapToZoomEnabled: Bool { get }
    var highlightPerDragEnabled: Bool { get }
    var minScaleX: CGFloat { get }
    var maxScaleX: CGFloat { get }
    var minScaleY: CGFloat { get }
    var maxScaleY: CGFloat { get }
    var visibleXRange: ClosedRange<Double>? { get }
    var visibleYRange: ClosedRange<Double>? { get }
}

/// Default scroll configuration
public struct DGDefaultScrollConfig: DGChartScrollConfig {
    public var scaleXEnabled: Bool = true
    public var scaleYEnabled: Bool = true
    public var dragEnabled: Bool = true
    public var dragXEnabled: Bool = true
    public var dragYEnabled: Bool = true
    public var pinchZoomEnabled: Bool = true
    public var doubleTapToZoomEnabled: Bool = true
    public var highlightPerDragEnabled: Bool = true
    public var minScaleX: CGFloat = 1
    public var maxScaleX: CGFloat = 10000
    public var minScaleY: CGFloat = 1
    public var maxScaleY: CGFloat = 10000
    public var visibleXRange: ClosedRange<Double>? = nil
    public var visibleYRange: ClosedRange<Double>? = nil

    public init() {}
}

// MARK: - Animation Protocols

/// Animation configuration
public protocol DGChartAnimationConfig {
    var enabled: Bool { get }
    var duration: TimeInterval { get }
    var easing: DGChartEasingFunction { get }
}

public enum DGChartEasingFunction {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case easeInSine
    case easeOutSine
    case easeInOutSine
    case easeInQuad
    case easeOutQuad
    case easeInOutQuad
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    case easeInQuart
    case easeOutQuart
    case easeInOutQuart
    case easeInQuint
    case easeOutQuint
    case easeInOutQuint
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo
    case easeInCirc
    case easeOutCirc
    case easeInOutCirc
    case easeInBack
    case easeOutBack
    case easeInOutBack
    case easeInElastic
    case easeOutElastic
    case easeInOutElastic
    case easeInBounce
    case easeOutBounce
    case easeInOutBounce

    func toDGChartEasing() -> ChartEasingOption {
        switch self {
        case .linear: return .linear
        case .easeIn: return .easeIn
        case .easeOut: return .easeOut
        case .easeInOut: return .easeInOut
        case .easeInSine: return .easeInSine
        case .easeOutSine: return .easeOutSine
        case .easeInOutSine: return .easeInOutSine
        case .easeInQuad: return .easeInQuad
        case .easeOutQuad: return .easeOutQuad
        case .easeInOutQuad: return .easeInOutQuad
        case .easeInCubic: return .easeInCubic
        case .easeOutCubic: return .easeOutCubic
        case .easeInOutCubic: return .easeInOutCubic
        case .easeInQuart: return .easeInQuart
        case .easeOutQuart: return .easeOutQuart
        case .easeInOutQuart: return .easeInOutQuart
        case .easeInQuint: return .easeInQuint
        case .easeOutQuint: return .easeOutQuint
        case .easeInOutQuint: return .easeInOutQuint
        case .easeInExpo: return .easeInExpo
        case .easeOutExpo: return .easeOutExpo
        case .easeInOutExpo: return .easeInOutExpo
        case .easeInCirc: return .easeInCirc
        case .easeOutCirc: return .easeOutCirc
        case .easeInOutCirc: return .easeInOutCirc
        case .easeInBack: return .easeInBack
        case .easeOutBack: return .easeOutBack
        case .easeInOutBack: return .easeInOutBack
        case .easeInElastic: return .easeInElastic
        case .easeOutElastic: return .easeOutElastic
        case .easeInOutElastic: return .easeInOutElastic
        case .easeInBounce: return .easeInBounce
        case .easeOutBounce: return .easeOutBounce
        case .easeInOutBounce: return .easeInOutBounce
        }
    }
}

/// Default animation configuration
public struct DGDefaultAnimationConfig: DGChartAnimationConfig {
    public var enabled: Bool = true
    public var duration: TimeInterval = 1.0
    public var easing: DGChartEasingFunction = .easeInOutQuart

    public init() {}
}

// MARK: - Color/Gradient Mapping

/// Color scheme for charts
public protocol DGChartColorScheme {
    func color(for index: Int, total: Int) -> UIColor
    func gradient(for index: Int, total: Int) -> CGGradient?
}

/// Default color scheme using system colors
public struct DGDefaultColorScheme: DGChartColorScheme {
    private let colors: [UIColor] = [
        .systemBlue, .systemGreen, .systemOrange, .systemRed,
        .systemPurple, .systemPink, .systemTeal, .systemIndigo,
        .systemYellow, .systemBrown, .systemCyan, .systemMint
    ]

    public func color(for index: Int, total: Int) -> UIColor {
        colors[index % colors.count]
    }

    public func gradient(for index: Int, total: Int) -> CGGradient? {
        let color = self.color(for: index, total: total)
        let colors = [color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0.1).cgColor]
        let locations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)
    }
}

/// Categorical color scheme
public struct DGCategoricalColorScheme: DGChartColorScheme {
    private let colors: [UIColor]

    public init(colors: [UIColor]) {
        self.colors = colors
    }

    public func color(for index: Int, total: Int) -> UIColor {
        colors[index % colors.count]
    }

    public func gradient(for index: Int, total: Int) -> CGGradient? {
        let color = self.color(for: index, total: total)
        let colors = [color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0.1).cgColor]
        let locations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)
    }
}

/// Sequential color scheme
public struct DGSequentialColorScheme: DGChartColorScheme {
    private let startColor: UIColor
    private let endColor: UIColor
    private let steps: Int

    public init(startColor: UIColor, endColor: UIColor, steps: Int = 12) {
        self.startColor = startColor
        self.endColor = endColor
        self.steps = steps
    }

    public func color(for index: Int, total: Int) -> UIColor {
        let clampedIndex = min(max(index, 0), steps - 1)
        let progress = CGFloat(clampedIndex) / CGFloat(max(steps - 1, 1))
        return interpolate(from: startColor, to: endColor, progress: progress)
    }

    public func gradient(for index: Int, total: Int) -> CGGradient? {
        let color = self.color(for: index, total: total)
        let colors = [color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0.1).cgColor]
        let locations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)
    }

    private func interpolate(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0

        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)

        let r = fromR + (toR - fromR) * progress
        let g = fromG + (toG - fromG) * progress
        let b = fromB + (toB - fromB) * progress
        let a = fromA + (toA - fromA) * progress

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

/// Diverging color scheme
public struct DGDivergingColorScheme: DGChartColorScheme {
    private let negativeColor: UIColor
    private let neutralColor: UIColor
    private let positiveColor: UIColor

    public init(negative: UIColor, neutral: UIColor, positive: UIColor) {
        self.negativeColor = negative
        self.neutralColor = neutral
        self.positiveColor = positive
    }

    public func color(for index: Int, total: Int) -> UIColor {
        // For diverging, we map based on value sign, not index
        // This is used differently - see DGChartDataSet for usage
        if index < total / 2 {
            return negativeColor
        } else if index == total / 2 && total % 2 == 1 {
            return neutralColor
        } else {
            return positiveColor
        }
    }

    public func gradient(for index: Int, total: Int) -> CGGradient? {
        let color = self.color(for: index, total: total)
        let colors = [color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0.1).cgColor]
        let locations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)
    }
}

// MARK: - Chart Data Set Protocol

/// Protocol for chart data sets - matches Swift Charts data grouping concept
public protocol DGChartDataSet {
    associatedtype DataPoint: DGChartDataPoint

    var id: String { get }
    var label: String { get }
    var data: [DataPoint] { get }
    var color: UIColor { get }
    var gradient: CGGradient? { get }
    var lineStyle: DGLineStyle? { get }
    var markStyle: DGMarkStyle? { get }
    var symbol: DGChartSymbol { get }
    var isVisible: Bool { get }
    var order: Int { get }
}

// MARK: - Chart View Protocol

/// Base protocol for all DGChart SwiftUI wrappers
public protocol DGChartView: View {
    associatedtype ChartData: DGChartDataSet

    var data: [ChartData] { get }
    var xAxisConfig: DGChartAxisConfig { get }
    var yAxisConfig: DGChartAxisConfig { get }
    var legendConfig: DGChartLegendConfig { get }
    var selectionConfig: DGChartSelectionConfig { get }
    var scrollConfig: DGChartScrollConfig { get }
    var animationConfig: DGChartAnimationConfig { get }
    var colorScheme: DGChartColorScheme { get }
    var backgroundColor: UIColor { get }
    var borderColor: UIColor { get }
    var borderWidth: CGFloat { get }

    func makeChartView() -> ChartViewBase
    func updateChartView(_ chartView: ChartViewBase)
}

// MARK: - Chart View Base

/// Base class for DGCharts views wrapped in SwiftUI
open class DGChartViewBase: ChartViewBase {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    private func setupDefaults() {
        backgroundColor = .clear
        noDataText = "No data available"
        noDataTextColor = .secondaryLabel
        noDataFont = .systemFont(ofSize: 14)
    }
}