//
//  DeviceHardwareEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DeviceHardwareEntity)
public class DeviceHardwareEntity: NSManagedObject {

}

extension DeviceHardwareEntity {
    public var hwModel: String {
        get { value(forKey: "hwModel") as! String }
        set { setValue(newValue, forKey: "hwModel") }
    }
    public var variant: String?? {
        get { value(forKey: "variant") as? String? }
        set { setValue(newValue, forKey: "variant") }
    }
    public var tags: NSSet? {
        get { value(forKey: "tags") as? NSSet }
        set { setValue(newValue, forKey: "tags") }
    }
    public var images: NSSet? {
        get { value(forKey: "images") as? NSSet }
        set { setValue(newValue, forKey: "images") }
    }

    @objc(addTagsObject:)
    public func addToTags(_ value: DeviceHardwareTagEntity) {
        mutableSetValue(forKey: "tags").add(value)
    }

    @objc(removeTagsObject:)
    public func removeFromTags(_ value: DeviceHardwareTagEntity) {
        mutableSetValue(forKey: "tags").remove(value)
    }

    @objc(addTags:)
    public func addToTags(_ values: NSSet) {
        mutableSetValue(forKey: "tags").union(values)
    }

    @objc(removeTags:)
    public func removeFromTags(_ values: NSSet) {
        mutableSetValue(forKey: "tags").minus(values)
    }


    @objc(addImagesObject:)
    public func addToImages(_ value: DeviceHardwareImageEntity) {
        mutableSetValue(forKey: "images").add(value)
    }

    @objc(removeImagesObject:)
    public func removeFromImages(_ value: DeviceHardwareImageEntity) {
        mutableSetValue(forKey: "images").remove(value)
    }

    @objc(addImages:)
    public func addToImages(_ values: NSSet) {
        mutableSetValue(forKey: "images").union(values)
    }

    @objc(removeImages:)
    public func removeFromImages(_ values: NSSet) {
        mutableSetValue(forKey: "images").minus(values)
    }

}

extension DeviceHardwareEntity: CoreDataEntity {
    public static var entityName: String { "DeviceHardwareEntity" }
}
