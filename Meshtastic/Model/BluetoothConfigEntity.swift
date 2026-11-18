//
//  BluetoothConfigEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for Bluetooth configuration.
//  Converted from SwiftData @Model for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(BluetoothConfigEntity)
public class BluetoothConfigEntity: NSManagedObject {

    @NSManaged public var deviceLoggingEnabled: Bool
    @NSManaged public var enabled: Bool
    @NSManaged public var fixedPin: Int32
    @NSManaged public var mode: Int32

    // Inverse relationship to NodeInfoEntity
    @NSManaged public var bluetoothConfigNode: NodeInfoEntity?

    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "BluetoothConfigEntity", in: context)!
        self.init(entity: entity, insertInto: context)
        self.deviceLoggingEnabled = false
        self.enabled = false
        self.fixedPin = 123456
        self.mode = 0
        self.bluetoothConfigNode = nil
    }
}