//
//  Measurement.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 11/17/23.
//  Updated for DGCharts iOS 15 compatibility
//

import Foundation

struct PlottableMeasurement<UnitType: Unit> {
	var measurement: Measurement<UnitType>
}

extension PlottableMeasurement: Plottable where UnitType == UnitLength {
	var primitivePlottable: Double {
		self.measurement.converted(to: .meters).value
	}

	init?(primitivePlottable: Double) {
		self.init(
			measurement: Measurement(
				value: primitivePlottable,
				unit: .meters
			)
		)
	}
}