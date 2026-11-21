//
//  EnvironmentDefaultSeries.swift
//  Meshtastic
//
//  Created by Jake Bordens on 12/11/24.
//  Updated for DGCharts iOS 15 compatibility
//

import Foundation
import SwiftUI

// This is the default configuration used by the EnvironmentMetricsLog view for the chart
extension MetricsSeriesList {
	static var environmentDefaultChartSeries: MetricsSeriesList {
		MetricsSeriesList(persistenceKey: "environment", series: [
			// Temperature Series Configuration
			MetricsChartSeries(
				id: "temperature",
				keyPath: \.temperature,
				name: "Temperature",
				abbreviatedName: "Temp",
				unit: "°",
				minimumYAxisSpan: 50.0,
				chartType: .combinedLineArea,
				conversion: { t in t.map { Float($0.localeTemperature()) } },
				foregroundStyle: { chartRange in
					let locale = NSLocale.current as NSLocale
					let localeUnit = locale.object(forKey: NSLocale.Key(rawValue: "kCFLocaleTemperatureUnitKey"))
					let format: UnitTemperature = (localeUnit as? String) == "Fahrenheit" ? .fahrenheit : .celsius
					let lowerBound = chartRange.map { Double($0.lowerBound) } ?? 0.0
					let upperBound = chartRange.map { Double($0.upperBound) } ?? 100.0
					let stops: [Gradient.Stop] = generateStops(minTemp: lowerBound, maxTemp: upperBound, tempUnit: format, opacity: 1.0)
					return LinearGradient(stops: stops, startPoint: .bottom, endPoint: .top)
				},
				valueExtractor: { entity in
					entity.temperature.map { Float($0.localeTemperature()) }
				}
			),

			// Relative Humidity Series Configuration
			MetricsChartSeries(
				id: "relativeHumidity",
				keyPath: \.relativeHumidity,
				name: "Relative Humidity",
				abbreviatedName: "Hum",
				unit: "%",
				initialYAxisRange: 0.0...100.0,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.purple.darker(componentDelta: 0.2)), .purple],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.relativeHumidity
				}
			),

			MetricsChartSeries(
				id: "dewPoint",
				keyPath: \.dewPoint,
				name: "Dew Point",
				abbreviatedName: "Dew",
				unit: "°",
				minimumYAxisSpan: 50.0,
				chartType: .line,
				lineWidth: 2.0,
				dashPattern: [2, 2],
				conversion: { t in t.map { Float($0.localeTemperature()) } },
				foregroundStyle: { chartRange in
					let locale = NSLocale.current as NSLocale
					let localeUnit = locale.object(forKey: NSLocale.Key(rawValue: "kCFLocaleTemperatureUnitKey"))
					let format: UnitTemperature = (localeUnit as? String) == "Fahrenheit" ? .fahrenheit : .celsius
					let lowerBound = chartRange.map { Double($0.lowerBound) } ?? 0.0
					let upperBound = chartRange.map { Double($0.upperBound) } ?? 100.0
					let stops: [Gradient.Stop] = generateStops(minTemp: lowerBound, maxTemp: upperBound, tempUnit: format, opacity: 1.0)
					return LinearGradient(stops: stops, startPoint: .bottom, endPoint: .top)
				},
				valueExtractor: { entity in
					entity.dewPoint.map { Float($0.localeTemperature()) }
				}
			),

			// Barometric Pressure Series Configuration
			MetricsChartSeries(
				id: "barometricPressure",
				keyPath: \.barometricPressure,
				name: "Barometric Pressure",
				abbreviatedName: "Bar",
				unit: "hPa",
				// Anchor the axis to the typical sea-level range (~950–1050 hPa) instead of
				// autoscaling tightly with the other environment series, so the absolute level is
				// readable and small real changes stay visible. Expands if readings fall outside
				// (e.g. high-altitude stations). Per meshtastic/design#53 / Meshtastic-Apple#2046.
				initialYAxisRange: 950.0...1050.0,
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.green.darker(componentDelta: 0.3)), .green],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.barometricPressure
				}
			),

			// Indoor Air Quality Series Configuration
			MetricsChartSeries(
				id: "iaq",
				keyPath: \.iaq,
				name: "Indoor Air Quality",
				abbreviatedName: "IAQ",
				visible: false,
				chartType: .point,
				foregroundStyle: { _ in .gray },
				valueExtractor: { entity in
					entity.iaq
				}
			),

			// Lux
			MetricsChartSeries(
				id: "lux",
				keyPath: \.lux,
				name: "Lux",
				abbreviatedName: "Lux",
				unit: "lx",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.cyan.lighter(componentDelta: 0.3)), .cyan],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.lux
				}
			),

			// White Lux
			MetricsChartSeries(
				id: "whiteLux",
				keyPath: \.whiteLux,
				name: "White Lux",
				abbreviatedName: "White",
				unit: "lx",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.cyan.lighter(componentDelta: 0.5)), Color(UIColor.cyan.lighter(componentDelta: 0.2))],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.whiteLux
				}
			),

			// UV Lux
			MetricsChartSeries(
				id: "uvLux",
				keyPath: \.uvLux,
				name: "UV Lux",
				abbreviatedName: "UV",
				unit: "lx",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.systemIndigo.lighter(componentDelta: 0.4)), Color(UIColor.systemIndigo.lighter(componentDelta: 0.2))],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.uvLux
				}
			),

			// IR Lux
			MetricsChartSeries(
				id: "irLux",
				keyPath: \.irLux,
				name: "IR Lux",
				abbreviatedName: "IR",
				unit: "lx",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.red.darker(componentDelta: 0.5)), .red],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.irLux
				}
			),

			// Radiation
			MetricsChartSeries(
				id: "radiation",
				keyPath: \.radiation,
				name: "Radiation",
				abbreviatedName: "☢️",
				unit: "µR/h",
				minimumYAxisSpan: 20.0,
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.orange.darker(componentDelta: 0.4)), .orange],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.radiation
				}
			),

			// Combined Wind Speed and Direction Series Configuration -- For use in Chart only
			MetricsChartSeries(
				id: "windSpeedAndDirection",
				keyPath: \.windSpeedAndDirection,
				name: "Wind Speed/Direction",
				abbreviatedName: "Speed/Dir",
				unit: "m/s",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.yellow.darker(componentDelta: 0.3)), Color(UIColor.yellow.darker(componentDelta: 0.1))],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.windSpeedAndDirection?.windSpeed
				}
			),

			// Rainfall 1-hour
			MetricsChartSeries(
				id: "rainfall1H",
				keyPath: \.rainfall1H,
				name: "Rainfall 1H",
				abbreviatedName: "Rain 1H",
				unit: "mm",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.systemBlue.darker(componentDelta: 0.5)), .blue],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.rainfall1H
				}
			),

			// Rainfall 24-hour
			MetricsChartSeries(
				id: "rainfall24H",
				keyPath: \.rainfall24H,
				name: "Rainfall 24H",
				abbreviatedName: "Rain 24H",
				unit: "mm",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.systemBlue.darker(componentDelta: 0.5)), .cyan],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.rainfall24H
				}
			),

			// Weight
			MetricsChartSeries(
				id: "weight",
				keyPath: \.weight,
				name: "Weight",
				abbreviatedName: "kg",
				unit: "kg",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.systemPink.darker(componentDelta: 0.5)), .pink],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.weight
				}
			),

			// Distance
			MetricsChartSeries(
				id: "distance",
				keyPath: \.distance,
				name: "Distance",
				abbreviatedName: "Dist",
				unit: "mm",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.systemTeal.darker(componentDelta: 0.7)), Color(UIColor.systemTeal)],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.distance
				}
			),

			// Soil Temperature
			MetricsChartSeries(
				id: "soilTemperature",
				keyPath: \.soilTemperature,
				name: "Soil Temperature",
				abbreviatedName: "Soil Temp",
				unit: "°",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.brown.darker(componentDelta: 0.4)), .brown],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.soilTemperature.map { Float($0.localeTemperature()) }
				}
			),

			// Soil Moisture
			MetricsChartSeries(
				id: "soilMoisture",
				keyPath: \.soilMoisture,
				name: "Soil Moisture",
				abbreviatedName: "Moist",
				unit: "%",
				visible: false,
				chartType: .line,
				foregroundStyle: { _ in
					.linearGradient(
						colors: [Color(UIColor.blue.darker(componentDelta: 0.4)), .brown],
						startPoint: .bottom, endPoint: .top
					)
				},
				valueExtractor: { entity in
					entity.soilMoisture
				}
			)
		])
	}
}