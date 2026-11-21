//
//  DGChartColor.swift
//  Meshtastic
//
//  Color and gradient mapping for DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Color Scheme Protocol

/// Protocol for chart color schemes
public protocol DGChartColorScheme {
    func color(for index: Int, total: Int) -> UIColor
    func gradient(for index: Int, total: Int) -> CGGradient?
}

// MARK: - Default Color Schemes

/// Default system color scheme
public struct DGDefaultColorScheme: DGChartColorScheme {
    private let colors: [UIColor] = [
        .systemBlue, .systemGreen, .systemOrange, .systemRed,
        .systemPurple, .systemPink, .systemTeal, .systemIndigo,
        .systemYellow, .systemBrown, .systemCyan, .systemMint
    ]

    public init() {}

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

/// Categorical color scheme with custom colors
public struct DGCategoricalColorScheme: DGChartColorScheme {
    private let colors: [UIColor]

    public init(colors: [UIColor]) {
        self.colors = colors.isEmpty ? DGDefaultColorScheme().colors : colors
    }

    public init(colors: [Color]) {
        self.colors = colors.map { UIColor($0) }
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

/// Sequential color scheme (single hue, varying lightness)
public struct DGSequentialColorScheme: DGChartColorScheme {
    private let baseColor: UIColor
    private let steps: Int
    private let lightnessRange: ClosedRange<CGFloat>

    public init(
        baseColor: UIColor = .systemBlue,
        steps: Int = 12,
        lightnessRange: ClosedRange<CGFloat> = 0.3...0.9
    ) {
        self.baseColor = baseColor
        self.steps = max(steps, 1)
        self.lightnessRange = lightnessRange
    }

    public init(
        baseColor: Color,
        steps: Int = 12,
        lightnessRange: ClosedRange<CGFloat> = 0.3...0.9
    ) {
        self.baseColor = UIColor(baseColor)
        self.steps = max(steps, 1)
        self.lightnessRange = lightnessRange
    }

    public func color(for index: Int, total: Int) -> UIColor {
        let clampedIndex = min(max(index, 0), steps - 1)
        let progress = CGFloat(clampedIndex) / CGFloat(max(steps - 1, 1))
        let lightness = lightnessRange.lowerBound + (lightnessRange.upperBound - lightnessRange.lowerBound) * progress
        return adjustLightness(baseColor, lightness: lightness)
    }

    public func gradient(for index: Int, total: Int) -> CGGradient? {
        let color = self.color(for: index, total: total)
        let colors = [color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0.1).cgColor]
        let locations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)
    }

    private func adjustLightness(_ color: UIColor, lightness: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: lightness, alpha: a)
    }
}

/// Diverging color scheme (two hues with neutral center)
public struct DGDivergingColorScheme: DGChartColorScheme {
    private let negativeColor: UIColor
    private let neutralColor: UIColor
    private let positiveColor: UIColor
    private let steps: Int

    public init(
        negative: UIColor = .systemRed,
        neutral: UIColor = .systemGray,
        positive: UIColor = .systemGreen,
        steps: Int = 11 // Odd number for neutral center
    ) {
        self.negativeColor = negative
        self.neutralColor = neutral
        self.positiveColor = positive
        self.steps = steps
    }

    public init(
        negative: Color = .red,
        neutral: Color = .gray,
        positive: Color = .green,
        steps: Int = 11
    ) {
        self.negativeColor = UIColor(negative)
        self.neutralColor = UIColor(neutral)
        self.positiveColor = UIColor(positive)
        self.steps = steps
    }

    public func color(for index: Int, total: Int) -> UIColor {
        // Map index to diverging scale
        let normalizedIndex = total > 1 ? CGFloat(index) / CGFloat(total - 1) : 0.5
        let clampedIndex = min(max(normalizedIndex, 0), 1)

        if clampedIndex < 0.5 {
            // Negative to neutral
            let progress = clampedIndex * 2
            return interpolate(from: negativeColor, to: neutralColor, progress: progress)
        } else if clampedIndex > 0.5 {
            // Neutral to positive
            let progress = (clampedIndex - 0.5) * 2
            return interpolate(from: neutralColor, to: positiveColor, progress: progress)
        } else {
            return neutralColor
        }
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

/// Semantic color scheme for data visualization
public struct DGSemanticColorScheme: DGChartColorScheme {
    public enum SemanticColor {
        case primary
        case secondary
        case success
        case warning
        case danger
        case info
        case neutral
    }

    private let colors: [SemanticColor: UIColor]

    public init(
        primary: UIColor = .systemBlue,
        secondary: UIColor = .systemGray,
        success: UIColor = .systemGreen,
        warning: UIColor = .systemOrange,
        danger: UIColor = .systemRed,
        info: UIColor = .systemTeal,
        neutral: UIColor = .systemGray2
    ) {
        self.colors = [
            .primary: primary,
            .secondary: secondary,
            .success: success,
            .warning: warning,
            .danger: danger,
            .info: info,
            .neutral: neutral
        ]
    }

    public func color(for index: Int, total: Int) -> UIColor {
        let semanticColors: [SemanticColor] = [.primary, .secondary, .success, .warning, .danger, .info, .neutral]
        return colors[semanticColors[index % semanticColors.count]] ?? .systemBlue
    }

    public func gradient(for index: Int, total: Int) -> CGGradient? {
        let color = self.color(for: index, total: total)
        let colors = [color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0.1).cgColor]
        let locations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)
    }

    public func color(for semantic: SemanticColor) -> UIColor {
        colors[semantic] ?? .systemBlue
    }
}

// MARK: - Gradient Builders

/// Linear gradient builder
public struct DGChartLinearGradient {
    public let colors: [UIColor]
    public let startPoint: CGPoint
    public let endPoint: CGPoint
    public let locations: [CGFloat]?

    public init(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1),
        locations: [CGFloat]? = nil
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.locations = locations
    }

    public init(
        colors: [Color],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1),
        locations: [CGFloat]? = nil
    ) {
        self.colors = colors.map { UIColor($0) }
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.locations = locations
    }

    public func cgGradient() -> CGGradient? {
        let cgColors = colors.map { $0.cgColor }
        return CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: cgColors as CFArray,
            locations: locations
        )
    }
}

/// Radial gradient builder
public struct DGChartRadialGradient {
    public let colors: [UIColor]
    public let center: CGPoint
    public let radius: CGFloat
    public let locations: [CGFloat]?

    public init(
        colors: [UIColor],
        center: CGPoint = CGPoint(x: 0.5, y: 0.5),
        radius: CGFloat = 0.5,
        locations: [CGFloat]? = nil
    ) {
        self.colors = colors
        self.center = center
        self.radius = radius
        self.locations = locations
    }

    public init(
        colors: [Color],
        center: CGPoint = CGPoint(x: 0.5, y: 0.5),
        radius: CGFloat = 0.5,
        locations: [CGFloat]? = nil
    ) {
        self.colors = colors.map { UIColor($0) }
        self.center = center
        self.radius = radius
        self.locations = locations
    }

    public func cgGradient() -> CGGradient? {
        let cgColors = colors.map { $0.cgColor }
        return CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: cgColors as CFArray,
            locations: locations
        )
    }
}

// MARK: - Foreground Style Mapping

/// Maps SwiftUI foregroundStyle to DGCharts colors
public struct DGChartForegroundStyle {
    public let color: UIColor?
    public let gradient: CGGradient?
    public let pattern: CGPattern?

    public init(color: UIColor) {
        self.color = color
        self.gradient = nil
        self.pattern = nil
    }

    public init(gradient: CGGradient) {
        self.color = nil
        self.gradient = gradient
        self.pattern = nil
    }

    public init(pattern: CGPattern) {
        self.color = nil
        self.gradient = nil
        self.pattern = pattern
    }

    public static func color(_ color: UIColor) -> DGChartForegroundStyle {
        DGChartForegroundStyle(color: color)
    }

    public static func color(_ color: Color) -> DGChartForegroundStyle {
        DGChartForegroundStyle(color: UIColor(color))
    }

    public static func gradient(_ gradient: DGChartLinearGradient) -> DGChartForegroundStyle {
        DGChartForegroundStyle(gradient: gradient.cgGradient()!)
    }

    public static func gradient(_ gradient: DGChartRadialGradient) -> DGChartForegroundStyle {
        DGChartForegroundStyle(gradient: gradient.cgGradient()!)
    }

    public static func linearGradient(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    ) -> DGChartForegroundStyle {
        DGChartForegroundStyle(gradient: DGChartLinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint).cgGradient()!)
    }
}

// MARK: - Color Mapping Utilities

public extension DGChartColorScheme {
    /// Generate colors for a data series
    func colorsForSeries(count: Int) -> [UIColor] {
        (0..<count).map { color(for: $0, total: count) }
    }

    /// Generate gradients for a data series
    func gradientsForSeries(count: Int) -> [CGGradient?] {
        (0..<count).map { gradient(for: $0, total: count) }
    }
}

/// Color palette for common use cases
public struct DGChartColorPalette {
    public static let material = DGCategoricalColorScheme(colors: [
        UIColor(red: 0.25, green: 0.51, blue: 0.96, alpha: 1), // Blue 500
        UIColor(red: 0.00, green: 0.69, blue: 0.42, alpha: 1), // Green 500
        UIColor(red: 1.00, green: 0.60, blue: 0.00, alpha: 1), // Orange 500
        UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1), // Red 500
        UIColor(red: 0.61, green: 0.15, blue: 0.69, alpha: 1), // Purple 500
        UIColor(red: 0.91, green: 0.12, blue: 0.39, alpha: 1), // Pink 500
        UIColor(red: 0.00, green: 0.68, blue: 0.67, alpha: 1), // Teal 500
        UIColor(red: 0.36, green: 0.42, blue: 0.82, alpha: 1), // Indigo 500
    ])

    public static let viridis = DGCategoricalColorScheme(colors: [
        UIColor(red: 0.27, green: 0.00, blue: 0.53, alpha: 1),
        UIColor(red: 0.45, green: 0.12, blue: 0.68, alpha: 1),
        UIColor(red: 0.59, green: 0.23, blue: 0.74, alpha: 1),
        UIColor(red: 0.71, green: 0.35, blue: 0.75, alpha: 1),
        UIColor(red: 0.82, green: 0.47, blue: 0.70, alpha: 1),
        UIColor(red: 0.91, green: 0.60, blue: 0.59, alpha: 1),
        UIColor(red: 0.98, green: 0.74, blue: 0.43, alpha: 1),
        UIColor(red: 0.99, green: 0.91, blue: 0.14, alpha: 1),
    ])

    public static let plasma = DGCategoricalColorScheme(colors: [
        UIColor(red: 0.05, green: 0.03, blue: 0.35, alpha: 1),
        UIColor(red: 0.32, green: 0.07, blue: 0.54, alpha: 1),
        UIColor(red: 0.54, green: 0.10, blue: 0.59, alpha: 1),
        UIColor(red: 0.73, green: 0.18, blue: 0.54, alpha: 1),
        UIColor(red: 0.88, green: 0.34, blue: 0.40, alpha: 1),
        UIColor(red: 0.97, green: 0.57, blue: 0.22, alpha: 1),
        UIColor(red: 0.98, green: 0.83, blue: 0.15, alpha: 1),
        UIColor(red: 0.94, green: 1.00, blue: 0.22, alpha: 1),
    ])

    public static let categorical = DGCategoricalColorScheme(colors: [
        .systemBlue, .systemGreen, .systemOrange, .systemRed,
        .systemPurple, .systemPink, .systemTeal, .systemIndigo,
        .systemYellow, .systemBrown, .systemCyan, .systemMint
    ])

    public static let pastel = DGCategoricalColorScheme(colors: [
        UIColor(red: 0.67, green: 0.84, blue: 0.95, alpha: 1),
        UIColor(red: 0.69, green: 0.87, blue: 0.69, alpha: 1),
        UIColor(red: 0.98, green: 0.81, blue: 0.55, alpha: 1),
        UIColor(red: 0.96, green: 0.65, blue: 0.65, alpha: 1),
        UIColor(red: 0.85, green: 0.69, blue: 0.87, alpha: 1),
        UIColor(red: 0.95, green: 0.73, blue: 0.80, alpha: 1),
        UIColor(red: 0.65, green: 0.87, blue: 0.85, alpha: 1),
        UIColor(red: 0.73, blue: 0.76, green: 0.92, alpha: 1),
    ])

    public static let dark = DGCategoricalColorScheme(colors: [
        UIColor(red: 0.30, green: 0.55, blue: 1.00, alpha: 1),
        UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1),
        UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1),
        UIColor(red: 1.00, green: 0.23, blue: 0.19, alpha: 1),
        UIColor(red: 0.70, green: 0.20, blue: 0.80, alpha: 1),
        UIColor(red: 1.00, green: 0.18, blue: 0.40, alpha: 1),
        UIColor(red: 0.00, green: 0.78, blue: 0.78, alpha: 1),
        UIColor(red: 0.45, green: 0.50, blue: 0.95, alpha: 1),
    ])
}

// MARK: - SwiftUI Color Extensions

public extension Color {
    func toUIColor() -> UIColor { UIColor(self) }

    func toCGColor() -> CGColor { self.toUIColor().cgColor }
}

public extension UIColor {
    func toColor() -> Color { Color(self) }

    func withAlpha(_ alpha: CGFloat) -> UIColor {
        self.withAlphaComponent(alpha)
    }

    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: min(b + percentage, 1.0), alpha: a)
    }

    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: max(b - percentage, 0.0), alpha: a)
    }
}