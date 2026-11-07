//
//  DisplayConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for DisplayConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DisplayConfigEntity)
public class DisplayConfigEntity: NSManagedObject {

}

extension DisplayConfigEntity {
    @NSManaged public var compassNorthTop: Bool
    @NSManaged public var flipScreen: Bool
    @NSManaged public var screenCarouselInterval: Int32
    @NSManaged public var screenOnSeconds: Int32
    @NSManaged public var displayConfigNode: NodeInfoEntity?
}

extension DisplayConfigEntity: CoreDataEntity {
    public static var entityName: String { "DisplayConfigEntity" }
}
