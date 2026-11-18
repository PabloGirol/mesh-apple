//
//  NeighborLinkEntity.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 10/15/26.
//  Converted to Core Data NSManagedObject subclass for iOS 15 compatibility.
//

import Foundation
import OSLog
import CoreData

/// One entry from a Neighbor Info report: `reporterNum` heard `neighborNum` directly, at `snr` dB.
///
/// The link is one way. It is the neighbor's signal as the reporter hears it, not the other way
/// round. Nodes are stored as plain numbers with no relationship to `NodeInfoEntity`, so saving a
/// report never loads a node's other rows, and the rows survive a node being deleted or
/// renumbered until the clean-up code below removes or rewrites them.
@objc(NeighborLinkEntity)
public class NeighborLinkEntity: NSManagedObject {

	/// `"reporterNum:neighborNum"`, so each reporter has at most one row per neighbor.
	@NSManaged public var key: String
	@NSManaged public var reporterNum: Int64
	@NSManaged public var neighborNum: Int64
	/// SNR in dB, measured by the reporter.
	@NSManaged public var snr: Float
	/// When the report arrived. Reports don't say how old each entry is.
	@NSManaged public var receivedAt: Date
	/// How often the reporter says it sends a report. Used to decide when a row is too old.
	@NSManaged public var reporterIntervalSecs: Int32
	/// Whether the report reached us over MQTT rather than from the radio's own LoRa.
	@NSManaged public var viaMqtt: Bool

	convenience init(context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "NeighborLinkEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.key = ""
		self.reporterNum = 0
		self.neighborNum = 0
		self.snr = 0
		self.receivedAt = Date.distantPast
		self.reporterIntervalSecs = 0
		self.viaMqtt = false
	}
}

extension NeighborLinkEntity {
	static func key(reporter: Int64, neighbor: Int64) -> String {
		"\(reporter):\(neighbor)"
	}

	/// Rows that mention any of `nodeNums`, on either side.
	static func predicate(involving nodeNums: [Int64]) -> NSPredicate {
		NSPredicate(format: "reporterNum IN %@ OR neighborNum IN %@", nodeNums, nodeNums)
	}

	/// Deletes the rows of nodes that are being deleted. Does not save.
	static func deleteAll(forNodes nodeNums: [Int64], in context: NSManagedObjectContext) {
		guard !nodeNums.isEmpty else { return }
		let request = NSFetchRequest<NeighborLinkEntity>(entityName: "NeighborLinkEntity")
		request.predicate = predicate(involving: nodeNums)
		do {
			for row in try context.fetch(request) {
				context.delete(row)
			}
		} catch {
			Logger.data.error("💥 [NeighborLinkEntity] Failed to delete neighbor links for removed nodes: \(error.localizedDescription, privacy: .public)")
		}
	}
}