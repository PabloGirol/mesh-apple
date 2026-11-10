//
//  DisplayConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DisplayConfigEntity)
public class DisplayConfigEntity: NSManagedObject {

}

extension DisplayConfigEntity {
    public var compassNorthTop: Bool {
        get { value(forKey: "compassNorthTop") as! Bool }
        set { setValue(newValue, forKey: "compassNorthTop") }
    }
    public var compassOrientation: Int32 {
        get { value(forKey: "compassOrientation") as! Int32 }
        set { setValue(newValue, forKey: "compassOrientation") }
    }
    public var displayMode: Int32 {
        get { value(forKey: "displayMode") as! Int32 }
        set { setValue(newValue, forKey: "displayMode") }
    }
    public var flipScreen: Bool {
        get { value(forKey: "flipScreen") as! Bool }
        set { setValue(newValue, forKey: "flipScreen") }
    }
    public var headingBold: Bool {
        get { value(forKey: "headingBold") as! Bool }
        set { setValue(newValue, forKey: "headingBold") }
    }
    public var oledType: Int32 {
        get { value(forKey: "oledType") as! Int32 }
        set { setValue(newValue, forKey: "oledType") }
    }
    public var screenCarouselInterval: Int32 {
        get { value(forKey: "screenCarouselInterval") as! Int32 }
        set { setValue(newValue, forKey: "screenCarouselInterval") }
    }
    public var screenOnSeconds: Int32 {
        get { value(forKey: "screenOnSeconds") as! Int32 }
        set { setValue(newValue, forKey: "screenOnSeconds") }
    }
    public var units: Int32 {
        get { value(forKey: "units") as! Int32 }
        set { setValue(newValue, forKey: "units") }
    }
    public var use12HClock: Bool {
        get { value(forKey: "use12HClock") as! Bool }
        set { setValue(newValue, forKey: "use12HClock") }
    }
    public var wakeOnTapOrMotion: Bool {
        get { value(forKey: "wakeOnTapOrMotion") as! Bool }
        set { setValue(newValue, forKey: "wakeOnTapOrMotion") }
    }
    public var displayConfigNode: NodeInfoEntity? {
        get { value(forKey: "displayConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "displayConfigNode") }
    }
}

extension DisplayConfigEntity: CoreDataEntity {
    public static var entityName: String { "DisplayConfigEntity" }
}
