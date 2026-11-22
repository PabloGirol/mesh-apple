//
//  TraceRouteModels.swift
//  Meshtastic
//
//  SwiftData models for trace routes and hops.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import CoreData

@objc(TraceRouteEntity)
public class TraceRouteEntity: NSManagedObject, CoreDataEntity {

	@NSManaged public var hasPositions: Bool
	@NSManaged public var hopsBack: Int32
	@NSManaged public var hopsTowards: Int32
	@NSManaged public var id: Int64
	@NSManaged public var response: Bool
	/// The radio refused to send this request because of its trace route cooldown.
	@NSManaged public var rateLimited: Bool
	@NSManaged public var routeBackText: String?
	@NSManaged public var routeText: String?
	@NSManaged public var sent: Bool
	@NSManaged public var snr: Float
	/// When the response arrived (or, before one does, when the request was sent).
	@NSManaged public var time: Date?
	/// When we sent the request. Nil for routes observed on the mesh and for older records.
	@NSManaged public var sentAt: Date?
	/// Node num that originated the trace route request (our connected node for requests we
	/// initiated, otherwise the requester of a trace route we observed on the mesh).
	@NSManaged public var fromNum: Int64
	/// Node num of the trace route target/responder (matches `node.num` for requests we initiated).
	@NSManaged public var toNum: Int64

	@NSManaged public var hops: [TraceRouteHopEntity]

	/// Point-in-time snapshot of each involved node's position, captured when the response was
	/// received. One entry per unique node num (see `TraceRouteNodePositionEntity`).
	@NSManaged public var nodePositions: [TraceRouteNodePositionEntity]

	@NSManaged public var node: NodeInfoEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "TraceRouteEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.hasPositions = false
		self.hopsBack = 0
		self.hopsTowards = 0
		self.id = 0
		self.response = false
		self.rateLimited = false
		self.routeBackText = nil
		self.routeText = nil
		self.sent = false
		self.snr = 0.0
		self.time = nil
		self.sentAt = nil
		self.fromNum = 0
		self.toNum = 0
		self.hops = []
		self.nodePositions = []
		self.node = nil
	}
}

extension TraceRouteEntity {
	/// True when this trace route was observed on the mesh rather than initiated by us.
	var observed: Bool { !sent }
}

@objc(TraceRouteHopEntity)
public class TraceRouteHopEntity: NSManagedObject, CoreDataEntity {

	@NSManaged public var back: Bool
	/// Position of this hop within its direction's ordered path (the `hops` relationship is
	/// unordered, so this preserves the originator → … → target sequence for rendering).
	@NSManaged public var index: Int32
	@NSManaged public var name: String?
	@NSManaged public var num: Int64
	@NSManaged public var snr: Float
	@NSManaged public var time: Date?

	@NSManaged public var traceRoute: TraceRouteEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "TraceRouteHopEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.back = false
		self.index = 0
		self.name = nil
		self.num = 0
		self.snr = 0.0
		self.time = nil
		self.traceRoute = nil
	}
}

/// A snapshot of a single node's position at the moment a trace route response was received.
/// Mirrors the meaningful fields of `PositionEntity` so the route can be mapped using the
/// positions nodes had *when the trace route ran*, independent of their later movement.
@objc(TraceRouteNodePositionEntity)
public class TraceRouteNodePositionEntity: NSManagedObject, CoreDataEntity {

	@NSManaged public var num: Int64
	@NSManaged public var altitude: Int32
	@NSManaged public var heading: Int32
	@NSManaged public var latitudeI: Int32
	@NSManaged public var longitudeI: Int32
	@NSManaged public var precisionBits: Int32
	@NSManaged public var satsInView: Int32
	@NSManaged public var seqNo: Int32
	@NSManaged public var snr: Float
	@NSManaged public var speed: Int32
	@NSManaged public var time: Date?

	@NSManaged public var traceRoute: TraceRouteEntity?

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "TraceRouteNodePositionEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.num = 0
		self.altitude = 0
		self.heading = 0
		self.latitudeI = 0
		self.longitudeI = 0
		self.precisionBits = 32
		self.satsInView = 0
		self.seqNo = 0
		self.snr = 0.0
		self.speed = 0
		self.time = nil
		self.traceRoute = nil
	}
}