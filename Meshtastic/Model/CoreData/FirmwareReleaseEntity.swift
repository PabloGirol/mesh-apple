//
//  FirmwareReleaseEntity.swift
//  Meshtastic
//
//  Core Data entity for FirmwareReleaseEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(FirmwareReleaseEntity)
public class FirmwareReleaseEntity: NSManagedObject {

}

extension FirmwareReleaseEntity {
    @NSManaged public var channel: String
    @NSManaged public var version: String
    @NSManaged public var releaseDate: Date
    @NSManaged public var changelog: String??
    @NSManaged public var downloadURL: String
    @NSManaged public var hardwareModel: String
    @NSManaged public var minAppVersion: Int32
    @NSManaged public var signature: String??
}

extension FirmwareReleaseEntity: CoreDataEntity {
    public static var entityName: String { "FirmwareReleaseEntity" }
}
