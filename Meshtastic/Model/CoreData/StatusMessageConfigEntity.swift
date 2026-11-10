//
//  StatusMessageConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(StatusMessageConfigEntity)
public class StatusMessageConfigEntity: NSManagedObject {

}

extension StatusMessageConfigEntity {
    public var nodeStatus: String {
        get { value(forKey: "nodeStatus") as! String }
        set { setValue(newValue, forKey: "nodeStatus") }
    }
    public var statusMessageConfigNode: NodeInfoEntity? {
        get { value(forKey: "statusMessageConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "statusMessageConfigNode") }
    }
}

extension StatusMessageConfigEntity: CoreDataEntity {
    public static var entityName: String { "StatusMessageConfigEntity" }
}
