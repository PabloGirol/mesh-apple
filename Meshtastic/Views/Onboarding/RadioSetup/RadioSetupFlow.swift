//
//  RadioSetupFlow.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 11/2/26.
//
//  The guided setup for a connected radio: region, preset and name. Opens on its own the
//  first time a radio with no region connects, and from the Set Up Radio rows on Connect and
//  Settings.
//

import CoreData
import SwiftUI
import NavigationStackShim

/// Which radio to set up; presenting one of these opens the flow.
struct RadioSetupRequest: Identifiable {
	let nodeNum: Int64
	var id: Int64 { nodeNum }
}

private struct OpenRadioSetupKey: EnvironmentKey {
	static let defaultValue: (Int64) -> Void = { _ in }
}

extension EnvironmentValues {
	/// Opens the radio setup flow for a node number. ContentView provides it.
	var openRadioSetup: (Int64) -> Void {
		get { self[OpenRadioSetupKey.self] }
		set { self[OpenRadioSetupKey.self] = newValue }
	}
}

struct RadioSetupFlow: View {
	let nodeNum: Int64
	/// Closes the flow where it isn't a sheet, like on the cinema's screen. Nil dismisses.
	var onClose: (() -> Void)?

	@EnvironmentObject private var accessoryManager: AccessoryManager
	@Environment(\.managedObjectContext) private var context
	@Environment(\.dismiss) private var dismiss
	@State private var model: RadioSetupModel?
	@State private var hasLoaded = false

	var body: some View {
		Group {
			if let model {
				RadioSetupPages(model: model, onFinished: close)
			} else if hasLoaded {
				// The node is not in the store, which only happens when a reset emptied it.
				VStack(spacing: 16) {
					Image(systemName: "antenna.radiowaves.left.and.right.slash")
						.font(.system(size: 48))
						.foregroundColor(.secondary)
					Text("Radio Not Found")
						.font(.title2)
						.foregroundColor(.secondary)
					Button("Close", action: close)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				ProgressView()
			}
		}
		.onAppear {
			guard !hasLoaded else { return }
			model = RadioSetupModel(nodeNum: nodeNum, context: context, accessoryManager: accessoryManager)
			hasLoaded = true
		}
		// A different radio took over mid-flow; its settings are not the ones on screen.
		.onChange(of: accessoryManager.activeDeviceNum) { _, num in
			if let num, num != nodeNum { close() }
		}
		.onChange(of: accessoryManager.state) { _, state in
			if state == .subscribed { model?.isAwaitingReconnect = false }
		}
		.interactiveDismissDisabled(model?.isSaving == true)
	}

	private func close() {
		if let onClose { onClose() } else { dismiss() }
	}
}

/// The pages on a navigation stack driven by the model's `path`. Apart from the flow so
/// snapshots can render it from plain values.
struct RadioSetupPages: View {
	@Bindable var model: RadioSetupModel
	let onFinished: () -> Void

	/// iOS 15: Current step for explicit navigation (since NavigationPath doesn't exist)
	@State private var currentStep: RadioSetupStep? = nil

	/// Advance to the next step in the flow.
	private func advance(from step: RadioSetupStep) {
		guard let next = RadioSetupModel.nextStep(after: step, isLicensed: model.isLicensed) else { return }
		currentStep = next
	}

	var body: some View {
		// iOS 15: Use explicit NavigationLinks with a single currentStep state
		CompatNavigationStack {
			ZStack {
				RadioSetupIntroPage(
					model: model,
					onNotNow: onFinished,
					onAdvance: { advance(from: .intro) }
				)
					.padding(.top, 44)
					.toolbar(.hidden, for: .navigationBar)
					.trackScreen(RadioSetupStep.intro.screenName)
					.opacity(currentStep == nil ? 1 : 0)

				NavigationLink(
					destination: RadioSetupRegionPage(
						model: model,
						onAdvance: { advance(from: .region) }
					)
						.trackScreen(RadioSetupStep.region.screenName),
					isActive: Binding(
						get: { currentStep == .region },
						set: { if !$0 { currentStep = nil } }
					)
				) { EmptyView() }

				NavigationLink(
					destination: RadioSetupPresetPage(
						model: model,
						onAdvance: { advance(from: .preset) }
					)
						.trackScreen(RadioSetupStep.preset.screenName),
					isActive: Binding(
						get: { currentStep == .preset },
						set: { if !$0 { currentStep = nil } }
					)
				) { EmptyView() }

				NavigationLink(
					destination: RadioSetupNamePage(
						model: model,
						onAdvance: { advance(from: .name) },
						onSkip: { advance(from: .name) }
					)
						.trackScreen(RadioSetupStep.name.screenName),
					isActive: Binding(
						get: { currentStep == .name },
						set: { if !$0 { currentStep = nil } }
					)
				) { EmptyView() }

				NavigationLink(
					destination: RadioSetupDonePage(model: model, onDone: onFinished)
						.trackScreen(RadioSetupStep.done.screenName),
					isActive: Binding(
						get: { currentStep == .done },
						set: { if !$0 { currentStep = nil } }
					)
				) { EmptyView() }
			}
		}
	}
}