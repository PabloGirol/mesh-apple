//
//  SerialConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for SerialConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(SerialConfigEntity)
public class SerialConfigEntity: NSManagedObject {

}

extension SerialConfigEntity {
    @NSManaged public var baudRate: Int32
    @NSManaged public var echo: Bool
    @NSManaged public var enabled: Bool
    @NSManaged public var mode: Int32
    @NSManaged public var rxd: Int32
    @NSManaged public var timeout: Int32
    @NSManaged public var txd: Int32
    @NSManaged public var serialConfigNode: NodeInfoEntity?
}

extension SerialConfigEntity: CoreDataEntity {
    public static var entityName: String { "SerialConfigEntity" }
}
