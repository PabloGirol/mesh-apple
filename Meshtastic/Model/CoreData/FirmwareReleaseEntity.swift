//
//  FirmwareReleaseEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(FirmwareReleaseEntity)
public class FirmwareReleaseEntity: NSManagedObject {

}

extension FirmwareReleaseEntity {
    public var channel: String {
        get { value(forKey: "channel") as! String }
        set { setValue(newValue, forKey: "channel") }
    }
    public var version: String {
        get { value(forKey: "version") as! String }
        set { setValue(newValue, forKey: "version") }
    }
    public var releaseDate: Date {
        get { value(forKey: "releaseDate") as! Date }
        set { setValue(newValue, forKey: "releaseDate") }
    }
    public var changelog: String?? {
        get { value(forKey: "changelog") as? String? }
        set { setValue(newValue, forKey: "changelog") }
    }
    public var downloadURL: String {
        get { value(forKey: "downloadURL") as! String }
        set { setValue(newValue, forKey: "downloadURL") }
    }
    public var hardwareModel: String {
        get { value(forKey: "hardwareModel") as! String }
        set { setValue(newValue, forKey: "hardwareModel") }
    }
    public var minAppVersion: Int32 {
        get { value(forKey: "minAppVersion") as! Int32 }
        set { setValue(newValue, forKey: "minAppVersion") }
    }
    public var signature: String?? {
        get { value(forKey: "signature") as? String? }
        set { setValue(newValue, forKey: "signature") }
    }
}

extension FirmwareReleaseEntity: CoreDataEntity {
    public static var entityName: String { "FirmwareReleaseEntity" }
}
