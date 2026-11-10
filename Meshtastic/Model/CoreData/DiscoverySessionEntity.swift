//
//  DiscoverySessionEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DiscoverySessionEntity)
public class DiscoverySessionEntity: NSManagedObject {

}

extension DiscoverySessionEntity {
    public var id: UUID {
        get { value(forKey: "id") as! UUID }
        set { setValue(newValue, forKey: "id") }
    }
    public var startTime: Date {
        get { value(forKey: "startTime") as! Date }
        set { setValue(newValue, forKey: "startTime") }
    }
    public var endTime: Date?? {
        get { value(forKey: "endTime") as? Date? }
        set { setValue(newValue, forKey: "endTime") }
    }
    public var selectedPresets: Data {
        get { value(forKey: "selectedPresets") as! Data }
        set { setValue(newValue, forKey: "selectedPresets") }
    }
    public var dwellDuration: Int32 {
        get { value(forKey: "dwellDuration") as! Int32 }
        set { setValue(newValue, forKey: "dwellDuration") }
    }
    public var completed: Bool {
        get { value(forKey: "completed") as! Bool }
        set { setValue(newValue, forKey: "completed") }
    }
    public var presetResults: NSSet? {
        get { value(forKey: "presetResults") as? NSSet }
        set { setValue(newValue, forKey: "presetResults") }
    }
    public var discoveredNodes: NSSet? {
        get { value(forKey: "discoveredNodes") as? NSSet }
        set { setValue(newValue, forKey: "discoveredNodes") }
    }
    public var discoveredBeacons: NSSet? {
        get { value(forKey: "discoveredBeacons") as? NSSet }
        set { setValue(newValue, forKey: "discoveredBeacons") }
    }

    @objc(addPresetResultsObject:)
    public func addToPresetResults(_ value: DiscoveryPresetResultEntity) {
        mutableSetValue(forKey: "presetResults").add(value)
    }

    @objc(removePresetResultsObject:)
    public func removeFromPresetResults(_ value: DiscoveryPresetResultEntity) {
        mutableSetValue(forKey: "presetResults").remove(value)
    }

    @objc(addPresetResults:)
    public func addToPresetResults(_ values: NSSet) {
        mutableSetValue(forKey: "presetResults").union(values)
    }

    @objc(removePresetResults:)
    public func removeFromPresetResults(_ values: NSSet) {
        mutableSetValue(forKey: "presetResults").minus(values)
    }


    @objc(addDiscoveredNodesObject:)
    public func addToDiscoveredNodes(_ value: DiscoveredNodeEntity) {
        mutableSetValue(forKey: "discoveredNodes").add(value)
    }

    @objc(removeDiscoveredNodesObject:)
    public func removeFromDiscoveredNodes(_ value: DiscoveredNodeEntity) {
        mutableSetValue(forKey: "discoveredNodes").remove(value)
    }

    @objc(addDiscoveredNodes:)
    public func addToDiscoveredNodes(_ values: NSSet) {
        mutableSetValue(forKey: "discoveredNodes").union(values)
    }

    @objc(removeDiscoveredNodes:)
    public func removeFromDiscoveredNodes(_ values: NSSet) {
        mutableSetValue(forKey: "discoveredNodes").minus(values)
    }


    @objc(addDiscoveredBeaconsObject:)
    public func addToDiscoveredBeacons(_ value: DiscoveredBeaconEntity) {
        mutableSetValue(forKey: "discoveredBeacons").add(value)
    }

    @objc(removeDiscoveredBeaconsObject:)
    public func removeFromDiscoveredBeacons(_ value: DiscoveredBeaconEntity) {
        mutableSetValue(forKey: "discoveredBeacons").remove(value)
    }

    @objc(addDiscoveredBeacons:)
    public func addToDiscoveredBeacons(_ values: NSSet) {
        mutableSetValue(forKey: "discoveredBeacons").union(values)
    }

    @objc(removeDiscoveredBeacons:)
    public func removeFromDiscoveredBeacons(_ values: NSSet) {
        mutableSetValue(forKey: "discoveredBeacons").minus(values)
    }

}

extension DiscoverySessionEntity: CoreDataEntity {
    public static var entityName: String { "DiscoverySessionEntity" }
}
