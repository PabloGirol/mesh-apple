//
//  TelemetryConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for TelemetryConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(TelemetryConfigEntity)
public class TelemetryConfigEntity: NSManagedObject {

}

extension TelemetryConfigEntity {
    @NSManaged public var deviceUpdateInterval: Int32
    @NSManaged public var environmentDisplayFahrenheit: Bool
    @NSManaged public var environmentMeasurementEnabled: Bool
    @NSManaged public var telemetryConfigNode: NodeInfoEntity?
}

extension TelemetryConfigEntity: CoreDataEntity {
    public static var entityName: String { "TelemetryConfigEntity" }
}
