//
//  AllTraceRoutesLog.swift
//  Meshtastic
//
//  App-wide log of every trace route response we have seen — both routes we initiated
//  and full responses observed passing over the mesh.
//

import SwiftUI
import CoreData
import OSLog

struct AllTraceRoutesLog: View {
	@Environment(\.managedObjectContext) private var context
	@EnvironmentObject var accessoryManager: AccessoryManager

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \TraceRouteEntity.time, ascending: false)],
		animation: .default)
	private var traceRoutes: FetchedResults<TraceRouteEntity>
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \NodeInfoEntity.num, ascending: true)],
		animation: .default)
	private var nodes: FetchedResults<NodeInfoEntity>

	@State private var openRouteID: NSManagedObjectID?

	private var nodeNames: [Int64: String] {
		Dictionary(nodes.map { ($0.num, $0.user?.longName ?? $0.num.toHex()) }, uniquingKeysWith: { first, _ in first })
	}

	var body: some View {
		Group {
			if traceRoutes.isEmpty {
				ContentUnavailableView("No Trace Routes", systemImage: "point.3.connected.trianglepath.dotted")
			} else {
				let names = nodeNames
				List {
					ForEach(traceRoutes, id: \.objectID) { route in
						TraceRouteStateTimeline(route: route) { now in
							Button {
								openRouteID = route.objectID
							} label: {
								TraceRouteCard(
									model: TraceRouteCardModel(route: route, title: title(for: route, names: names), now: now),
									showsOrigin: true
								)
								.contentShape(Rectangle())
							}
							.buttonStyle(.plain)
						}
						.swipeActions {
							Button(role: .destructive) {
								delete(route)
							} label: {
								Label("Delete", systemImage: "trash")
							}
						}
					}
				}
			}
		}
		.navigationTitle("Trace Routes")
		.navigationDestination(item: $openRouteID) { id in
			if let route = traceRoutes.first(where: { $0.objectID == id }) {
				TraceRouteDetail(route: route)
			}
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				ConnectedDevice(deviceConnected: accessoryManager.isConnected, name: accessoryManager.activeConnection?.device.shortName ?? "?")
			}
		}
	}

	private func title(for route: TraceRouteEntity, names: [Int64: String]) -> String {
		let from = names[route.fromNum] ?? route.fromNum.toHex()
		let to = names[route.toNum] ?? route.toNum.toHex()
		return "\(from) → \(to)"
	}

	private func delete(_ route: TraceRouteEntity) {
		if openRouteID == route.objectID {
			openRouteID = nil
		}
		context.delete(route)
		do {
			try context.save()
		} catch let error as NSError {
			Logger.data.error("\(error.localizedDescription, privacy: .public)")
		}
	}
}
