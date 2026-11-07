//
//  PositionEntity.swift
//  Meshtastic
//
//  Core Data entity for PositionEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(PositionEntity)
public class PositionEntity: NSManagedObject {

}

extension PositionEntity {
    @NSManaged public var altitude: Int32
    @NSManaged public var heading: Int32
    @NSManaged public var latitudeI: Int32
    @NSManaged public var longitudeI: Int32
    @NSManaged public var satsInView: Int32
    @NSManaged public var seqNo: Int32
    @NSManaged public var snr: Float
    @NSManaged public var speed: Int32
    @NSManaged public var time: Date??
    @NSManaged public var nodePosition: NodeInfoEntity?
}

extension PositionEntity: CoreDataEntity {
    public static var entityName: String { "PositionEntity" }
}
