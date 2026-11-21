//
//  NodePositionIntent.swift
//  Meshtastic
//
//  Created by Benjamin Faershtein on 8/10/24.
//

import Foundation
import CoreLocation
import CoreData

#if canImport(AppIntents) && compiler(>=5.9) && !MESHTASTIC_IOS15
import AppIntents

@available(iOS 16.0, *)
struct NodePositionIntent: AppIntent {

	@Parameter(title: "Node Number")
	var nodeNum: Int

	static let title: LocalizedStringResource = "Get Node Position"
	static let description: IntentDescription = "Fetch the latest position of a certain node"

	func perform() async throws -> some IntentResult & ReturnsValue<CLPlacemark> {
		if !(await AccessoryManager.shared.isConnected) {
			throw AppIntentErrors.AppIntentError.notConnected
		}
		let nodeNumInt64 = Int64(nodeNum)
		let request = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
		request.predicate = NSPredicate(format: "num == %lld", nodeNumInt64)
		request.fetchLimit = 1
		do {
			let fetchedNode = try MainActor.run { try CoreDataStackImpl.shared.container.viewContext.fetch(request) }
			guard fetchedNode.count == 1 else {
				throw $nodeNum.needsValueError("Could not find node")
			}
			let nodeInfo = fetchedNode[0]
			if let coord = nodeInfo.latestPosition?.nodeCoordinate {
				let nodeLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
				// Reverse geocode the CLLocation to get a CLPlacemark
				let geocoder = CLGeocoder()
				let placemarks = try await geocoder.reverseGeocodeLocation(nodeLocation)

				if let placemark = placemarks.first {
					return .result(value: placemark)
				} else {
					throw AppIntentErrors.AppIntentError.message("Error Reverse Geocoding Location")
				}
			} else {
				throw AppIntentErrors.AppIntentError.message("Node does not have positions")
			}
		} catch {
			throw AppIntentErrors.AppIntentError.message("Fetch Failure")
		}
	}
}
#endif