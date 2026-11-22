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
	@NSManaged public var time: NSDate?

	// Optional scalars - use NSNumber? for @NSManaged (primitive optionals not representable in ObjC)
	@NSManaged public var airUtilTx: NSNumber?
	@NSManaged public var barometricPressure: NSNumber?
	@NSManaged public var batteryLevel: NSNumber?
	@NSManaged public var channelUtilization: NSNumber?
	@NSManaged public var current: NSNumber?
	@NSManaged public var distance: NSNumber?
	@NSManaged public var gasResistance: NSNumber?
	@NSManaged public var iaq: NSNumber?
	@NSManaged public var irLux: NSNumber?
	@NSManaged public var lux: NSNumber?
	@NSManaged public var noiseFloor: NSNumber?
	@NSManaged public var powerCh1Current: NSNumber?
	@NSManaged public var powerCh1Voltage: NSNumber?
	@NSManaged public var powerCh2Current: NSNumber?
	@NSManaged public var powerCh2Voltage: NSNumber?
	@NSManaged public var powerCh3Current: NSNumber?
	@NSManaged public var powerCh3Voltage: NSNumber?
	@NSManaged public var radiation: NSNumber?
	@NSManaged public var rainfall1H: NSNumber?
	@NSManaged public var rainfall24H: NSNumber?
	@NSManaged public var relativeHumidity: NSNumber?
	@NSManaged public var rssi: NSNumber?
	@NSManaged public var snr: NSNumber?
	@NSManaged public var soilMoisture: NSNumber?
	@NSManaged public var soilTemperature: NSNumber?
	@NSManaged public var temperature: NSNumber?
	@NSManaged public var uptimeSeconds: NSNumber?
	@NSManaged public var uvLux: NSNumber?
	@NSManaged public var voltage: NSNumber?
	@NSManaged public var weight: NSNumber?
	@NSManaged public var whiteLux: NSNumber?
	@NSManaged public var windDirection: NSNumber?
	@NSManaged public var windGust: NSNumber?
	@NSManaged public var windLull: NSNumber?
	@NSManaged public var windSpeed: NSNumber?

	// MARK: - Air Quality Metrics
	// Particulate matter concentrations (µg/m³) from the firmware's AirQualityMetrics telemetry
	// variant (metricsType 3), persisted like the other environment telemetry fields. See issue #2040.
	@NSManaged public var pm10Standard: NSNumber?
	@NSManaged public var pm25Standard: NSNumber?
	@NSManaged public var pm100Standard: NSNumber?
	@NSManaged public var pm10Environmental: NSNumber?
	@NSManaged public var pm25Environmental: NSNumber?
	@NSManaged public var pm100Environmental: NSNumber?

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
		guard let temp = self.temperature?.floatValue, let rh = self.relativeHumidity?.floatValue else {
			return nil
		}
		return Float(calculateDewPoint(temp: temp, relativeHumidity: rh, convertToLocale: false))
	}

	/// A comparable date for sorting. NSDate doesn't conform to Comparable in iOS 15,
	/// so we convert to Date which does.
	var comparableTime: Date {
		time as Date? ?? .distantPast
	}
}