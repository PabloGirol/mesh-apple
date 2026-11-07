//
//  BluetoothConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for BluetoothConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(BluetoothConfigEntity)
public class BluetoothConfigEntity: NSManagedObject {

}

extension BluetoothConfigEntity {
    @NSManaged public var enabled: Bool
    @NSManaged public var fixedPin: Int32
    @NSManaged public var mode: Int32
    @NSManaged public var bluetoothConfigNode: NodeInfoEntity?
}

extension BluetoothConfigEntity: CoreDataEntity {
    public static var entityName: String { "BluetoothConfigEntity" }
}
