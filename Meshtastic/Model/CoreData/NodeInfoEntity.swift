//
//  NodeInfoEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(NodeInfoEntity)
public class NodeInfoEntity: NSManagedObject {

}

extension NodeInfoEntity {
    public var bleName: String?? {
        get { value(forKey: "bleName") as? String? }
        set { setValue(newValue, forKey: "bleName") }
    }
    public var channel: Int32 {
        get { value(forKey: "channel") as! Int32 }
        set { setValue(newValue, forKey: "channel") }
    }
    public var id: Int64 {
        get { value(forKey: "id") as! Int64 }
        set { setValue(newValue, forKey: "id") }
    }
    public var lastHeard: Date {
        get { value(forKey: "lastHeard") as! Date }
        set { setValue(newValue, forKey: "lastHeard") }
    }
    public var num: Int64 {
        get { value(forKey: "num") as! Int64 }
        set { setValue(newValue, forKey: "num") }
    }
    public var snr: Float {
        get { value(forKey: "snr") as! Float }
        set { setValue(newValue, forKey: "snr") }
    }
    public var user: UserEntity? {
        get { value(forKey: "user") as? UserEntity }
        set { setValue(newValue, forKey: "user") }
    }
    public var myInfo: MyInfoEntity? {
        get { value(forKey: "myInfo") as? MyInfoEntity }
        set { setValue(newValue, forKey: "myInfo") }
    }
    public var channels: NSSet? {
        get { value(forKey: "channels") as? NSSet }
        set { setValue(newValue, forKey: "channels") }
    }
    public var positions: NSSet? {
        get { value(forKey: "positions") as? NSSet }
        set { setValue(newValue, forKey: "positions") }
    }
    public var telemetry: NSSet? {
        get { value(forKey: "telemetry") as? NSSet }
        set { setValue(newValue, forKey: "telemetry") }
    }
    public var bluetoothConfig: BluetoothConfigEntity? {
        get { value(forKey: "bluetoothConfig") as? BluetoothConfigEntity }
        set { setValue(newValue, forKey: "bluetoothConfig") }
    }
    public var cannedMessageConfig: CannedMessageConfigEntity? {
        get { value(forKey: "cannedMessageConfig") as? CannedMessageConfigEntity }
        set { setValue(newValue, forKey: "cannedMessageConfig") }
    }
    public var deviceConfig: DeviceConfigEntity? {
        get { value(forKey: "deviceConfig") as? DeviceConfigEntity }
        set { setValue(newValue, forKey: "deviceConfig") }
    }
    public var displayConfig: DisplayConfigEntity? {
        get { value(forKey: "displayConfig") as? DisplayConfigEntity }
        set { setValue(newValue, forKey: "displayConfig") }
    }
    public var externalNotificationConfig: ExternalNotificationConfigEntity? {
        get { value(forKey: "externalNotificationConfig") as? ExternalNotificationConfigEntity }
        set { setValue(newValue, forKey: "externalNotificationConfig") }
    }
    public var loRaConfig: LoRaConfigEntity? {
        get { value(forKey: "loRaConfig") as? LoRaConfigEntity }
        set { setValue(newValue, forKey: "loRaConfig") }
    }
    public var mqttConfig: MQTTConfigEntity? {
        get { value(forKey: "mqttConfig") as? MQTTConfigEntity }
        set { setValue(newValue, forKey: "mqttConfig") }
    }
    public var networkConfig: NetworkConfigEntity? {
        get { value(forKey: "networkConfig") as? NetworkConfigEntity }
        set { setValue(newValue, forKey: "networkConfig") }
    }
    public var positionConfig: PositionConfigEntity? {
        get { value(forKey: "positionConfig") as? PositionConfigEntity }
        set { setValue(newValue, forKey: "positionConfig") }
    }
    public var rangeTestConfig: RangeTestConfigEntity? {
        get { value(forKey: "rangeTestConfig") as? RangeTestConfigEntity }
        set { setValue(newValue, forKey: "rangeTestConfig") }
    }
    public var serialConfig: SerialConfigEntity? {
        get { value(forKey: "serialConfig") as? SerialConfigEntity }
        set { setValue(newValue, forKey: "serialConfig") }
    }
    public var telemetryConfig: TelemetryConfigEntity? {
        get { value(forKey: "telemetryConfig") as? TelemetryConfigEntity }
        set { setValue(newValue, forKey: "telemetryConfig") }
    }
    public var ambientLightingConfig: AmbientLightingConfigEntity? {
        get { value(forKey: "ambientLightingConfig") as? AmbientLightingConfigEntity }
        set { setValue(newValue, forKey: "ambientLightingConfig") }
    }
    public var audioConfig: AudioConfigEntity? {
        get { value(forKey: "audioConfig") as? AudioConfigEntity }
        set { setValue(newValue, forKey: "audioConfig") }
    }
    public var detectionSensorConfig: DetectionSensorConfigEntity? {
        get { value(forKey: "detectionSensorConfig") as? DetectionSensorConfigEntity }
        set { setValue(newValue, forKey: "detectionSensorConfig") }
    }
    public var meshBeaconConfig: MeshBeaconConfigEntity? {
        get { value(forKey: "meshBeaconConfig") as? MeshBeaconConfigEntity }
        set { setValue(newValue, forKey: "meshBeaconConfig") }
    }
    public var paxCounterConfig: PaxCounterConfigEntity? {
        get { value(forKey: "paxCounterConfig") as? PaxCounterConfigEntity }
        set { setValue(newValue, forKey: "paxCounterConfig") }
    }
    public var powerConfig: PowerConfigEntity? {
        get { value(forKey: "powerConfig") as? PowerConfigEntity }
        set { setValue(newValue, forKey: "powerConfig") }
    }
    public var rtttlConfig: RTTTLConfigEntity? {
        get { value(forKey: "rtttlConfig") as? RTTTLConfigEntity }
        set { setValue(newValue, forKey: "rtttlConfig") }
    }
    public var securityConfig: SecurityConfigEntity? {
        get { value(forKey: "securityConfig") as? SecurityConfigEntity }
        set { setValue(newValue, forKey: "securityConfig") }
    }
    public var storeForwardConfig: StoreForwardConfigEntity? {
        get { value(forKey: "storeForwardConfig") as? StoreForwardConfigEntity }
        set { setValue(newValue, forKey: "storeForwardConfig") }
    }
    public var takConfig: TAKConfigEntity? {
        get { value(forKey: "takConfig") as? TAKConfigEntity }
        set { setValue(newValue, forKey: "takConfig") }
    }
    public var neighborInfoConfig: NeighborInfoConfigEntity? {
        get { value(forKey: "neighborInfoConfig") as? NeighborInfoConfigEntity }
        set { setValue(newValue, forKey: "neighborInfoConfig") }
    }
    public var statusMessageConfig: StatusMessageConfigEntity? {
        get { value(forKey: "statusMessageConfig") as? StatusMessageConfigEntity }
        set { setValue(newValue, forKey: "statusMessageConfig") }
    }

    @objc(addChannelsObject:)
    public func addToChannels(_ value: ChannelEntity) {
        mutableSetValue(forKey: "channels").add(value)
    }

    @objc(removeChannelsObject:)
    public func removeFromChannels(_ value: ChannelEntity) {
        mutableSetValue(forKey: "channels").remove(value)
    }

    @objc(addChannels:)
    public func addToChannels(_ values: NSSet) {
        mutableSetValue(forKey: "channels").union(values)
    }

    @objc(removeChannels:)
    public func removeFromChannels(_ values: NSSet) {
        mutableSetValue(forKey: "channels").minus(values)
    }


    @objc(addPositionsObject:)
    public func addToPositions(_ value: PositionEntity) {
        mutableSetValue(forKey: "positions").add(value)
    }

    @objc(removePositionsObject:)
    public func removeFromPositions(_ value: PositionEntity) {
        mutableSetValue(forKey: "positions").remove(value)
    }

    @objc(addPositions:)
    public func addToPositions(_ values: NSSet) {
        mutableSetValue(forKey: "positions").union(values)
    }

    @objc(removePositions:)
    public func removeFromPositions(_ values: NSSet) {
        mutableSetValue(forKey: "positions").minus(values)
    }


    @objc(addTelemetryObject:)
    public func addToTelemetry(_ value: TelemetryEntity) {
        mutableSetValue(forKey: "telemetry").add(value)
    }

    @objc(removeTelemetryObject:)
    public func removeFromTelemetry(_ value: TelemetryEntity) {
        mutableSetValue(forKey: "telemetry").remove(value)
    }

    @objc(addTelemetry:)
    public func addToTelemetry(_ values: NSSet) {
        mutableSetValue(forKey: "telemetry").union(values)
    }

    @objc(removeTelemetry:)
    public func removeFromTelemetry(_ values: NSSet) {
        mutableSetValue(forKey: "telemetry").minus(values)
    }

}

extension NodeInfoEntity: CoreDataEntity {
    public static var entityName: String { "NodeInfoEntity" }
}
