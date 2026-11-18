//
//  ConfigModels.swift
//  Meshtastic
//
//  SwiftData models for all device and module configuration entities.
//  Converted to Core Data NSManagedObject subclasses for iOS 15 compatibility.
//

import Foundation
import CoreData


@objc(DetectionSensorConfigEntity)
public class DetectionSensorConfigEntity: NSManagedObject {

	@NSManaged public var enabled: Bool
	@NSManaged public var minimumBroadcastSecs: Int32
	@NSManaged public var monitorPin: Int32
	@NSManaged public var name: String?
	@NSManaged public var sendBell: Bool
	@NSManaged public var stateBroadcastSecs: Int32
	@NSManaged public var triggerType: Int32
	@NSManaged public var usePullup: Bool
	@NSManaged public var detectionSensorConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DetectionSensorConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.enabled = false
		self.minimumBroadcastSecs = 0
		self.monitorPin = 0
		self.name = nil
		self.sendBell = false
		self.stateBroadcastSecs = 0
		self.triggerType = 0
		self.usePullup = false
		self.detectionSensorConfigNode = nil
	}
}


@objc(MeshBeaconConfigEntity)
public class MeshBeaconConfigEntity: NSManagedObject {

	@NSManaged public var flags: Int32
	@NSManaged public var broadcastMessage: String
	@NSManaged public var broadcastOfferChannelName: String
	@NSManaged public var broadcastOfferChannelPSK: Data
	@NSManaged public var broadcastOfferRegion: Int32
	@NSManaged public var broadcastOfferPreset: Int32
	@NSManaged public var broadcastOfferFrequencySlot: Int32
	@NSManaged public var broadcastOnChannelName: String
	@NSManaged public var broadcastOnChannelPSK: Data
	@NSManaged public var broadcastOnRegion: Int32
	@NSManaged public var broadcastOnPreset: Int32
	@NSManaged public var broadcastIntervalSecs: Int32
	@NSManaged public var broadcastSendAsNode: Int64
	@NSManaged public var broadcastTargets: NSSet?
	@NSManaged public var meshBeaconConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "MeshBeaconConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.flags = 0
		self.broadcastMessage = ""
		self.broadcastOfferChannelName = ""
		self.broadcastOfferChannelPSK = Data()
		self.broadcastOfferRegion = 0
		self.broadcastOfferPreset = -1
		self.broadcastOfferFrequencySlot = 0
		self.broadcastOnChannelName = ""
		self.broadcastOnChannelPSK = Data()
		self.broadcastOnRegion = 0
		self.broadcastOnPreset = -1
		self.broadcastIntervalSecs = 3600
		self.broadcastSendAsNode = 0
		self.meshBeaconConfigNode = nil
	}
}

extension MeshBeaconConfigEntity {
	@objc(addBroadcastTargetsObject:)
	public func addToBroadcastTargets(_ value: BroadcastTargetEntity) {
		mutableSetValue(forKey: "broadcastTargets").add(value)
	}

	@objc(removeBroadcastTargetsObject:)
	public func removeFromBroadcastTargets(_ value: BroadcastTargetEntity) {
		mutableSetValue(forKey: "broadcastTargets").remove(value)
	}

	@objc(addBroadcastTargets:)
	public func addToBroadcastTargets(_ values: NSSet) {
		mutableSetValue(forKey: "broadcastTargets").union(values)
	}

	@objc(removeBroadcastTargets:)
	public func removeFromBroadcastTargets(_ values: NSSet) {
		mutableSetValue(forKey: "broadcastTargets").minus(values)
	}
}


@objc(DeviceConfigEntity)
public class DeviceConfigEntity: NSManagedObject {

	@NSManaged public var buttonGpio: Int32
	@NSManaged public var buzzerGpio: Int32
	@NSManaged public var debugLogEnabled: Bool
	@NSManaged public var disableTripleClick: Bool
	@NSManaged public var doubleTapAsButtonPress: Bool
	@NSManaged public var isManaged: Bool
	@NSManaged public var ledHeartbeatEnabled: Bool
	@NSManaged public var nodeInfoBroadcastSecs: Int32
	@NSManaged public var rebroadcastMode: Int32
	@NSManaged public var role: Int32
	@NSManaged public var serialEnabled: Bool
	@NSManaged public var tripleClickAsAdHocPing: Bool
	@NSManaged public var tzdef: String?
	@NSManaged public var deviceConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DeviceConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.buttonGpio = 0
		self.buzzerGpio = 0
		self.debugLogEnabled = false
		self.disableTripleClick = false
		self.doubleTapAsButtonPress = false
		self.isManaged = false
		self.ledHeartbeatEnabled = true
		self.nodeInfoBroadcastSecs = 0
		self.rebroadcastMode = 0
		self.role = 0
		self.serialEnabled = false
		self.tripleClickAsAdHocPing = true
		self.tzdef = nil
		self.deviceConfigNode = nil
	}
}


@objc(LoRaConfigEntity)
public class LoRaConfigEntity: NSManagedObject {

	@NSManaged public var bandwidth: Int32
	@NSManaged public var channelNum: Int32
	@NSManaged public var codingRate: Int32
	@NSManaged public var frequencyOffset: Float
	@NSManaged public var hopLimit: Int32
	@NSManaged public var ignoreMqtt: Bool
	@NSManaged public var modemPreset: Int32
	@NSManaged public var okToMqtt: Bool
	@NSManaged public var overrideDutyCycle: Bool
	@NSManaged public var paFanDisabled: Bool
	@NSManaged public var overrideFrequency: Float
	@NSManaged public var regionCode: Int32
	@NSManaged public var spreadFactor: Int32
	@NSManaged public var sx126xRxBoostedGain: Bool
	@NSManaged public var txEnabled: Bool
	@NSManaged public var txPower: Int32
	@NSManaged public var usePreset: Bool
	@NSManaged public var loRaConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "LoRaConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.bandwidth = 0
		self.channelNum = 0
		self.codingRate = 0
		self.frequencyOffset = 0
		self.hopLimit = 0
		self.ignoreMqtt = false
		self.modemPreset = 0
		self.okToMqtt = false
		self.overrideDutyCycle = false
		self.paFanDisabled = false
		self.overrideFrequency = 0.0
		self.regionCode = 0
		self.spreadFactor = 0
		self.sx126xRxBoostedGain = false
		self.txEnabled = true
		self.txPower = 0
		self.usePreset = true
		self.loRaConfigNode = nil
	}
}

@objc(MQTTConfigEntity)
public class MQTTConfigEntity: NSManagedObject {

	@NSManaged public var address: String?
	@NSManaged public var enabled: Bool
	@NSManaged public var encryptionEnabled: Bool
	@NSManaged public var jsonEnabled: Bool
	@NSManaged public var mapPositionPrecision: Int32
	@NSManaged public var mapPublishIntervalSecs: Int32
	@NSManaged public var mapReportingEnabled: Bool
	@NSManaged public var mapReportingShouldReportLocation: Bool
	@NSManaged public var password: String?
	@NSManaged public var proxyToClientEnabled: Bool
	@NSManaged public var root: String?
	@NSManaged public var tlsEnabled: Bool
	@NSManaged public var username: String?
	@NSManaged public var mqttConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "MQTTConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.address = nil
		self.enabled = false
		self.encryptionEnabled = false
		self.jsonEnabled = false
		self.mapPositionPrecision = 13
		self.mapPublishIntervalSecs = 0
		self.mapReportingEnabled = false
		self.mapReportingShouldReportLocation = false
		self.password = nil
		self.proxyToClientEnabled = false
		self.root = "msh"
		self.tlsEnabled = false
		self.username = nil
		self.mqttConfigNode = nil
	}
}


@objc(NeighborInfoConfigEntity)
public class NeighborInfoConfigEntity: NSManagedObject {

	@NSManaged public var enabled: Bool
	@NSManaged public var transmitOverLora: Bool
	@NSManaged public var updateInterval: Int32
	@NSManaged public var neighborInfoConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "NeighborInfoConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.enabled = false
		self.transmitOverLora = false
		self.updateInterval = 0
		self.neighborInfoConfigNode = nil
	}
}

@objc(PaxCounterConfigEntity)
public class PaxCounterConfigEntity: NSManagedObject {

	@NSManaged public var bleThreshold: Int32
	@NSManaged public var enabled: Bool
	@NSManaged public var updateInterval: Int32
	@NSManaged public var wifiThreshold: Int32
	@NSManaged public var paxCounterConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "PaxCounterConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.bleThreshold = 0
		self.enabled = false
		self.updateInterval = 0
		self.wifiThreshold = -80
		self.paxCounterConfigNode = nil
	}
}

@objc(PositionConfigEntity)
public class PositionConfigEntity: NSManagedObject {

	@NSManaged public var broadcastSmartMinimumDistance: Int32
	@NSManaged public var broadcastSmartMinimumIntervalSecs: Int32
	@NSManaged public var deviceGpsEnabled: Bool
	@NSManaged public var fixedPosition: Bool
	@NSManaged public var gpsAttemptTime: Int32
	@NSManaged public var gpsEnGpio: Int32
	@NSManaged public var gpsMode: Int32
	@NSManaged public var gpsUpdateInterval: Int32
	@NSManaged public var positionBroadcastSeconds: Int32
	@NSManaged public var positionFlags: Int32
	@NSManaged public var rxGpio: Int32
	@NSManaged public var smartPositionEnabled: Bool
	@NSManaged public var txGpio: Int32
	@NSManaged public var positionConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "PositionConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.broadcastSmartMinimumDistance = 0
		self.broadcastSmartMinimumIntervalSecs = 0
		self.deviceGpsEnabled = false
		self.fixedPosition = false
		self.gpsAttemptTime = 0
		self.gpsEnGpio = 0
		self.gpsMode = 0
		self.gpsUpdateInterval = 0
		self.positionBroadcastSeconds = 0
		self.positionFlags = 0
		self.rxGpio = 0
		self.smartPositionEnabled = false
		self.txGpio = 0
		self.positionConfigNode = nil
	}
}

@objc(PowerConfigEntity)
public class PowerConfigEntity: NSManagedObject {

	@NSManaged public var adcMultiplierOverride: Float
	@NSManaged public var deviceBatteryInaAddress: Int32
	@NSManaged public var isPowerSaving: Bool
	@NSManaged public var lsSecs: Int32
	@NSManaged public var minWakeSecs: Int32
	@NSManaged public var onBatteryShutdownAfterSecs: Int32
	@NSManaged public var waitBluetoothSecs: Int32
	@NSManaged public var powerConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "PowerConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.adcMultiplierOverride = 0
		self.deviceBatteryInaAddress = 0
		self.isPowerSaving = false
		self.lsSecs = 0
		self.minWakeSecs = 0
		self.onBatteryShutdownAfterSecs = 0
		self.waitBluetoothSecs = 0
		self.powerConfigNode = nil
	}
}

@objc(RangeTestConfigEntity)
public class RangeTestConfigEntity: NSManagedObject {

	@NSManaged public var enabled: Bool
	@NSManaged public var save: Bool
	@NSManaged public var sender: Int32
	@NSManaged public var rangeTestConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "RangeTestConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.enabled = false
		self.save = false
		self.sender = 0
		self.rangeTestConfigNode = nil
	}
}

@objc(RTTTLConfigEntity)
public class RTTTLConfigEntity: NSManagedObject {

	@NSManaged public var ringtone: String?
	@NSManaged public var rtttlConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "RTTTLConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.ringtone = nil
		self.rtttlConfigNode = nil
	}
}

@objc(SecurityConfigEntity)
public class SecurityConfigEntity: NSManagedObject {

	@NSManaged public var adminChannelEnabled: Bool
	@NSManaged public var adminKey: Data?
	@NSManaged public var adminKey2: Data?
	@NSManaged public var adminKey3: Data?
	@NSManaged public var bluetoothLoggingEnabled: Bool
	@NSManaged public var debugLogApiEnabled: Bool
	@NSManaged public var isManaged: Bool
	/// Raw value of `Config.SecurityConfig.PacketSignaturePolicy`. 0 (Compatible) is the
	/// protobuf default, so an absent field and an unconfigured entity agree.
	@NSManaged public var packetSignaturePolicy: Int32
	@NSManaged public var privateKey: Data?
	@NSManaged public var publicKey: Data?
	@NSManaged public var serialEnabled: Bool
	@NSManaged public var securityConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "SecurityConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.adminChannelEnabled = false
		self.adminKey = nil
		self.adminKey2 = nil
		self.adminKey3 = nil
		self.bluetoothLoggingEnabled = false
		self.debugLogApiEnabled = false
		self.isManaged = false
		self.packetSignaturePolicy = 0
		self.privateKey = nil
		self.publicKey = nil
		self.serialEnabled = false
		self.securityConfigNode = nil
	}
}

@objc(SerialConfigEntity)
public class SerialConfigEntity: NSManagedObject {

	@NSManaged public var baudRate: Int32
	@NSManaged public var echo: Bool
	@NSManaged public var enabled: Bool
	@NSManaged public var mode: Int32
	@NSManaged public var overrideConsoleSerialPort: Bool
	@NSManaged public var rxd: Int32
	@NSManaged public var timeout: Int32
	@NSManaged public var txd: Int32
	@NSManaged public var serialConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "SerialConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.baudRate = 0
		self.echo = false
		self.enabled = false
		self.mode = 0
		self.overrideConsoleSerialPort = false
		self.rxd = 0
		self.timeout = 0
		self.txd = 0
		self.serialConfigNode = nil
	}
}

@objc(StoreForwardConfigEntity)
public class StoreForwardConfigEntity: NSManagedObject {

	@NSManaged public var enabled: Bool
	@NSManaged public var heartbeat: Bool
	@NSManaged public var historyReturnMax: Int32
	@NSManaged public var historyReturnWindow: Int32
	@NSManaged public var isRouter: Bool
	@NSManaged public var lastHeartbeat: Date?
	@NSManaged public var lastRequest: Int32
	@NSManaged public var records: Int32
	@NSManaged public var storeForwardConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "StoreForwardConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.enabled = false
		self.heartbeat = false
		self.historyReturnMax = 0
		self.historyReturnWindow = 0
		self.isRouter = false
		self.lastHeartbeat = nil
		self.lastRequest = 0
		self.records = 0
		self.storeForwardConfigNode = nil
	}
}

@objc(StatusMessageConfigEntity)
public class StatusMessageConfigEntity: NSManagedObject {

	@NSManaged public var nodeStatus: String
	@NSManaged public var statusMessageConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "StatusMessageConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.nodeStatus = ""
		self.statusMessageConfigNode = nil
	}
}

@objc(TAKConfigEntity)
public class TAKConfigEntity: NSManagedObject {

	@NSManaged public var role: Int32
	@NSManaged public var team: Int32
	@NSManaged public var takConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "TAKConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.role = 0
		self.team = 0
		self.takConfigNode = nil
	}
}

@objc(TelemetryConfigEntity)
public class TelemetryConfigEntity: NSManagedObject {

	@NSManaged public var airQualityEnabled: Bool
	@NSManaged public var airQualityInterval: Int32
	@NSManaged public var deviceTelemetryEnabled: Bool
	@NSManaged public var deviceUpdateInterval: Int32
	@NSManaged public var environmentDisplayFahrenheit: Bool
	@NSManaged public var environmentMeasurementEnabled: Bool
	@NSManaged public var environmentScreenEnabled: Bool
	@NSManaged public var environmentUpdateInterval: Int32
	@NSManaged public var powerMeasurementEnabled: Bool
	@NSManaged public var powerScreenEnabled: Bool
	@NSManaged public var powerUpdateInterval: Int32
	@NSManaged public var telemetryConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "TelemetryConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.airQualityEnabled = false
		self.airQualityInterval = 0
		self.deviceTelemetryEnabled = false
		self.deviceUpdateInterval = 0
		self.environmentDisplayFahrenheit = false
		self.environmentMeasurementEnabled = false
		self.environmentScreenEnabled = false
		self.environmentUpdateInterval = 0
		self.powerMeasurementEnabled = false
		self.powerScreenEnabled = false
		self.powerUpdateInterval = 0
		self.telemetryConfigNode = nil
	}
}