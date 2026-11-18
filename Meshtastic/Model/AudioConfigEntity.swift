//
//  AudioConfigEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for audio configuration.
//  Converted from SwiftData @Model for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(AudioConfigEntity)
public class AudioConfigEntity: NSManagedObject {

    @NSManaged public var codec2Enabled: Bool
    @NSManaged public var pttPin: Int32
    @NSManaged public var bitrate: Int32
    @NSManaged public var i2sWs: Int32
    @NSManaged public var i2sSd: Int32
    @NSManaged public var i2sDin: Int32
    @NSManaged public var i2sSck: Int32
    @NSManaged public var audioConfigNode: NodeInfoEntity?

    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "AudioConfigEntity", in: context)!
        self.init(entity: entity, insertInto: context)
        self.codec2Enabled = false
        self.pttPin = 0
        self.bitrate = 0
        self.i2sWs = 0
        self.i2sSd = 0
        self.i2sDin = 0
        self.i2sSck = 0
        self.audioConfigNode = nil
    }
}