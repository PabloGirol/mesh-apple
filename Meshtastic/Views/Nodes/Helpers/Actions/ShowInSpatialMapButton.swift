//
///  ShowInSpatialMapButton.swift
///  Meshtastic
///
///  Copyright(c) Garth Vander Houwen 10/10/26.
///
#if os(visionOS)
import SwiftUI

/// Opens (or brings forward) the spatial map volume with this node selected.
struct ShowInSpatialMapButton: View {
	let nodeNum: Int64
	@EnvironmentObject private var appState: AppState

	var body: some View {
		EmptyView()
	}
}
#endif