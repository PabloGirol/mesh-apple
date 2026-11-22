//
//  TraceRouteDetail.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 10/13/26.
//

import CoreData
import SwiftUI

/// One trace route: the summary card, a row of actions, then the hop timeline when it came back
/// (otherwise what happened to the request) and the round trip and hop counts.
struct TraceRouteDetail: View {
	@Environment(\.managedObjectContext) private var context
	@EnvironmentObject var router: Router
	@EnvironmentObject var accessoryManager: AccessoryManager

	let route: TraceRouteEntity

	@State private var selectedNodeNum: Int64?
	@State private var shareImage: TraceRouteShareImage?
	@State private var isRenderingShareImage = false

	private var preset: ModemPresets { ModemPresets(rawValue: UserDefaults.modemPreset) ?? .longFast }

	var body: some View {
		TraceRouteStateTimeline(route: route) { now in
			let state = route.state(now: now)
			List {
				Section {
					TraceRouteCard(model: TraceRouteCardModel(route: route, title: title, now: now))
						.contextMenu {
							if let shareImage {
								if #available(iOS 16.0, *) {
									shareLink(shareImage)
								}
							}
							copyButton
						}
				}
				actions(state: state)
				switch state {
				case .complete, .observed:
					Section {
						TraceRouteHopTimeline(
							legs: legs,
							canSelectStop: { num in num != accessoryManager.activeDeviceNum && findNode(num) != nil },
							onSelectStop: { selectedNodeNum = $0 }
						)
						.padding(.vertical, 8)
					}
				case .pending, .noResponse, .rateLimited:
					Section {
						stateMessage(state)
					}
				}
				details(state: state)
			}
		}
		.navigationTitle("Trace Route")
		.navigationBarTitleDisplayMode(.inline)
		.task(id: shareImageKey) {
			await renderShareImage()
		}
		.navigationDestination(item: $selectedNodeNum) { num in
			if let node = findNode(num) {
				NodeDetail(node: node, nodeNum: num)
			}
		}
	}

	private var targetName: String {
		route.node?.user?.longName ?? findNode(route.toNum)?.user?.longName ?? route.toNum.toHex()
	}

	private var title: String {
		let origin = findNode(route.fromNum)?.user?.longName ?? route.fromNum.toHex()
		return "\(origin) → \(targetName)"
	}

	private var legs: TraceRouteLegs {
		TraceRouteLegs(route: route, preset: preset) { num in
			findNode(num)?.user?.longName ?? num.toHex()
		}
	}

	private var shareImageKey: Int64 {
		var key = route.id
		key = key &* 31 &+ route.time
		if let shareImage {
			key = key &* 31 &+ Int64(shareImage.timestamp.timeIntervalSince1970)
		}
		return key
	}

	@MainActor
	private func renderShareImage() async {
		let model = TraceRouteShareModel(
			route: route,
			preset: preset,
			findNodeName: { num in findNode(num)?.user?.longName ?? num.toHex() }
		)
		do {
			let image = try await model.renderImage()
			shareImage = TraceRouteShareImage(image: image, timestamp: Date())
			isRenderingShareImage = false
		} catch {
			Logger.ui.error("Failed to render trace route share image: \(error.localizedDescription)")
			isRenderingShareImage = false
		}
	}

	private func findNode(_ num: Int64) -> NodeInfoEntity? {
		guard num != accessoryManager.activeDeviceNum else { return nil }
		let request = NSFetchRequest<NodeInfoEntity>(entityName: "NodeInfoEntity")
		request.predicate = NSPredicate(format: "num == %lld", num)
		request.fetchLimit = 1
		return try? context.fetch(request).first
	}

	private func actions(state: TraceRouteState) -> some View {
		Section {
			if state == .complete || state == .observed {
				Button {
					Task { await renderShareImage() }
				} label: {
					Label("Share", systemImage: "square.and.arrow.up")
				}
				.disabled(isRenderingShareImage)
			}
			Button {
				copyTraceRoute()
			} label: {
				Label("Copy", systemImage: "doc.on.doc")
			}
		}
	}

	private var copyButton: some View {
		Button {
			copyTraceRoute()
		} label: {
			Label("Copy", systemImage: "doc.on.doc")
		}
	}

	private var shareLink: (TraceRouteShareImage) -> some View = { shareImage in
		if #available(iOS 16.0, *) {
			ShareLink(item: shareImage.image, preview: SharePreview("Trace Route", image: shareImage.image))
		} else {
			EmptyView()
		}
	}

	private func copyTraceRoute() {
		let text = traceRouteToText(route: route, preset: preset, findNodeName: { num in findNode(num)?.user?.longName ?? num.toHex() })
		UIPasteboard.general.string = text
	}

	private func stateMessage(_ state: TraceRouteState) -> some View {
		switch state {
		case .pending:
			Text("Trace route request sent, waiting for response...")
		case .noResponse:
			Text("No response received. The target may be out of range or offline.")
		case .rateLimited:
			Text("Rate limited. Try again in a moment.")
		case .complete, .observed:
			EmptyView()
		}
	}

	private func details(state: TraceRouteState) -> some View {
		Section {
			DetailRow(title: "State", value: state.description)
			if state == .complete || state == .observed {
				DetailRow(title: "Round Trip", value: route.roundTripMs.map { "\($0) ms" } ?? "—")
				DetailRow(title: "Hops", value: "\(route.hopCount)")
			}
			DetailRow(title: "Requested", value: route.sentAt.formatted(date: .abbreviated, time: .standard))
			if let time = route.time {
				DetailRow(title: "Completed", value: time.formatted(date: .abbreviated, time: .standard))
			}
		}
	}
}

private struct DetailRow: View {
	let title: String
	let value: String

	var body: some View {
		HStack {
			Text(title)
				.foregroundStyle(.secondary)
			Spacer()
			Text(value)
				.font(.callout.monospacedDigit())
		}
	}
}