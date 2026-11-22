//
//  DGChartScroll.swift
//  Meshtastic
//
//  Scroll, zoom, and pan configuration for DGCharts SwiftUI wrappers
//  DGChartScrollConfig protocol and DGDefaultScrollConfig are defined in DGChartsProtocols
//

import SwiftUI
import DGCharts

// MARK: - Viewport Job

/// Job for modifying viewport programmatically
public struct DGChartViewportJob {
    public let type: DGChartViewportJobType
    public let xValue: Double?
    public let yValue: Double?
    public let axis: YAxis.AxisDependency
    public let animated: Bool
    public let duration: TimeInterval

    public init(
        type: DGChartViewportJobType,
        xValue: Double? = nil,
        yValue: Double? = nil,
        axis: YAxis.AxisDependency = .left,
        animated: Bool = true,
        duration: TimeInterval = 0.5
    ) {
        self.type = type
        self.xValue = xValue
        self.yValue = yValue
        self.axis = axis
        self.animated = animated
        self.duration = duration
    }
}

public enum DGChartViewportJobType {
    case moveViewToX
    case moveViewToY
    case moveViewTo(x: Double, y: Double)
    case centerViewTo(x: Double, y: Double, axis: YAxis.AxisDependency)
    case setScale(xScale: CGFloat, yScale: CGFloat)
    case zoomIn
    case zoomOut
    case zoom(xScale: CGFloat, yScale: CGFloat, x: CGFloat, y: CGFloat)
    case resetZoom
}

// MARK: - Scroll Modifiers

public struct DGChartScrollModifier<Content: View>: View {
    let content: Content
    let scrollConfig: DGChartScrollConfig?

    public init(_ content: Content, scrollConfig: DGChartScrollConfig?) {
        self.content = content
        self.scrollConfig = scrollConfig
    }

    public var body: some View {
        content
    }
}

public extension View {
    func chartScroll(_ config: DGChartScrollConfig?) -> some View {
        DGChartScrollModifier(self, scrollConfig: config)
    }

    func chartScrollEnabled(_ enabled: Bool) -> some View {
        var config = DGDefaultScrollConfig()
        config.scaleXEnabled = enabled
        config.scaleYEnabled = enabled
        config.dragEnabled = enabled
        config.pinchZoomEnabled = enabled
        config.doubleTapToZoomEnabled = enabled
        return chartScroll(config)
    }

    func chartZoomEnabled(_ enabled: Bool) -> some View {
        var config = DGDefaultScrollConfig()
        config.scaleXEnabled = enabled
        config.scaleYEnabled = enabled
        config.pinchZoomEnabled = enabled
        config.doubleTapToZoomEnabled = enabled
        return chartScroll(config)
    }

    func chartPanEnabled(_ enabled: Bool) -> some View {
        var config = DGDefaultScrollConfig()
        config.dragEnabled = enabled
        config.dragXEnabled = enabled
        config.dragYEnabled = enabled
        return chartScroll(config)
    }
}

// MARK: - Scroll Appearance Modifiers

public extension DGDefaultScrollConfig {
    func scaleXEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.scaleXEnabled = enabled
        return copy
    }

    func scaleYEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.scaleYEnabled = enabled
        return copy
    }

    func dragEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.dragEnabled = enabled
        return copy
    }

    func dragXEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.dragXEnabled = enabled
        return copy
    }

    func dragYEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.dragYEnabled = enabled
        return copy
    }

    func pinchZoomEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.pinchZoomEnabled = enabled
        return copy
    }

    func doubleTapToZoomEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.doubleTapToZoomEnabled = enabled
        return copy
    }

    func highlightPerDragEnabled(_ enabled: Bool) -> DGDefaultScrollConfig {
        var copy = self
        copy.highlightPerDragEnabled = enabled
        return copy
    }

    func minScaleX(_ scale: CGFloat) -> DGDefaultScrollConfig {
        var copy = self
        copy.minScaleX = scale
        return copy
    }

    func maxScaleX(_ scale: CGFloat) -> DGDefaultScrollConfig {
        var copy = self
        copy.maxScaleX = scale
        return copy
    }

    func minScaleY(_ scale: CGFloat) -> DGDefaultScrollConfig {
        var copy = self
        copy.minScaleY = scale
        return copy
    }

    func maxScaleY(_ scale: CGFloat) -> DGDefaultScrollConfig {
        var copy = self
        copy.maxScaleY = scale
        return copy
    }

    func visibleXRange(_ range: ClosedRange<Double>?) -> DGDefaultScrollConfig {
        var copy = self
        copy.visibleXRange = range
        return copy
    }

    func visibleYRange(_ range: ClosedRange<Double>?) -> DGDefaultScrollConfig {
        var copy = self
        copy.visibleYRange = range
        return copy
    }

    func viewportJobs(_ jobs: [DGChartViewportJob]) -> DGDefaultScrollConfig {
        var copy = self
        copy.viewportJobs = jobs
        return copy
    }
}

// MARK: - Viewport Controller

/// Controller for programmatic viewport manipulation
@MainActor
public final class DGChartViewportController: ObservableObject {
    weak var chartView: ChartViewBase?

    public override init() {}

    public func setChartView(_ chartView: ChartViewBase) {
        self.chartView = chartView
    }

    // MARK: - Zoom

    public func zoomIn(animated: Bool = true) {
        chartView?.zoomIn()
    }

    public func zoomOut(animated: Bool = true) {
        chartView?.zoomOut()
    }

    public func zoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat, animated: Bool = true) {
        if animated {
            chartView?.zoom(scaleX: scaleX, scaleY: scaleY, x: x, y: y)
        } else {
            chartView?.zoom(scaleX: scaleX, scaleY: scaleY, x: x, y: y)
        }
    }

    public func setScale(minScaleX: CGFloat, minScaleY: CGFloat, maxScaleX: CGFloat, maxScaleY: CGFloat) {
        chartView?.setScaleMinima(minScaleX, minScaleY: minScaleY)
        chartView?.setScaleMaxima(maxScaleX, maxScaleY: maxScaleY)
    }

    public func resetZoom(animated: Bool = true) {
        chartView?.fitScreen()
    }

    // MARK: - Pan/Scroll

    public func moveViewToX(_ xValue: Double, animated: Bool = true) {
        chartView?.moveViewToX(xValue)
    }

    public func moveViewToY(_ yValue: Double, axis: YAxis.AxisDependency = .left, animated: Bool = true) {
        chartView?.moveViewToY(yValue, axis: axis)
    }

    public func moveViewTo(x: Double, y: Double, axis: YAxis.AxisDependency = .left, animated: Bool = true) {
        chartView?.moveViewTo(x: x, y: y, axis: axis)
    }

    public func centerViewTo(x: Double, y: Double, axis: YAxis.AxisDependency = .left, animated: Bool = true) {
        chartView?.centerViewTo(x: x, y: y, axis: axis)
    }

    // MARK: - Visible Range

    public func setVisibleXRange(minXRange: Double, maxXRange: Double) {
        chartView?.setVisibleXRange(minXRange: minXRange, maxXRange: maxXRange)
    }

    public func setVisibleYRange(minYRange: Double, maxYRange: Double, axis: YAxis.AxisDependency = .left) {
        chartView?.setVisibleYRange(minYRange: minYRange, maxYRange: maxYRange, axis: axis)
    }

    // MARK: - Getters

    public var visibleXRange: (min: Double, max: Double)? {
        guard let chartView = chartView else { return nil }
        let lowestX = chartView.lowestVisibleX
        let highestX = chartView.highestVisibleX
        return (lowestX, highestX)
    }

    public var visibleYRange: (min: Double, max: Double)? {
        guard let chartView = chartView else { return nil }
        let lowestY = chartView.lowestVisibleY
        let highestY = chartView.highestVisibleY
        return (lowestY, highestY)
    }

    public var scaleX: CGFloat { chartView?.scaleX ?? 1 }
    public var scaleY: CGFloat { chartView?.scaleY ?? 1 }

    public var isZoomed: Bool { scaleX > 1 || scaleY > 1 }

    public var contentRect: CGRect { chartView?.contentRect ?? .zero }

    // MARK: - Gestures

    public func enableGestures(
        scaleX: Bool? = nil,
        scaleY: Bool? = nil,
        drag: Bool? = nil,
        dragX: Bool? = nil,
        dragY: Bool? = nil,
        pinchZoom: Bool? = nil,
        doubleTapZoom: Bool? = nil
    ) {
        if let scaleX = scaleX { chartView?.scaleXEnabled = scaleX }
        if let scaleY = scaleY { chartView?.scaleYEnabled = scaleY }
        if let drag = drag { chartView?.dragEnabled = drag }
        if let dragX = dragX { chartView?.dragXEnabled = dragX }
        if let dragY = dragY { chartView?.dragYEnabled = dragY }
        if let pinchZoom = pinchZoom { chartView?.pinchZoomEnabled = pinchZoom }
        if let doubleTapZoom = doubleTapZoom { chartView?.doubleTapToZoomEnabled = doubleTapZoom }
    }
}

// MARK: - Scroll/Zoom Environment

private struct DGChartViewportControllerKey: EnvironmentKey {
    static let defaultValue: DGChartViewportController = DGChartViewportController()
    typealias Value = DGChartViewportController
}

public extension EnvironmentValues {
    var chartViewportController: DGChartViewportController {
        get { self[DGChartViewportControllerKey.self] }
        set { self[DGChartViewportControllerKey.self] = newValue }
    }
}

// MARK: - Convenience Scroll Configuration

public extension DGChartScrollConfig {
    /// Default scroll config with all gestures enabled
    static var `default`: DGDefaultScrollConfig { DGDefaultScrollConfig() }

    /// Zoom only (no pan)
    static var zoomOnly: DGDefaultScrollConfig {
        var config = DGDefaultScrollConfig()
        config.dragEnabled = false
        config.dragXEnabled = false
        config.dragYEnabled = false
        return config
    }

    /// Pan only (no zoom)
    static var panOnly: DGDefaultScrollConfig {
        var config = DGDefaultScrollConfig()
        config.scaleXEnabled = false
        config.scaleYEnabled = false
        config.pinchZoomEnabled = false
        config.doubleTapToZoomEnabled = false
        return config
    }

    /// X-axis only
    static var xAxisOnly: DGDefaultScrollConfig {
        var config = DGDefaultScrollConfig()
        config.scaleYEnabled = false
        config.dragYEnabled = false
        return config
    }

    /// Y-axis only
    static var yAxisOnly: DGDefaultScrollConfig {
        var config = DGDefaultScrollConfig()
        config.scaleXEnabled = false
        config.dragXEnabled = false
        return config
    }

    /// No interaction (static chart)
    static var none: DGDefaultScrollConfig {
        var config = DGDefaultScrollConfig()
        config.scaleXEnabled = false
        config.scaleYEnabled = false
        config.dragEnabled = false
        config.dragXEnabled = false
        config.dragYEnabled = false
        config.pinchZoomEnabled = false
        config.doubleTapToZoomEnabled = false
        config.highlightPerDragEnabled = false
        return config
    }
}