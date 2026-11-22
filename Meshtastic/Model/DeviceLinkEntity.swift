//
//  DeviceLinkEntity.swift
//  Meshtastic
//
//  SwiftData model for device link catalog.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(DeviceLinkEntity)
public class DeviceLinkEntity: NSManagedObject {

	/// Short code from the msh.to URL catalog
	/// NOTE: Core Data unique constraints are defined in the model file (.xcdatamodeld), not as @Attribute
	@NSManaged public var shortCode: String
	/// Canonical msh.to redirect URL. The API no longer returns the destination directly,
	/// so this is `https://msh.to/{shortCode}` (the redirect service resolves the target).
	@NSManaged public var originalUrl: String
	/// Human-readable description from the catalog
	@NSManaged public var linkDescription: String?
	/// True for `Type == "Vendor"` (official manufacturer link)
	@NSManaged public var isVendor: Bool
	/// True for `Type == "Marketplace"` (third-party retailer/reseller link)
	@NSManaged public var isMarketplace: Bool
	/// Device `platformioTarget` values this link applies to (from the API `Targets` field)
	@NSManaged public var targets: [String]
	/// Region codes this marketplace ships to (empty = worldwide). Only meaningful when
	/// `isMarketplace` is true; non-marketplace links leave this empty.
	///
	/// NOTE: This is intentionally a non-optional `[String]`. SwiftData/Core Data cannot
	/// materialize an *optional* array of a value type (`[String]?`) — it faults with
	/// "Could not materialize Objective-C class named \"Array\" ...", which crashes any
	/// `context.save()` that flushes one of these rows (e.g. sending a message). The
	/// "is this a marketplace?" distinction that `nil` used to encode is carried by
	/// `isMarketplace` instead. See issue #1949.
	@NSManaged public var regions: [String]

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "DeviceLinkEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.shortCode = ""
		self.originalUrl = ""
		self.linkDescription = nil
		self.isVendor = false
		self.isMarketplace = false
		self.targets = []
		self.regions = []
	}

	convenience init(
		shortCode: String,
		originalUrl: String = "",
		linkDescription: String? = nil,
		isVendor: Bool = false,
		isMarketplace: Bool = false,
		targets: [String] = [],
		regions: [String] = []
	) {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		let entity = NSEntityDescription.entity(forEntityName: "DeviceLinkEntity", in: context)!
		self.init(entity: entity, insertInto: nil as NSManagedObjectContext?)
		self.shortCode = shortCode
		self.originalUrl = originalUrl
		self.linkDescription = linkDescription
		self.isVendor = isVendor
		self.isMarketplace = isMarketplace
		self.targets = targets
		self.regions = regions
	}

	/// Whether this link should be shown for a device with `platformioTarget` when the
	/// user is in `userRegion`. Marketplace links are region-gated (shown only where the
	/// retailer ships); vendor links and worldwide marketplaces (empty `regions`) always
	/// show for a matching target. Shared by `DeviceLinksSection` and its tests so the
	/// visibility rule has a single source of truth.
	func isVisible(forTarget platformioTarget: String, userRegion: String) -> Bool {
		guard targets.contains(platformioTarget) else { return false }
		guard isMarketplace, !regions.isEmpty else { return true }
		return regions.contains(userRegion)
	}
}