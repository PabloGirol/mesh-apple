//
//  DGChartsDemo.swift
//  Meshtastic
//
//  Demo views showing how to use DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Demo Views

/// Main demo view showing all chart types
struct DGChartsDemoView: View {
    @State private var selectedChartType = 0

    let chartTypes = ["Line", "Bar", "Area", "Point", "Combined"]

    var body: some View {
        NavigationView {
            VStack {
                Picker("Chart Type", selection: $selectedChartType) {
                    ForEach(0..<chartTypes.count, id: \.self) { index in
                        Text(chartTypes[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Group {
                    switch selectedChartType {
                    case 0: LineChartDemo()
                    case 1: BarChartDemo()
                    case 2: AreaChartDemo()
                    case 3: PointChartDemo()
                    case 4: CombinedChartDemo()
                    default: LineChartDemo()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedChartType)
            }
            .navigationTitle("DGCharts Demo")
        }
    }
}

/// Line Chart Demo
struct LineChartDemo: View {
    @State private var chart: DGLineChartView = {
        let chart = DGLineChartView()
        let points = (0..<20).map { i in
            DGLineChartPoint(x: Double(i), y: sin(Double(i) * 0.5) * 10 + Double.random(in: -1...1))
        }
        chart.series = [DGChartSeries(
            id: "sine",
            name: "Sine Wave",
            abbreviatedName: "Sin",
            color: .blue,
            isVisible: true,
            chartType: .line,
            lineWidth: 2.0
        )]
        chart.seriesData = ["sine": points]
        chart.drawCircles = false
        chart.mode = .linear
        return chart
    }()

    var body: some View {
        chart
            .frame(height: 300)
            .padding()
    }
}

/// Bar Chart Demo
struct BarChartDemo: View {
    @State private var chart: DGBarChartView = {
        let chart = DGBarChartView()
        let points = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"].enumerated().map { index, _ in
            DGBarChartPoint(x: Double(index), y: Double.random(in: 20...100))
        }
        chart.series = [DGChartSeries(
            id: "sales",
            name: "Monthly Sales",
            abbreviatedName: "Sales",
            color: .green,
            isVisible: true,
            chartType: .bar,
            lineWidth: 0
        )]
        chart.seriesData = ["sales": points]
        chart.barWidth = 0.6
        return chart
    }()

    var body: some View {
        chart
            .frame(height: 300)
            .padding()
    }
}

/// Area Chart Demo
struct AreaChartDemo: View {
    @State private var chart: DGCombinedChartView = {
        let chart = DGCombinedChartView()
        let points = (0..<25).map { i in
            let base = 20 + sin(Double(i) * 0.5) * 5
            let noise = Double.random(in: -1...1)
            return DGLineChartPoint(x: Double(i), y: max(0, base + noise))
        }
        chart.series = [DGChartSeries(
            id: "temp",
            name: "Temperature",
            abbreviatedName: "Temp",
            color: .orange,
            isVisible: true,
            chartType: .area,
            lineWidth: 2.0,
            fillColor: .orange,
            fillAlpha: 0.3
        )]
        chart.seriesData = ["temp": points.map { DGCombinedChartPoint(x: $0.x, y: $0.y, label: $0.label, type: .area) }]
        chart.mode = .linear
        return chart
    }()

    var body: some View {
        chart
            .frame(height: 300)
            .padding()
    }
}

/// Point/Scatter Chart Demo
struct PointChartDemo: View {
    @State private var chart: DGScatterChartView = {
        let chart = DGScatterChartView()
        let points = (0..<50).map { _ in
            DGLineChartPoint(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
        }
        chart.series = [DGChartSeries(
            id: "measurements",
            name: "Measurements",
            abbreviatedName: "Meas",
            color: .purple,
            isVisible: true,
            chartType: .line,
            lineWidth: 0
        )]
        chart.seriesData = ["measurements": points]
        chart.scatterShape = .circle
        chart.scatterShapeSize = 12.0
        chart.drawValuesEnabled = false
        return chart
    }()

    var body: some View {
        chart
            .frame(height: 300)
            .padding()
    }
}

/// Combined Chart Demo
struct CombinedChartDemo: View {
    @State private var chart: DGCombinedChartView = {
        let chart = DGCombinedChartView()

        let linePoints = (0..<20).map { i in
            DGLineChartPoint(x: Double(i), y: sin(Double(i) * 0.5) * 10 + Double.random(in: -1...1))
        }
        let barPoints = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"].enumerated().map { index, _ in
            DGBarChartPoint(x: Double(index), y: Double.random(in: 20...100))
        }
        let scatterPoints = (0..<10).map { _ in
            DGLineChartPoint(x: Double.random(in: 0...20), y: Double.random(in: -10...10))
        }

        chart.series = [
            DGChartSeries(
                id: "revenue",
                name: "Revenue",
                abbreviatedName: "Rev",
                color: .blue,
                isVisible: true,
                chartType: .bar,
                lineWidth: 0
            ),
            DGChartSeries(
                id: "trend",
                name: "Trend",
                abbreviatedName: "Trend",
                color: .red,
                isVisible: true,
                chartType: .line,
                lineWidth: 3.0
            ),
            DGChartSeries(
                id: "samples",
                name: "Samples",
                abbreviatedName: "Samp",
                color: .green,
                isVisible: true,
                chartType: .line,
                lineWidth: 0
            )
        ]

        chart.seriesData = [
            "revenue": barPoints.map { DGCombinedChartPoint(x: $0.x, y: $0.y, label: $0.label, type: .bar) },
            "trend": linePoints.map { DGCombinedChartPoint(x: $0.x, y: $0.y, label: $0.label, type: .line) },
            "samples": scatterPoints.map { DGCombinedChartPoint(x: $0.x, y: $0.y, label: $0.label, type: .line) }
        ]

        chart.barWidth = 0.5
        chart.mode = .linear
        chart.drawCircles = true
        chart.circleRadius = 4.0

        return chart
    }()

    var body: some View {
        chart
            .frame(height: 300)
            .padding()
    }
}

// MARK: - Data Generators

func generateLinePoints() -> [DGLineChartPoint] {
    (0..<20).map { i in
        DGLineChartPoint(x: Double(i), y: sin(Double(i) * 0.5) * 10 + Double.random(in: -1...1))
    }
}

func generateAreaPoints() -> [DGLineChartPoint] {
    (0..<25).map { i in
        let base = 20 + sin(Double(i) * 0.5) * 5
        let noise = Double.random(in: -1...1)
        return DGLineChartPoint(x: Double(i), y: max(0, base + noise))
    }
}

func generateBarPoints() -> [DGBarChartPoint] {
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun"].enumerated().map { index, _ in
        DGBarChartPoint(x: Double(index), y: Double.random(in: 20...100))
    }
}

func generateScatterPoints() -> [DGLineChartPoint] {
    (0..<50).map { _ in
        DGLineChartPoint(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
    }
}

// MARK: - Advanced Demo

/// Advanced demo showing customization options
struct AdvancedDGChartsDemo: View {
    @State var animate = false
    @State var colorSchemeIndex = 0
    @State var showLegend = true
    @State var showGrid = true
    @State var enableZoom = true
    @State var enablePan = true

    let colorSchemes: [DGChartColorScheme] = [
        DGDefaultColorScheme(),
        DGCategoricalColorScheme(colors: [.systemBlue, .systemGreen, .systemOrange]),
        DGSequentialColorScheme(baseColor: .systemBlue, steps: 12, lightnessRange: 0.3...0.9),
        DGDivergingColorScheme(negative: .systemRed, neutral: .systemGray, positive: .systemGreen)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Controls
                GroupBox("Controls") {
                    VStack(spacing: 12) {
                        Toggle("Animate", isOn: $animate)
                        Toggle("Show Legend", isOn: $showLegend)
                        Toggle("Show Grid", isOn: $showGrid)
                        Toggle("Enable Zoom", isOn: $enableZoom)
                        Toggle("Enable Pan", isOn: $enablePan)

                        Picker("Color Scheme", selection: $colorSchemeIndex) {
                            ForEach(0..<colorSchemes.count, id: \.self) { i in
                                Text(["Default", "Categorical", "Sequential", "Diverging"][i])
                            }
                        }
                    }
                }

                // Chart with custom config
                let lineChart: DGLineChartView = {
                    let chart = DGLineChartView()
                    let points = generateLinePoints()
                    let points2 = points.map { DGLineChartPoint(x: $0.x, y: $0.y + 5) }
                    let points3 = points.map { DGLineChartPoint(x: $0.x, y: $0.y - 5) }

                    chart.series = [
                        DGChartSeries(
                            id: "series1",
                            name: "Series 1",
                            abbreviatedName: "S1",
                            color: colorSchemes[colorSchemeIndex].color(for: 0, total: 3),
                            isVisible: true,
                            chartType: .line,
                            lineWidth: 3.0,
                            dashPattern: [5, 5]
                        ),
                        DGChartSeries(
                            id: "series2",
                            name: "Series 2",
                            abbreviatedName: "S2",
                            color: colorSchemes[colorSchemeIndex].color(for: 1, total: 3),
                            isVisible: true,
                            chartType: .line,
                            lineWidth: 2.0
                        ),
                        DGChartSeries(
                            id: "series3",
                            name: "Series 3",
                            abbreviatedName: "S3",
                            color: colorSchemes[colorSchemeIndex].color(for: 2, total: 3),
                            isVisible: true,
                            chartType: .line,
                            lineWidth: 2.0,
                            dashPattern: [10, 5]
                        )
                    ]

                    chart.seriesData = [
                        "series1": points,
                        "series2": points2,
                        "series3": points3
                    ]

                    chart.drawCircles = true
                    chart.circleRadius = 4.0
                    chart.mode = .linear
                    chart.xAxisConfig = DGChartXAxisConfig(
                        position: .bottom,
                        labelCount: 8,
                        labelRotation: 0,
                        dateFormat: nil,
                        customFormatter: nil,
                        granularity: 1.0,
                        granularityEnabled: false
                    )
                    chart.yAxisConfig = DGChartYAxisConfig(
                        position: .left,
                        labelCount: 6,
                        axisMinimum: -20,
                        axisMaximum: 20,
                        granularity: 1.0,
                        granularityEnabled: false,
                        customFormatter: nil
                    )
                    chart.legendConfig = DGChartLegendConfig(
                        isEnabled: showLegend,
                        position: .belowChartCenter,
                        alignment: .center,
                        orientation: .horizontal,
                        font: .systemFont(ofSize: 11),
                        textColor: .label
                    )
                    chart.gridColor = showGrid ? .separator : .clear
                    chart.gridLineWidth = 0.5
                    chart.pinchZoomEnabled = enableZoom
                    chart.doubleTapToZoomEnabled = enableZoom
                    chart.dragEnabled = enablePan
                    chart.scaleXEnabled = enableZoom
                    chart.scaleYEnabled = enableZoom
                    chart.animateOnAppear = animate
                    chart.animationDuration = animate ? 1.0 : 0

                    return chart
                }()

                lineChart
                    .frame(height: 300)
            }
            .padding()
        }
        .navigationTitle("Advanced Demo")
    }
}

// MARK: - Preview

#if DEBUG
struct DGChartsDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DGChartsDemoView()
    }
}
#endif