//
//  WaypointEntity.swift
//  Meshtastic
//
//  SwiftData model for waypoints.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(WaypointEntity)
public class WaypointEntity: NSManagedObject {

	@NSManaged public var created: Date?
	@NSManaged public var createdBy: Int64
	@NSManaged public var expire: Date?
	@NSManaged public var icon: Int64
	@NSManaged public var id: Int64
	@NSManaged public var lastUpdated: Date?
	@NSManaged public var lastUpdatedBy: Int64
	@NSManaged public var latitudeI: Int32
	@NSManaged public var locked: Bool
	/// A local-only waypoint the user created on this device: it is never broadcast
	/// over the mesh, and the mesh ingest never overwrites it (see MeshPackets.waypointPacket).
	@NSManaged public var isLocal: Bool
	@NSManaged public var longDescription: String?
	@NSManaged public var longitudeI: Int32
	@NSManaged public var name: String?

	// MARK: Geofence (mirrors the Waypoint protobuf geofence fields)

	/// Circular geofence radius in meters, centred on the waypoint's own location. 0 = no circle.
	@NSManaged public var geofenceRadius: Int
	/// Whether a rectangular bounding-box geofence is set (mirrors Waypoint.hasBoundingBox).
	@NSManaged public var hasBoundingBox: Bool
	/// Bounding-box corners as degrees × 1e7 (sfixed32), matching latitudeI / longitudeI.
	@NSManaged public var boundingBoxLatitudeNorthI: Int32
	@NSManaged public var boundingBoxLatitudeSouthI: Int32
	@NSManaged public var boundingBoxLongitudeEastI: Int32
	@NSManaged public var boundingBoxLongitudeWestI: Int32
	/// Raise a local notification when a tracked node enters / exits this geofence.
	@NSManaged public var notifyOnEnter: Bool
	@NSManaged public var notifyOnExit: Bool
	/// When set, only raise enter/exit notifications for nodes marked as favorites on this receiver.
	@NSManaged public var notifyFavoritesOnly: Bool

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "WaypointEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.created = nil
		self.createdBy = 0
		self.expire = nil
		self.icon = 0
		self.id = 0
		self.lastUpdated = nil
		self.lastUpdatedBy = 0
		self.latitudeI = 0
		self.locked = false
		self.isLocal = false
		self.longDescription = nil
		self.longitudeI = 0
		self.name = nil
		self.geofenceRadius = 0
		self.hasBoundingBox = false
		self.boundingBoxLatitudeNorthI = 0
		self.boundingBoxLatitudeSouthI = 0
		self.boundingBoxLongitudeEastI = 0
		self.boundingBoxLongitudeWestI = 0
		self.notifyOnEnter = false
		self.notifyOnExit = false
		self.notifyFavoritesOnly = false
	}
}