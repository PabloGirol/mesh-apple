//
//  RouteModels.swift
//  Meshtastic
//
//  Core Data models for routes, locations, and PaxCounter.
//  Converted from SwiftData for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(RouteEntity)
public class RouteEntity: NSManagedObject {

	@NSManaged public var color: Int64
	@NSManaged public var date: Date?
	@NSManaged public var distance: Double
	@NSManaged public var elevationGain: Double
	@NSManaged public var enabled: Bool
	@NSManaged public var endDate: Date?
	@NSManaged public var id: Int32
	@NSManaged public var name: String?
	@NSManaged public var notes: String?

	// locations relationship becomes @NSManaged array
	@NSManaged public var locations: [LocationEntity]

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "RouteEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.color = 0
		self.date = nil
		self.distance = 0
		self.elevationGain = 0
		self.enabled = false
		self.endDate = nil
		self.id = 0
		self.name = nil
		self.notes = nil
		self.locations = []
	}
}

@objc(LocationEntity)
public class LocationEntity: NSManagedObject {

	@NSManaged public var altitude: Int32
	@NSManaged public var heading: Int32
	@NSManaged public var id: Int32
	@NSManaged public var latitudeI: Int32
	@NSManaged public var longitudeI: Int32
	@NSManaged public var speed: Int32

	// routeLocation becomes @NSManaged optional
	@NSManaged public var routeLocation: RouteEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "LocationEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.altitude = 0
		self.heading = 0
		self.id = 0
		self.latitudeI = 0
		self.longitudeI = 0
		self.speed = 0
		self.routeLocation = nil
	}
}

@objc(PaxCounterEntity)
public class PaxCounterEntity: NSManagedObject {

	@NSManaged public var ble: Int32
	@NSManaged public var time: Date?
	@NSManaged public var uptime: Int32
	@NSManaged public var wifi: Int32

	// paxNode becomes @NSManaged optional
	@NSManaged public var paxNode: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "PaxCounterEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.ble = 0
		self.time = nil
		self.uptime = 0
		self.wifi = 0
		self.paxNode = nil
	}
}