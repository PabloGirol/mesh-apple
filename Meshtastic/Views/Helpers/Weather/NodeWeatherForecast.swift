//
//  NodeWeatherForecast.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 2/25/23.
//  Updated for DGCharts iOS 15 compatibility
//

import CoreLocation
import DGCharts
import OSLog
import SwiftUI
import WeatherKit

struct NodeWeatherForecastView: View {
	var location: CLLocation

	@State private var forecast: NodeWeatherForecast = placeholderForecast

	var body: some View {
		VStack {
			chart
				.frame(width: 400)
		}
		.padding(10)
		.background()
		.task {
			do {
				let weather = try await WeatherService.shared.weather(for: location, including: .hourly).forecast
				let locale = NSLocale.current as NSLocale
				let localeUnit = locale.object(forKey: NSLocale.Key(rawValue: "kCFLocaleTemperatureUnitKey"))
				let targetUnit: UnitTemperature = (localeUnit as? String) == "Fahrenheit" ? .fahrenheit : .celsius
				forecast = NodeWeatherForecast(entries: weather.map {
					.init(
						date: $0.date,
						degrees: $0.temperature.converted(to: targetUnit).value,
						isDaylight: $0.isDaylight
					)
				})
			} catch {
				Logger.services.error("Could not load weather: \(error.localizedDescription, privacy: .public)")
			}
		}
	}

	@ViewBuilder
	var chart: some View {
		// Build chart data points
		let points = forecast.entries.map { entry in
			ChartDataPoint.fromDate(entry.date, value: entry.degrees)
		}

		let lowPoints = forecast.entries.map { entry in
			ChartDataPoint.fromDate(entry.date, value: forecast.low)
		}

		let seriesData = ChartSeriesData(
			id: "temperature",
			name: "Temperature",
			color: .teal,
			chartType: .area,
			points: points,
			lineWidth: 2.0,
			drawFilled: true,
			fillAlpha: 0.3,
			fillColor: .yellow
		)

		let lowSeries = ChartSeriesData(
			id: "low",
			name: "Low",
			color: .clear,
			chartType: .line,
			points: lowPoints,
			lineWidth: 0,
			isVisible: false
		)

		// Build rule marks for night time ranges
		var ruleMarks: [DGRuleMark] = []
		for range in forecast.nightTimeRanges {
			// Add vertical rule marks for night boundaries
			if range.lowerBound != forecast.entries.first?.date {
				ruleMarks.append(DGRuleMark(
					position: range.lowerBound.timeIntervalSince1970,
					axis: .x,
					color: .indigo,
					lineWidth: 1.0,
					dashPattern: [4, 4]
				))
			}
			if range.upperBound != forecast.entries.last?.date {
				ruleMarks.append(DGRuleMark(
					position: range.upperBound.timeIntervalSince1970,
					axis: .x,
					color: .indigo,
					lineWidth: 1.0,
					dashPattern: [4, 4]
				))
			}
		}

		let xAxisConfig = DGChartXAxisConfig(
			position: .bottom,
			labelCount: 8,
			dateFormat: "HH:mm",
			dateFormatter: {
				let formatter = DateFormatter()
				formatter.dateFormat = "HH:mm"
				return formatter
			}()
		)

		let yAxisConfig = DGChartYAxisConfig(
			position: .left,
			labelCount: 6,
			axisMinimum: nil,
			axisMaximum: nil,
			axisValueFormatter: { value, _ in
				return "\(Int(value))°"
			}
		)

		let legendConfig = DGChartLegendConfig(
			isEnabled: false
		)

		return LineChartView(
			data: [seriesData, lowSeries],
			xAxisConfig: xAxisConfig,
			yAxisConfig: yAxisConfig,
			legendConfig: legendConfig,
			ruleMarks: ruleMarks,
			yDomain: nil,
			visibleXRange: nil,
			scrollPosition: nil,
			isScrollable: false,
			legendHidden: true,
			frame: nil,
			selection: nil,
			onSelectionChanged: nil,
			backgroundColor: .systemBackground,
			gridColor: .systemGray4,
			gridLineWidth: 0.5,
			drawCircles: false,
			circleRadius: 4.0,
			mode: .cubicBezier,
			cubicIntensity: 0.2,
			drawFilled: true,
			fillAlpha: 0.3
		)
	}

	static var placeholderForecast: NodeWeatherForecast {
		func entry(hourOffset: Int, degrees: Double, isDaylight: Bool) -> NodeWeatherForecast.WeatherEntry {
			let startDate = Calendar.current.date(from: DateComponents(year: 2022, month: 5, day: 6, hour: 9))!
			let date = Calendar.current.date(byAdding: DateComponents(hour: hourOffset), to: startDate)!
			return NodeWeatherForecast.WeatherEntry(date: date, degrees: degrees, isDaylight: isDaylight)
		}

		return NodeWeatherForecast(entries: [
			entry(hourOffset: 0, degrees: 63, isDaylight: true),
			entry(hourOffset: 1, degrees: 68, isDaylight: true),
			entry(hourOffset: 2, degrees: 72, isDaylight: true),
			entry(hourOffset: 3, degrees: 77, isDaylight: true),
			entry(hourOffset: 4, degrees: 80, isDaylight: true),
			entry(hourOffset: 5, degrees: 82, isDaylight: true),
			entry(hourOffset: 6, degrees: 83, isDaylight: true),
			entry(hourOffset: 7, degrees: 83, isDaylight: true),
			entry(hourOffset: 8, degrees: 81, isDaylight: true),
			entry(hourOffset: 9, degrees: 79, isDaylight: true),
			entry(hourOffset: 10, degrees: 75, isDaylight: true),
			entry(hourOffset: 11, degrees: 70, isDaylight: true),
			entry(hourOffset: 12, degrees: 66, isDaylight: false),
			entry(hourOffset: 13, degrees: 64, isDaylight: false),
			entry(hourOffset: 14, degrees: 63, isDaylight: false),
			entry(hourOffset: 15, degrees: 61, isDaylight: false),
			entry(hourOffset: 16, degrees: 60, isDaylight: false),
			entry(hourOffset: 17, degrees: 59, isDaylight: false),
			entry(hourOffset: 18, degrees: 57, isDaylight: false),
			entry(hourOffset: 19, degrees: 56, isDaylight: false),
			entry(hourOffset: 20, degrees: 55, isDaylight: false),
			entry(hourOffset: 21, degrees: 55, isDaylight: true),
			entry(hourOffset: 22, degrees: 56, isDaylight: true),
			entry(hourOffset: 23, degrees: 59, isDaylight: true),
			entry(hourOffset: 24, degrees: 62, isDaylight: true)
		])
	}
}

struct NodeWeatherForecast {
	struct WeatherEntry: Identifiable {
		var id: Date { date }
		var date: Date
		var degrees: Double
		var isDaylight: Bool
	}

	var entries: [WeatherEntry]

	var low: Double {
		return (entries.map(\.degrees).min() ?? 0) - 2
	}

	var hottestEntry: WeatherEntry {
		return entries.sorted { $0.degrees > $1.degrees }.first ?? entries[0]
	}

	var nightTimeRanges: [Range<Date>] {
		var currentLowerBound: Date?
		var results: [Range<Date>] = []
		for entry in entries {
			if entry.isDaylight, let lowerBound = currentLowerBound {
				results.append(lowerBound..<entry.date)
				currentLowerBound = nil
			} else if !entry.isDaylight && currentLowerBound == nil {
				currentLowerBound = entry.date
			}
		}
		if let lowerBound = currentLowerBound {
			results.append(lowerBound..<entries.last!.date)
		}
		return results
	}

	var binRange: ClosedRange<Date> {
		let startDate: Date = entries.map(\.date).first(where: {
			Calendar.current.component(.hour, from: $0).isMultiple(of: 3)
		})!
		let endDate: Date = entries.map(\.date).reversed().first(where: {
			Calendar.current.component(.hour, from: $0).isMultiple(of: 3)
		})!
		return startDate ... endDate
	}

	func temperature(at date: Date) -> Double {
		entries.first(where: { $0.date == date })!.degrees
	}
}

struct NodeWeatherForecastView_Previews: PreviewProvider {
	static var previews: some View {
		if let cl = LocationsHandler.currentLocation {
			NodeWeatherForecastView(location: CLLocation(latitude: cl.latitude, longitude: cl.longitude) )
				.aspectRatio(2, contentMode: .fit)
				.padding()
				.previewLayout(.sizeThatFits)
		}
	}
}