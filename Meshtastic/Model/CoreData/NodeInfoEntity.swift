//
//  NodeInfoEntity.swift
//  Meshtastic
//
//  Core Data entity for NodeInfoEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(NodeInfoEntity)
public class NodeInfoEntity: NSManagedObject {

}

extension NodeInfoEntity {
    @NSManaged public var bleName: String??
    @NSManaged public var channel: Int32
    @NSManaged public var id: Int64
    @NSManaged public var lastHeard: Date
    @NSManaged public var num: Int64
    @NSManaged public var snr: Float
    @NSManaged public var user: UserEntity?
    @NSManaged public var myInfo: MyInfoEntity?
    @NSManaged public var channels: NSSet
    @NSManaged public var positions: NSSet
    @NSManaged public var telemetry: NSSet
    @NSManaged public var bluetoothConfig: BluetoothConfigEntity?
    @NSManaged public var cannedMessageConfig: CannedMessageConfigEntity?
    @NSManaged public var deviceConfig: DeviceConfigEntity?
    @NSManaged public var displayConfig: DisplayConfigEntity?
    @NSManaged public var externalNotificationConfig: ExternalNotificationConfigEntity?
    @NSManaged public var loRaConfig: LoRaConfigEntity?
    @NSManaged public var mqttConfig: MQTTConfigEntity?
    @NSManaged public var networkConfig: NetworkConfigEntity?
    @NSManaged public var positionConfig: PositionConfigEntity?
    @NSManaged public var rangeTestConfig: RangeTestConfigEntity?
    @NSManaged public var serialConfig: SerialConfigEntity?
    @NSManaged public var telemetryConfig: TelemetryConfigEntity?

    @objc(addChannelsObject:)
    @NSManaged public func addToChannels(_ value: ChannelEntity)

    @objc(removeChannelsObject:)
    @NSManaged public func removeFromChannels(_ value: ChannelEntity)

    @objc(addChannels:)
    @NSManaged public func addToChannels(_ values: NSSet)

    @objc(removeChannels:)
    @NSManaged public func removeFromChannels(_ values: NSSet)


    @objc(addPositionsObject:)
    @NSManaged public func addToPositions(_ value: PositionEntity)

    @objc(removePositionsObject:)
    @NSManaged public func removeFromPositions(_ value: PositionEntity)

    @objc(addPositions:)
    @NSManaged public func addToPositions(_ values: NSSet)

    @objc(removePositions:)
    @NSManaged public func removeFromPositions(_ values: NSSet)


    @objc(addTelemetryObject:)
    @NSManaged public func addToTelemetry(_ value: TelemetryEntity)

    @objc(removeTelemetryObject:)
    @NSManaged public func removeFromTelemetry(_ value: TelemetryEntity)

    @objc(addTelemetry:)
    @NSManaged public func addToTelemetry(_ values: NSSet)

    @objc(removeTelemetry:)
    @NSManaged public func removeFromTelemetry(_ values: NSSet)

}

extension NodeInfoEntity: CoreDataEntity {
    public static var entityName: String { "NodeInfoEntity" }
}
