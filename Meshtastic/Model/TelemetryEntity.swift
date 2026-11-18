//
//  TelemetryEntity.swift
//  Meshtastic
//
//  SwiftData model for telemetry data.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(TelemetryEntity)
public class TelemetryEntity: NSManagedObject {

	// Non-optional scalars
	@NSManaged public var metricsType: Int32
	@NSManaged public var numOnlineNodes: Int32
	@NSManaged public var numPacketsRx: Int32
	@NSManaged public var numPacketsRxBad: Int32
	@NSManaged public var numPacketsTx: Int32
	@NSManaged public var numRxDupe: Int32
	@NSManaged public var numTotalNodes: Int32
	@NSManaged public var numTxRelay: Int32
	@NSManaged public var numTxRelayCanceled: Int32
	@NSManaged public var time: Date?

	// Optional scalars
	@NSManaged public var airUtilTx: Float?
	@NSManaged public var barometricPressure: Float?
	@NSManaged public var batteryLevel: Int32?
	@NSManaged public var channelUtilization: Float?
	@NSManaged public var current: Float?
	@NSManaged public var distance: Float?
	@NSManaged public var gasResistance: Float?
	@NSManaged public var iaq: Int32?
	@NSManaged public var irLux: Float?
	@NSManaged public var lux: Float?
	@NSManaged public var noiseFloor: Int32?
	@NSManaged public var powerCh1Current: Float?
	@NSManaged public var powerCh1Voltage: Float?
	@NSManaged public var powerCh2Current: Float?
	@NSManaged public var powerCh2Voltage: Float?
	@NSManaged public var powerCh3Current: Float?
	@NSManaged public var powerCh3Voltage: Float?
	@NSManaged public var radiation: Float?
	@NSManaged public var rainfall1H: Float?
	@NSManaged public var rainfall24H: Float?
	@NSManaged public var relativeHumidity: Float?
	@NSManaged public var rssi: Int32?
	@NSManaged public var snr: Float?
	@NSManaged public var soilMoisture: UInt32?
	@NSManaged public var soilTemperature: Float?
	@NSManaged public var temperature: Float?
	@NSManaged public var uptimeSeconds: Int32?
	@NSManaged public var uvLux: Float?
	@NSManaged public var voltage: Float?
	@NSManaged public var weight: Float?
	@NSManaged public var whiteLux: Float?
	@NSManaged public var windDirection: Int32?
	@NSManaged public var windGust: Float?
	@NSManaged public var windLull: Float?
	@NSManaged public var windSpeed: Float?

	// MARK: - Air Quality Metrics
	// Particulate matter concentrations (µg/m³) from the firmware's AirQualityMetrics telemetry
	// variant (metricsType 3), persisted like the other environment telemetry fields. See issue #2040.
	@NSManaged public var pm10Standard: UInt32?
	@NSManaged public var pm25Standard: UInt32?
	@NSManaged public var pm100Standard: UInt32?
	@NSManaged public var pm10Environmental: UInt32?
	@NSManaged public var pm25Environmental: UInt32?
	@NSManaged public var pm100Environmental: UInt32?

	/// The node this reading belongs to. New rows are found by this number rather than through
	/// `nodeTelemetry`: setting the relationship makes SwiftData load every telemetry row the
	/// node has to update the inverse array, on each insert. See `TelemetryEntity+NodeNum.swift`.
	@NSManaged public var nodeNum: Int64

	// Relationship. Only rows saved before `nodeNum` existed still use it; new rows leave it nil.
	@NSManaged public var nodeTelemetry: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "TelemetryEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.metricsType = 0
		self.numOnlineNodes = 0
		self.numPacketsRx = 0
		self.numPacketsRxBad = 0
		self.numPacketsTx = 0
		self.numRxDupe = 0
		self.numTotalNodes = 0
		self.numTxRelay = 0
		self.numTxRelayCanceled = 0
		self.time = nil
		self.airUtilTx = nil
		self.barometricPressure = nil
		self.batteryLevel = nil
		self.channelUtilization = nil
		self.current = nil
		self.distance = nil
		self.gasResistance = nil
		self.iaq = nil
		self.irLux = nil
		self.lux = nil
		self.noiseFloor = nil
		self.powerCh1Current = nil
		self.powerCh1Voltage = nil
		self.powerCh2Current = nil
		self.powerCh2Voltage = nil
		self.powerCh3Current = nil
		self.powerCh3Voltage = nil
		self.radiation = nil
		self.rainfall1H = nil
		self.rainfall24H = nil
		self.relativeHumidity = nil
		self.rssi = nil
		self.snr = nil
		self.soilMoisture = nil
		self.soilTemperature = nil
		self.temperature = nil
		self.uptimeSeconds = nil
		self.uvLux = nil
		self.voltage = nil
		self.weight = nil
		self.whiteLux = nil
		self.windDirection = nil
		self.windGust = nil
		self.windLull = nil
		self.windSpeed = nil
		self.pm10Standard = nil
		self.pm25Standard = nil
		self.pm100Standard = nil
		self.pm10Environmental = nil
		self.pm25Environmental = nil
		self.pm100Environmental = nil
		self.nodeNum = 0
		self.nodeTelemetry = nil
	}
}

extension TelemetryEntity {
	// Computed property
	var dewPoint: Float? {
		guard let temp = self.temperature, let rh = self.relativeHumidity else {
			return nil
		}
		return Float(calculateDewPoint(temp: temp, relativeHumidity: rh, convertToLocale: false))
	}
}