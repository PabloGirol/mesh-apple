//
//  DeviceMetadataEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for device metadata.
//  Converted from SwiftData for iOS 15 compatibility.
//

import Foundation
import CoreData
import MeshtasticProtobufs

@objc(DeviceMetadataEntity)
public class DeviceMetadataEntity: NSManagedObject {

	@NSManaged public var canShutdown: Bool
	@NSManaged public var deviceStateVersion: Int32
	@NSManaged public var excludedModules: Int32
	@NSManaged public var firmwareVersion: String?
	@NSManaged public var hasBluetooth: Bool
	@NSManaged public var hasEthernet: Bool
	@NSManaged public var hasWifi: Bool
	/// Whether this firmware build includes XEdDSA packet signature verification.
	/// Read-only capability: gates the Packet Authenticity policy selector in Security config.
	@NSManaged public var hasXeddsa: Bool
	@NSManaged public var hwModel: String?
	@NSManaged public var positionFlags: Int32
	@NSManaged public var role: Int32
	@NSManaged public var time: Date?
	/// The radio's screen, from `DeviceMetadata.display`. Zero width and height mean the radio
	/// reported no display: it has none, was built without screen mirroring, or runs older firmware.
	@NSManaged public var displayWidth: Int32
	@NSManaged public var displayHeight: Int32
	/// Raw `DisplayFrame.Format` the radio's frames will use.
	@NSManaged public var displayFormat: Int32
	/// Raw `DisplayInfo.PanelClass`.
	@NSManaged public var displayPanelClass: Int32
	@NSManaged public var displayHasTouch: Bool

	@NSManaged public var metadataNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DeviceMetadataEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.canShutdown = false
		self.deviceStateVersion = 0
		self.excludedModules = 0
		self.firmwareVersion = nil
		self.hasBluetooth = false
		self.hasEthernet = false
		self.hasWifi = false
		self.hasXeddsa = false
		self.hwModel = nil
		self.positionFlags = 0
		self.role = 0
		self.time = nil
		self.displayWidth = 0
		self.displayHeight = 0
		self.displayFormat = 0
		self.displayPanelClass = 0
		self.displayHasTouch = false
		self.metadataNode = nil
	}

	/// Whether the radio can stream its screen to the app.
	var hasDisplay: Bool {
		displayWidth > 0 && displayHeight > 0
	}

	func update(from metadata: DeviceMetadata) {
		time = Date()
		deviceStateVersion = Int32(metadata.deviceStateVersion)
		canShutdown = metadata.canShutdown
		hasWifi = metadata.hasWifi_p
		hasBluetooth = metadata.hasBluetooth_p
		hasEthernet = metadata.hasEthernet_p
		hasXeddsa = metadata.hasXeddsa_p
		role = Int32(metadata.role.rawValue)
		positionFlags = Int32(truncatingIfNeeded: metadata.positionFlags)
		excludedModules = Int32(truncatingIfNeeded: metadata.excludedModules)
		// Clear the display when it's absent so a downgrade doesn't leave a stale screen behind.
		let display = metadata.hasDisplay ? metadata.display : MeshtasticProtobufs.DisplayInfo()
		displayWidth = Int32(truncatingIfNeeded: display.width)
		displayHeight = Int32(truncatingIfNeeded: display.height)
		displayFormat = Int32(display.format.rawValue)
		displayPanelClass = Int32(display.panelClass.rawValue)
		displayHasTouch = display.hasTouch_p

		let lastDotIndex = metadata.firmwareVersion.lastIndex(of: ".")
		var version = metadata.firmwareVersion[...(lastDotIndex ?? String.Index(utf16Offset: 6, in: metadata.firmwareVersion))]
		version = version.dropLast()
		firmwareVersion = String(version)
	}
}