//
//  MeshBeaconConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(MeshBeaconConfigEntity)
public class MeshBeaconConfigEntity: NSManagedObject {

}

extension MeshBeaconConfigEntity {
    public var flags: Int32 {
        get { value(forKey: "flags") as! Int32 }
        set { setValue(newValue, forKey: "flags") }
    }
    public var broadcastMessage: String {
        get { value(forKey: "broadcastMessage") as! String }
        set { setValue(newValue, forKey: "broadcastMessage") }
    }
    public var broadcastOfferChannelName: String {
        get { value(forKey: "broadcastOfferChannelName") as! String }
        set { setValue(newValue, forKey: "broadcastOfferChannelName") }
    }
    public var broadcastOfferChannelPSK: Data {
        get { value(forKey: "broadcastOfferChannelPSK") as! Data }
        set { setValue(newValue, forKey: "broadcastOfferChannelPSK") }
    }
    public var broadcastOfferRegion: Int32 {
        get { value(forKey: "broadcastOfferRegion") as! Int32 }
        set { setValue(newValue, forKey: "broadcastOfferRegion") }
    }
    public var broadcastOfferPreset: Int32 {
        get { value(forKey: "broadcastOfferPreset") as! Int32 }
        set { setValue(newValue, forKey: "broadcastOfferPreset") }
    }
    public var broadcastOfferFrequencySlot: Int32 {
        get { value(forKey: "broadcastOfferFrequencySlot") as! Int32 }
        set { setValue(newValue, forKey: "broadcastOfferFrequencySlot") }
    }
    public var broadcastOnChannelName: String {
        get { value(forKey: "broadcastOnChannelName") as! String }
        set { setValue(newValue, forKey: "broadcastOnChannelName") }
    }
    public var broadcastOnChannelPSK: Data {
        get { value(forKey: "broadcastOnChannelPSK") as! Data }
        set { setValue(newValue, forKey: "broadcastOnChannelPSK") }
    }
    public var broadcastOnRegion: Int32 {
        get { value(forKey: "broadcastOnRegion") as! Int32 }
        set { setValue(newValue, forKey: "broadcastOnRegion") }
    }
    public var broadcastOnPreset: Int32 {
        get { value(forKey: "broadcastOnPreset") as! Int32 }
        set { setValue(newValue, forKey: "broadcastOnPreset") }
    }
    public var broadcastIntervalSecs: Int32 {
        get { value(forKey: "broadcastIntervalSecs") as! Int32 }
        set { setValue(newValue, forKey: "broadcastIntervalSecs") }
    }
    public var broadcastSendAsNode: Int64 {
        get { value(forKey: "broadcastSendAsNode") as! Int64 }
        set { setValue(newValue, forKey: "broadcastSendAsNode") }
    }
    public var broadcastTargets: NSSet? {
        get { value(forKey: "broadcastTargets") as? NSSet }
        set { setValue(newValue, forKey: "broadcastTargets") }
    }
    public var meshBeaconConfigNode: NodeInfoEntity? {
        get { value(forKey: "meshBeaconConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "meshBeaconConfigNode") }
    }

    @objc(addBroadcastTargetsObject:)
    public func addToBroadcastTargets(_ value: BroadcastTargetEntity) {
        mutableSetValue(forKey: "broadcastTargets").add(value)
    }

    @objc(removeBroadcastTargetsObject:)
    public func removeFromBroadcastTargets(_ value: BroadcastTargetEntity) {
        mutableSetValue(forKey: "broadcastTargets").remove(value)
    }

    @objc(addBroadcastTargets:)
    public func addToBroadcastTargets(_ values: NSSet) {
        mutableSetValue(forKey: "broadcastTargets").union(values)
    }

    @objc(removeBroadcastTargets:)
    public func removeFromBroadcastTargets(_ values: NSSet) {
        mutableSetValue(forKey: "broadcastTargets").minus(values)
    }

}

extension MeshBeaconConfigEntity: CoreDataEntity {
    public static var entityName: String { "MeshBeaconConfigEntity" }
}
