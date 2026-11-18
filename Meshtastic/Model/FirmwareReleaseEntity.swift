//
//  FirmwareReleaseEntity.swift
//  Meshtastic
//
//  Core Data NSManagedObject subclass for firmware releases.
//  Converted from SwiftData for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(FirmwareReleaseEntity)
public class FirmwareReleaseEntity: NSManagedObject {

	@NSManaged public var pageUrl: String?
	@NSManaged public var releaseNotes: String?
	@NSManaged public var releaseType: String?
	@NSManaged public var title: String?
	@NSManaged public var versionId: String
	@NSManaged public var versionMajor: Int32
	@NSManaged public var versionMinor: Int32
	@NSManaged public var versionPatch: Int32

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "FirmwareReleaseEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.pageUrl = nil
		self.releaseNotes = nil
		self.releaseType = nil
		self.title = nil
		self.versionId = ""
		self.versionMajor = 0
		self.versionMinor = 0
		self.versionPatch = 0
	}
}