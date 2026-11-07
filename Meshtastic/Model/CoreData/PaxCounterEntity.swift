//
//  PaxCounterEntity.swift
//  Meshtastic
//
//  Core Data entity for PaxCounterEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(PaxCounterEntity)
public class PaxCounterEntity: NSManagedObject {

}

extension PaxCounterEntity {
    @NSManaged public var time: Date
    @NSManaged public var count: Int32
    @NSManaged public var snr: Float
}

extension PaxCounterEntity: CoreDataEntity {
    public static var entityName: String { "PaxCounterEntity" }
}
