//
//  SecurityConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(SecurityConfigEntity)
public class SecurityConfigEntity: NSManagedObject {

}

extension SecurityConfigEntity {
    public var adminChannelEnabled: Bool {
        get { value(forKey: "adminChannelEnabled") as! Bool }
        set { setValue(newValue, forKey: "adminChannelEnabled") }
    }
    public var adminKey: Data?? {
        get { value(forKey: "adminKey") as? Data? }
        set { setValue(newValue, forKey: "adminKey") }
    }
    public var adminKey2: Data?? {
        get { value(forKey: "adminKey2") as? Data? }
        set { setValue(newValue, forKey: "adminKey2") }
    }
    public var adminKey3: Data?? {
        get { value(forKey: "adminKey3") as? Data? }
        set { setValue(newValue, forKey: "adminKey3") }
    }
    public var bluetoothLoggingEnabled: Bool {
        get { value(forKey: "bluetoothLoggingEnabled") as! Bool }
        set { setValue(newValue, forKey: "bluetoothLoggingEnabled") }
    }
    public var debugLogApiEnabled: Bool {
        get { value(forKey: "debugLogApiEnabled") as! Bool }
        set { setValue(newValue, forKey: "debugLogApiEnabled") }
    }
    public var isManaged: Bool {
        get { value(forKey: "isManaged") as! Bool }
        set { setValue(newValue, forKey: "isManaged") }
    }
    public var packetSignaturePolicy: Int32 {
        get { value(forKey: "packetSignaturePolicy") as! Int32 }
        set { setValue(newValue, forKey: "packetSignaturePolicy") }
    }
    public var privateKey: Data?? {
        get { value(forKey: "privateKey") as? Data? }
        set { setValue(newValue, forKey: "privateKey") }
    }
    public var publicKey: Data?? {
        get { value(forKey: "publicKey") as? Data? }
        set { setValue(newValue, forKey: "publicKey") }
    }
    public var serialEnabled: Bool {
        get { value(forKey: "serialEnabled") as! Bool }
        set { setValue(newValue, forKey: "serialEnabled") }
    }
    public var securityConfigNode: NodeInfoEntity? {
        get { value(forKey: "securityConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "securityConfigNode") }
    }
}

extension SecurityConfigEntity: CoreDataEntity {
    public static var entityName: String { "SecurityConfigEntity" }
}
