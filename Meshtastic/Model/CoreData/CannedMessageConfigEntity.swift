//
//  CannedMessageConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for CannedMessageConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(CannedMessageConfigEntity)
public class CannedMessageConfigEntity: NSManagedObject {

}

extension CannedMessageConfigEntity {
    @NSManaged public var inputbrokerEventCcw: Int32
    @NSManaged public var inputbrokerEventCw: Int32
    @NSManaged public var inputbrokerEventPress: Int32
    @NSManaged public var inputbrokerPinA: Int32
    @NSManaged public var inputbrokerPinB: Int32
    @NSManaged public var inputbrokerPinPress: Int32
    @NSManaged public var rotary1Enabled: Bool
    @NSManaged public var sendBell: Bool
    @NSManaged public var updown1Enabled: Bool
    @NSManaged public var cannedMessagesConfigNode: NodeInfoEntity?
}

extension CannedMessageConfigEntity: CoreDataEntity {
    public static var entityName: String { "CannedMessageConfigEntity" }
}
