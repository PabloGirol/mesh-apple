//
//  NetworkConfigEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(NetworkConfigEntity)
public class NetworkConfigEntity: NSManagedObject {

	@NSManaged public var addressMode: Int32
	@NSManaged public var dns: Int32
	@NSManaged public var enabledProtocols: Int32
	@NSManaged public var ethEnabled: Bool
	@NSManaged public var gateway: Int32
	@NSManaged public var ip: Int32
	@NSManaged public var ntpServer: String?
	@NSManaged public var rsyslogServer: String?
	@NSManaged public var subnet: Int32
	@NSManaged public var wifiEnabled: Bool
	@NSManaged public var wifiMode: Int32
	@NSManaged public var wifiPsk: String?
	@NSManaged public var wifiSsid: String?
	@NSManaged public var networkConfigNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "NetworkConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.addressMode = 0
		self.dns = 0
		self.enabledProtocols = 0
		self.ethEnabled = false
		self.gateway = 0
		self.ip = 0
		self.ntpServer = nil
		self.rsyslogServer = nil
		self.subnet = 0
		self.wifiEnabled = false
		self.wifiMode = 0
		self.wifiPsk = nil
		self.wifiSsid = nil
		self.networkConfigNode = nil
	}
}