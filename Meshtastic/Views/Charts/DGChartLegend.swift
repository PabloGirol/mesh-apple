//
//  DGChartLegend.swift
//  Meshtastic
//
//  Legend configuration and modifiers for DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Legend Position

/// Position of legend in the chart
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
    case automatic
}

// MARK: - Legend Configuration Builder

@resultBuilder
public struct DGChartLegendConfigBuilder {
    public static func buildBlock(_ components: DGChartLegendConfig...) -> [DGChartLegendConfig] {
        components
    }

    public static func buildOptional(_ component: [DGChartLegendConfig]?) -> [DGChartLegendConfig] {
        component ?? []
    }

    public static func buildEither(first component: [DGChartLegendConfig]) -> [DGChartLegendConfig] {
        component
    }

    public static func buildEither(second component: [DGChartLegendConfig]) -> [DGChartLegendConfig] {
        component
    }

    public static func buildArray(_ components: [[DGChartLegendConfig]]) -> [DGChartLegendConfig] {
        components.flatMap { $0 }
    }
}

// MARK: - Legend Modifiers

public struct DGChartLegendModifier<Content: View>: View {
    let content: Content
    let legendConfig: DGChartLegendConfig?

    public init(_ content: Content, legendConfig: DGChartLegendConfig?) {
        self.content = content
        self.legendConfig = legendConfig
    }

    public var body: some View {
        content
    }
}

public extension View {
    func chartLegend(_ config: DGChartLegendConfig?) -> some View {
        DGChartLegendModifier(self, legendConfig: config)
    }

    func chartLegend(@DGChartLegendConfigBuilder _ config: () -> DGChartLegendConfig) -> some View {
        chartLegend(config())
    }

    func chartLegendHidden(_ hidden: Bool = true) -> some View {
        var config = DGDefaultLegendConfig()
        config.enabled = !hidden
        return chartLegend(config)
    }
}

// MARK: - Legend Appearance Modifiers

public extension DGDefaultLegendConfig {
    func enabled(_ enabled: Bool) -> DGDefaultLegendConfig {
        var copy = self
        copy.enabled = enabled
        return copy
    }

    func position(_ position: DGChartLegendPosition) -> DGDefaultLegendConfig {
        var copy = self
        copy.position = position
        return copy
    }

    func horizontalAlignment(_ alignment: DGChartLegendHorizontalAlignment) -> DGDefaultLegendConfig {
        var copy = self
        copy.horizontalAlignment = alignment
        return copy
    }

    func verticalAlignment(_ alignment: DGChartLegendVerticalAlignment) -> DGDefaultLegendConfig {
        var copy = self
        copy.verticalAlignment = alignment
        return copy
    }

    func orientation(_ orientation: DGChartLegendOrientation) -> DGDefaultLegendConfig {
        var copy = self
        copy.orientation = orientation
        return copy
    }

    func drawInside(_ inside: Bool) -> DGDefaultLegendConfig {
        var copy = self
        copy.drawInside = inside
        return copy
    }

    func direction(_ direction: DGChartLegendDirection) -> DGDefaultLegendConfig {
        var copy = self
        copy.direction = direction
        return copy
    }

    func textColor(_ color: UIColor) -> DGDefaultLegendConfig {
        var copy = self
        copy.textColor = color
        return copy
    }

    func font(_ font: UIFont) -> DGDefaultLegendConfig {
        var copy = self
        copy.font = font
        return copy
    }

    func form(_ form: DGChartLegendForm) -> DGDefaultLegendConfig {
        var copy = self
        copy.form = form
        return copy
    }

    func formSize(_ size: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.formSize = size
        return copy
    }

    func formToTextSpace(_ space: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.formToTextSpace = space
        return copy
    }

    func xEntrySpace(_ space: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.xEntrySpace = space
        return copy
    }

    func yEntrySpace(_ space: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.yEntrySpace = space
        return copy
    }

    func xOffset(_ offset: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.xOffset = offset
        return copy
    }

    func yOffset(_ offset: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.yOffset = offset
        return copy
    }

    func backgroundColor(_ color: UIColor?) -> DGDefaultLegendConfig {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    func borderColor(_ color: UIColor?) -> DGDefaultLegendConfig {
        var copy = self
        copy.borderColor = color
        return copy
    }

    func borderWidth(_ width: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.borderWidth = width
        return copy
    }

    func wordWrapEnabled(_ enabled: Bool) -> DGDefaultLegendConfig {
        var copy = self
        copy.wordWrapEnabled = enabled
        return copy
    }

    func maxSizePercent(_ percent: CGFloat) -> DGDefaultLegendConfig {
        var copy = self
        copy.maxSizePercent = percent
        return copy
    }
}

// MARK: - Convenience Legend Configuration

public extension DGChartLegendConfig {
    /// Create a bottom horizontal legend (default)
    static func bottom(
        alignment: DGChartLegendHorizontalAlignment = .center,
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 11)
    ) -> DGDefaultLegendConfig {
        var config = DGDefaultLegendConfig()
        config.position = .bottom
        config.horizontalAlignment = alignment
        config.verticalAlignment = .bottom
        config.orientation = .horizontal
        config.textColor = textColor
        config.font = font
        return config
    }

    /// Create a top horizontal legend
    static func top(
        alignment: DGChartLegendHorizontalAlignment = .center,
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 11)
    ) -> DGDefaultLegendConfig {
        var config = DGDefaultLegendConfig()
        config.position = .top
        config.horizontalAlignment = alignment
        config.verticalAlignment = .top
        config.orientation = .horizontal
        config.textColor = textColor
        config.font = font
        return config
    }

    /// Create a right vertical legend
    static func right(
        alignment: DGChartLegendVerticalAlignment = .center,
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 11)
    ) -> DGDefaultLegendConfig {
        var config = DGDefaultLegendConfig()
        config.position = .right
        config.horizontalAlignment = .right
        config.verticalAlignment = alignment
        config.orientation = .vertical
        config.textColor = textColor
        config.font = font
        return config
    }

    /// Create a left vertical legend
    static func left(
        alignment: DGChartLegendVerticalAlignment = .center,
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 11)
    ) -> DGDefaultLegendConfig {
        var config = DGDefaultLegendConfig()
        config.position = .left
        config.horizontalAlignment = .left
        config.verticalAlignment = alignment
        config.orientation = .vertical
        config.textColor = textColor
        config.font = font
        return config
    }

    /// Create an inside top-right legend
    static func insideTopRight(
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 11)
    ) -> DGDefaultLegendConfig {
        var config = DGDefaultLegendConfig()
        config.position = .insideTopRight
        config.horizontalAlignment = .right
        config.verticalAlignment = .top
        config.orientation = .vertical
        config.drawInside = true
        config.textColor = textColor
        config.font = font
        return config
    }

    /// Create an inside bottom-right legend
    static func insideBottomRight(
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 11)
    ) -> DGDefaultLegendConfig {
        var config = DGDefaultLegendConfig()
        config.position = .insideBottomRight
        config.horizontalAlignment = .right
        config.verticalAlignment = .bottom
        config.orientation = .vertical
        config.drawInside = true
        config.textColor = textColor
        config.font = font
        return config
    }
}

// MARK: - Legend Entry Customization

/// Custom legend entry for advanced customization
public struct DGChartLegendEntry {
    public let label: String
    public let form: DGChartLegendForm
    public let formSize: CGFloat
    public let formColor: UIColor
    public let formLineWidth: CGFloat
    public let formLineDashPattern: [CGFloat]?
    public let textColor: UIColor
    public let font: UIFont

    public init(
        label: String,
        form: DGChartLegendForm = .defaultForm,
        formSize: CGFloat = 12,
        formColor: UIColor = .systemBlue,
        formLineWidth: CGFloat = 2,
        formLineDashPattern: [CGFloat]? = nil,
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 11)
    ) {
        self.label = label
        self.form = form
        self.formSize = formSize
        self.formColor = formColor
        self.formLineWidth = formLineWidth
        self.formLineDashPattern = formLineDashPattern
        self.textColor = textColor
        self.font = font
    }
}

/// Custom legend renderer protocol
public protocol DGChartCustomLegendRenderer {
    func renderLegend(entries: [DGChartLegendEntry], in rect: CGRect, context: CGContext)
}

/// Default legend renderer
public struct DGChartDefaultLegendRenderer: DGChartCustomLegendRenderer {
    public func renderLegend(entries: [DGChartLegendEntry], in rect: CGRect, context: CGContext) {
        // Default implementation would use DGCharts built-in legend
        // This is for custom drawing if needed
    }
}