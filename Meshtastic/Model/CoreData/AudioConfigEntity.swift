//
//  AudioConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(AudioConfigEntity)
public class AudioConfigEntity: NSManagedObject {

}

extension AudioConfigEntity {
    public var codec2Enabled: Bool {
        get { value(forKey: "codec2Enabled") as! Bool }
        set { setValue(newValue, forKey: "codec2Enabled") }
    }
    public var pttPin: Int32 {
        get { value(forKey: "pttPin") as! Int32 }
        set { setValue(newValue, forKey: "pttPin") }
    }
    public var bitrate: Int32 {
        get { value(forKey: "bitrate") as! Int32 }
        set { setValue(newValue, forKey: "bitrate") }
    }
    public var i2sWs: Int32 {
        get { value(forKey: "i2sWs") as! Int32 }
        set { setValue(newValue, forKey: "i2sWs") }
    }
    public var i2sSd: Int32 {
        get { value(forKey: "i2sSd") as! Int32 }
        set { setValue(newValue, forKey: "i2sSd") }
    }
    public var i2sDin: Int32 {
        get { value(forKey: "i2sDin") as! Int32 }
        set { setValue(newValue, forKey: "i2sDin") }
    }
    public var i2sSck: Int32 {
        get { value(forKey: "i2sSck") as! Int32 }
        set { setValue(newValue, forKey: "i2sSck") }
    }
    public var audioConfigNode: NodeInfoEntity? {
        get { value(forKey: "audioConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "audioConfigNode") }
    }
}

extension AudioConfigEntity: CoreDataEntity {
    public static var entityName: String { "AudioConfigEntity" }
}
