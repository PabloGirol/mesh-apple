//
//  NetworkConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for NetworkConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(NetworkConfigEntity)
public class NetworkConfigEntity: NSManagedObject {

}

extension NetworkConfigEntity {
    @NSManaged public var ntpServer: String??
    @NSManaged public var wifiEnabled: Bool
    @NSManaged public var wifiPsk: String??
    @NSManaged public var wifiSsid: String??
    @NSManaged public var networkConfigNode: NodeInfoEntity?
}

extension NetworkConfigEntity: CoreDataEntity {
    public static var entityName: String { "NetworkConfigEntity" }
}
