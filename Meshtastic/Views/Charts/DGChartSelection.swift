//
//  DGChartSelection.swift
//  Meshtastic
//
//  Selection and interaction configuration for DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Selection Mode

/// Selection/highlight mode for charts
public enum DGChartSelectionMode {
    case none
    case single
    case multiple
    case nearestX
    case nearestY
    case nearestXY
    case xRange
    case yRange
}

// MARK: - Selection Configuration

/// Configuration for chart selection/highlighting
public protocol DGChartSelectionConfig {
    var mode: DGChartSelectionMode { get }
    var highlightColor: UIColor { get }
    var highlightLineWidth: CGFloat { get }
    var highlightLineDashPattern: [CGFloat]? { get }
    var drawHorizontalHighlightIndicator: Bool { get }
    var drawVerticalHighlightIndicator: Bool { get }
    var highlighter: DGChartHighlighter? { get }
    var selectionChanged: (([ChartDataEntry]?, Highlight?) -> Void)? { get }
}

// Default implementation provided in DGChartsProtocols.swift

// MARK: - Highlighter Protocol

/// Custom highlighter for advanced selection logic
public protocol DGChartHighlighter {
    func getHighlight(x: Double, y: Double, dataSets: [IChartDataSet]) -> Highlight?
}

/// Default highlighter implementation
public struct DGChartDefaultHighlighter: DGChartHighlighter {
    public init() {}

    public func getHighlight(x: Double, y: Double, dataSets: [IChartDataSet]) -> Highlight? {
        // Use default DGCharts highlighter logic
        return nil
    }
}

/// Nearest X highlighter
public struct DGChartNearestXHighlighter: DGChartHighlighter {
    public init() {}

    public func getHighlight(x: Double, y: Double, dataSets: [IChartDataSet]) -> Highlight? {
        var closestHighlight: Highlight?
        var closestDistance: Double = .greatestFiniteMagnitude

        for dataSet in dataSets {
            for i in 0..<dataSet.entryCount {
                guard let entry = dataSet.entryForIndex(i) else { continue }
                let distance = abs(entry.x - x)
                if distance < closestDistance {
                    closestDistance = distance
                    closestHighlight = Highlight(x: entry.x, y: entry.y, dataSetIndex: 0, dataIndex: i, axis: .left)
                }
            }
        }

        return closestHighlight
    }
}

/// Nearest Y highlighter
public struct DGChartNearestYHighlighter: DGChartHighlighter {
    public init() {}

    public func getHighlight(x: Double, y: Double, dataSets: [IChartDataSet]) -> Highlight? {
        var closestHighlight: Highlight?
        var closestDistance: Double = .greatestFiniteMagnitude

        for dataSet in dataSets {
            for i in 0..<dataSet.entryCount {
                guard let entry = dataSet.entryForIndex(i) else { continue }
                let distance = abs(entry.y - y)
                if distance < closestDistance {
                    closestDistance = distance
                    closestHighlight = Highlight(x: entry.x, y: entry.y, dataSetIndex: 0, dataIndex: i, axis: .left)
                }
            }
        }

        return closestHighlight
    }
}

// MARK: - Selection Modifiers

public struct DGChartSelectionModifier<Content: View>: View {
    let content: Content
    let selectionConfig: DGChartSelectionConfig?

    public init(_ content: Content, selectionConfig: DGChartSelectionConfig?) {
        self.content = content
        self.selectionConfig = selectionConfig
    }

    public var body: some View {
        content
    }
}

public extension View {
    func chartSelection(_ config: DGChartSelectionConfig?) -> some View {
        DGChartSelectionModifier(self, selectionConfig: config)
    }

    func chartSelectionMode(_ mode: DGChartSelectionMode) -> some View {
        var config = DGDefaultSelectionConfig()
        config.mode = mode
        return chartSelection(config)
    }
}

// MARK: - Selection Appearance Modifiers

public extension DGDefaultSelectionConfig {
    func mode(_ mode: DGChartSelectionMode) -> DGDefaultSelectionConfig {
        var copy = self
        copy.mode = mode
        return copy
    }

    func highlightColor(_ color: UIColor) -> DGDefaultSelectionConfig {
        var copy = self
        copy.highlightColor = color
        return copy
    }

    func highlightLineWidth(_ width: CGFloat) -> DGDefaultSelectionConfig {
        var copy = self
        copy.highlightLineWidth = width
        return copy
    }

    func highlightLineDashPattern(_ pattern: [CGFloat]?) -> DGDefaultSelectionConfig {
        var copy = self
        copy.highlightLineDashPattern = pattern
        return copy
    }

    func drawHorizontalHighlightIndicator(_ enabled: Bool) -> DGDefaultSelectionConfig {
        var copy = self
        copy.drawHorizontalHighlightIndicator = enabled
        return copy
    }

    func drawVerticalHighlightIndicator(_ enabled: Bool) -> DGDefaultSelectionConfig {
        var copy = self
        copy.drawVerticalHighlightIndicator = enabled
        return copy
    }

    func highlighter(_ highlighter: DGChartHighlighter?) -> DGDefaultSelectionConfig {
        var copy = self
        copy.highlighter = highlighter
        return copy
    }
}

// MARK: - Selection Callbacks

/// Selection callback data
public struct DGChartSelectionInfo<Point: DGChartDataPoint> {
    public let selectedPoints: [Point]
    public let highlight: Highlight?
    public let dataSetIndex: Int
    public let dataIndex: Int
    public let xValue: Double
    public let yValue: Double
}

/// Selection gesture recognizer for custom interaction
public struct DGChartSelectionGesture: ViewModifier {
    let onSelectionChange: (DGChartSelectionInfo<Any>?) -> Void

    public func body(content: Content) -> some View {
        // This is a marker modifier - actual implementation is in chart views
        content
    }
}

public extension View {
    func onChartSelectionChange<Point: DGChartDataPoint>(
        _ callback: @escaping (DGChartSelectionInfo<Point>?) -> Void
    ) -> some View {
        modifier(DGChartSelectionGesture { info in
            // Type erasure for the modifier
            if let typedInfo = info as? DGChartSelectionInfo<Point> {
                callback(typedInfo)
            }
        })
    }
}

// MARK: - Highlight View

/// View for displaying highlight information (tooltip, callout, etc.)
public struct DGChartHighlightView<Content: View>: View {
    let highlight: Highlight?
    let content: (Highlight?) -> Content

    public init(highlight: Highlight?, @ViewBuilder content: @escaping (Highlight?) -> Content) {
        self.highlight = highlight
        self.content = content
    }

    public var body: some View {
        content(highlight)
    }
}

// MARK: - Selection State

/// Observable selection state for programmatic control
@MainActor
public final class DGChartSelectionState: ObservableObject {
    @Published public var selectedHighlight: Highlight?
    @Published public var selectedEntries: [ChartDataEntry] = []
    @Published public var isSelecting: Bool = false

    public init() {}

    public func select(highlight: Highlight?, entries: [ChartDataEntry]) {
        selectedHighlight = highlight
        selectedEntries = entries
    }

    public func clear() {
        selectedHighlight = nil
        selectedEntries = []
    }

    public func selectEntry(at index: Int, in dataSetIndex: Int) {
        // Programmatic selection by index
    }
}

// MARK: - Selection Environment

private struct DGChartSelectionStateKey: EnvironmentKey {
    static let defaultValue: DGChartSelectionState = DGChartSelectionState()
}

public extension EnvironmentValues {
    var chartSelectionState: DGChartSelectionState {
        get { self[DGChartSelectionStateKey.self] }
        set { self[DGChartSelectionStateKey.self] = newValue }
    }
}