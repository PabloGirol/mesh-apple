//
//  TelemetryEntity.swift
//  Meshtastic
//
//  Core Data entity for TelemetryEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(TelemetryEntity)
public class TelemetryEntity: NSManagedObject {

}

extension TelemetryEntity {
    @NSManaged public var metricsType: Int32
    @NSManaged public var time: Date??
    @NSManaged public var airUtilTx: Float??
    @NSManaged public var barometricPressure: Float??
    @NSManaged public var batteryLevel: Int32??
    @NSManaged public var channelUtilization: Float??
    @NSManaged public var current: Float??
    @NSManaged public var gasResistance: Float??
    @NSManaged public var relativeHumidity: Float??
    @NSManaged public var temperature: Float??
    @NSManaged public var voltage: Float??
    @NSManaged public var nodeTelemetry: NodeInfoEntity?
}

extension TelemetryEntity: CoreDataEntity {
    public static var entityName: String { "TelemetryEntity" }
}
