//
//  DGChartsDemo.swift
//  Meshtastic
//
//  Demo views showing how to use DGCharts SwiftUI wrappers
//

import SwiftUI
import DGCharts

// MARK: - Demo Data Models

struct DemoDataPoint: DGChartDataPoint {
    let id = UUID()
    let x: Double
    let y: Double
}

struct DemoDatePoint: DGChartDataPoint {
    let id = UUID()
    let x: Date
    let y: Double
}

struct DemoCategoryPoint: DGChartDataPoint {
    let id = UUID()
    let x: String
    let y: Double
}

// MARK: - Demo Views

/// Main demo view showing all chart types
struct DGChartsDemoView: View {
    @State private var selectedChartType = 0
    @State private var selectedPoints: [DemoDataPoint]? = nil
    @State private var selectionHighlight: Highlight? = nil

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

                if let points = selectedPoints {
                    SelectionInfoView(points: points, highlight: selectionHighlight)
                }
            }
            .navigationTitle("DGCharts Demo")
        }
    }
}

/// Line Chart Demo
struct LineChartDemo: View {
    @State var data: [DemoDataPoint] = generateLineData()
    @State var selectedPoints: [DemoDataPoint]? = nil
    @State var selectionHighlight: Highlight? = nil

    var body: some View {
        DGLineChart(
            dataSets: [
                DGLineChartDataSet(
                    label: "Sine Wave",
                    data: data,
                    color: .systemBlue,
                    lineStyle: StrokeStyle(lineWidth: 2),
                    symbol: .circle,
                    fillEnabled: false,
                    interpolationMethod: .curved
                )
            ],
            xAxisConfig: .linear(label: "X Axis", min: 0, max: 20, labelCount: 6),
            yAxisConfig: .linear(label: "Y Axis", min: -15, max: 15, labelCount: 6),
            legendConfig: .bottom(),
            scrollConfig: .default,
            animationConfig: .default,
            colorScheme: .default,
            onSelectionChange: { points, highlight in
                selectedPoints = points
                selectionHighlight = highlight
            }
        )
        .frame(height: 300)
        .padding()
    }
}

/// Bar Chart Demo
struct BarChartDemo: View {
    @State var data: [DemoCategoryPoint] = generateBarData()
    @State var selectedPoints: [DemoCategoryPoint]? = nil

    var body: some View {
        DGBarChart(
            dataSets: [
                DGBarChartDataSet(
                    label: "Monthly Sales",
                    data: data,
                    color: .systemGreen,
                    barWidth: 0.6,
                    cornerRadius: 4
                )
            ],
            xAxisConfig: .category(label: "Month", values: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]),
            yAxisConfig: .linear(label: "Sales", min: 0, max: 120, labelCount: 6),
            legendConfig: .bottom(),
            scrollConfig: .panOnly,
            animationConfig: .default,
            colorScheme: .default,
            onSelectionChange: { points, highlight in
                selectedPoints = points
            }
        )
        .frame(height: 300)
        .padding()
    }
}

/// Area Chart Demo
struct AreaChartDemo: View {
    @State var data: [DemoDataPoint] = generateAreaData()
    @State var selectedPoints: [DemoDataPoint]? = nil

    var body: some View {
        DGAreaChart(
            dataSets: [
                DGAreaChartDataSet(
                    label: "Temperature",
                    data: data,
                    color: .systemOrange,
                    fillColor: .systemOrange,
                    fillAlpha: 0.3,
                    interpolationMethod: .curved,
                    drawLine: true
                )
            ],
            xAxisConfig: .linear(label: "Time (hours)", min: 0, max: 24, labelCount: 7),
            yAxisConfig: .linear(label: "Temperature (°C)", min: 0, max: 30, labelCount: 6),
            legendConfig: .insideTopRight(),
            scrollConfig: .default,
            animationConfig: .default,
            colorScheme: .default,
            onSelectionChange: { points, highlight in
                selectedPoints = points
            }
        )
        .frame(height: 300)
        .padding()
    }
}

/// Point/Scatter Chart Demo
struct PointChartDemo: View {
    @State var data: [DemoDataPoint] = generateScatterData()
    @State var selectedPoints: [DemoDataPoint]? = nil

    var body: some View {
        DGPointChart(
            dataSets: [
                DGPointChartDataSet(
                    label: "Measurements",
                    data: data,
                    color: .systemPurple,
                    symbol: .circle,
                    symbolSize: 12,
                    symbolStrokeColor: .white,
                    symbolStrokeWidth: 2
                )
            ],
            xAxisConfig: .linear(label: "X", min: 0, max: 100, labelCount: 6),
            yAxisConfig: .linear(label: "Y", min: 0, max: 100, labelCount: 6),
            legendConfig: .bottom(),
            scrollConfig: .zoomOnly,
            animationConfig: .default,
            colorScheme: .default,
            onSelectionChange: { points, highlight in
                selectedPoints = points
            }
        )
        .frame(height: 300)
        .padding()
    }
}

/// Combined Chart Demo
struct CombinedChartDemo: View {
    @State var lineData: [DemoDataPoint] = generateLineData()
    @State var barData: [DemoCategoryPoint] = generateBarData()
    @State var scatterData: [DemoDataPoint] = generateScatterData()
    @State var selectedPoints: [Any]? = nil

    var body: some View {
        DGCombinedChart(
            dataSets: [
                // Bar data on left axis
                DGCombinedChartDataSet(
                    label: "Revenue",
                    data: barData,
                    chartType: .bar,
                    yAxisSide: .left,
                    color: .systemBlue,
                    barWidth: 0.5
                ),
                // Line data on right axis
                DGCombinedChartDataSet(
                    label: "Trend",
                    data: lineData,
                    chartType: .line,
                    yAxisSide: .right,
                    color: .systemRed,
                    lineWidth: 3,
                    symbol: .circle,
                    interpolationMethod: .curved
                ),
                // Scatter data on left axis
                DGCombinedChartDataSet(
                    label: "Samples",
                    data: scatterData.prefix(10).map { DemoDataPoint(x: $0.x * 3, y: $0.y) },
                    chartType: .scatter,
                    yAxisSide: .left,
                    color: .systemGreen,
                    symbol: .diamond,
                    symbolSize: 14
                )
            ],
            xAxisConfig: .linear(label: "X Axis", min: 0, max: 20, labelCount: 6),
            leftYAxisConfig: .linear(label: "Left Axis", min: 0, max: 120, labelCount: 6),
            rightYAxisConfig: .linear(label: "Right Axis", min: -15, max: 15, labelCount: 6),
            legendConfig: .bottom(),
            scrollConfig: .default,
            animationConfig: .default,
            colorScheme: .default,
            drawOrder: [.bar, .line, .scatter],
            onSelectionChange: { points, highlight in
                selectedPoints = points
            }
        )
        .frame(height: 300)
        .padding()
    }
}

/// Selection Info View
struct SelectionInfoView: View {
    let points: [Any]
    let highlight: Highlight?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Selected: \(points.count) point(s)")
                .font(.headline)

            if let highlight = highlight {
                Text("DataSet: \(highlight.dataSetIndex), Index: \(highlight.dataIndex)")
                Text("X: \(String(format: "%.2f", highlight.x)), Y: \(String(format: "%.2f", highlight.y))")
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Data Generators

func generateLineData() -> [DemoDataPoint] {
    (0..<20).map { i in
        DemoDataPoint(x: Double(i), y: sin(Double(i) * 0.5) * 10 + Double.random(in: -1...1))
    }
}

func generateAreaData() -> [DemoDataPoint] {
    (0..<25).map { i in
        let base = 20 + sin(Double(i) * 0.5) * 5
        let noise = Double.random(in: -1...1)
        return DemoDataPoint(x: Double(i), y: max(0, base + noise))
    }
}

func generateBarData() -> [DemoCategoryPoint] {
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun"].map {
        DemoCategoryPoint(x: $0, y: Double.random(in: 20...100))
    }
}

func generateScatterData() -> [DemoDataPoint] {
    (0..<50).map { _ in
        DemoDataPoint(x: Double.random(in: 0...100), y: Double.random(in: 0...100))
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
        .default,
        .categorical(colors: [.systemBlue, .systemGreen, .systemOrange]),
        .sequential(baseColor: .systemBlue),
        .diverging(negative: .systemRed, neutral: .systemGray, positive: .systemGreen),
        .material,
        .viridis,
        .plasma,
        .pastel
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
                                Text(["Default", "Categorical", "Sequential", "Diverging", "Material", "Viridis", "Plasma", "Pastel"][i])
                            }
                        }
                    }
                }

                // Chart with custom config
                DGLineChart(
                    dataSets: [
                        DGLineChartDataSet(
                            label: "Series 1",
                            data: generateLineData(),
                            color: colorSchemes[colorSchemeIndex].color(for: 0, total: 3),
                            lineStyle: StrokeStyle(lineWidth: 3, dash: [5, 5]),
                            symbol: .square,
                            interpolationMethod: .curved
                        ),
                        DGLineChartDataSet(
                            label: "Series 2",
                            data: generateLineData().map { DemoDataPoint(x: $0.x, y: $0.y + 5) },
                            color: colorSchemes[colorSchemeIndex].color(for: 1, total: 3),
                            lineStyle: StrokeStyle(lineWidth: 2),
                            symbol: .triangle,
                            interpolationMethod: .linear
                        ),
                        DGLineChartDataSet(
                            label: "Series 3",
                            data: generateLineData().map { DemoDataPoint(x: $0.x, y: $0.y - 5) },
                            color: colorSchemes[colorSchemeIndex].color(for: 2, total: 3),
                            lineStyle: StrokeStyle(lineWidth: 2, dash: [10, 5]),
                            symbol: .diamond,
                            interpolationMethod: .stepped
                        )
                    ],
                    xAxisConfig: .linear(label: "Time", min: 0, max: 20)
                        .labelColor(.label)
                        .labelFont(.systemFont(ofSize: 12))
                        .gridColor(showGrid ? .separator : .clear)
                        .gridWidth(0.5)
                        .labelCount(8),
                    yAxisConfig: .linear(label: "Value", min: -20, max: 20)
                        .labelColor(.label)
                        .labelFont(.systemFont(ofSize: 12))
                        .gridColor(showGrid ? .separator : .clear)
                        .gridWidth(0.5)
                        .labelCount(6),
                    legendConfig: showLegend ? .bottom().font(.systemFont(ofSize: 11)) : .bottom().enabled(false),
                    scrollConfig: DGDefaultScrollConfig()
                        .scaleXEnabled(enableZoom)
                        .scaleYEnabled(enableZoom)
                        .dragEnabled(enablePan)
                        .pinchZoomEnabled(enableZoom)
                        .doubleTapToZoomEnabled(enableZoom),
                    animationConfig: animate ? .default : DGDefaultAnimationConfig(enabled: false, duration: 0, easing: .linear),
                    colorScheme: colorSchemes[colorSchemeIndex]
                )
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