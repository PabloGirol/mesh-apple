//
//  MetricsColumnDetail.swift
//  Meshtastic
//
//  Created by Jake Bordens on 12/10/24.
//

import NavigationStackShim
import SwiftUI

struct MetricsColumnDetail: View {
	@ObservedObject var columnList: MetricsColumnList
	@ObservedObject var seriesList: MetricsSeriesList

	@State private var currentDetent = PresentationDetent.medium

	enum ViewOption: String, CaseIterable, Identifiable {
		case chart = "Chart"
		case table = "Table"

		var id: String { rawValue }
	}

	@State private var selectedView: ViewOption = .chart

	var body: some View {
		CompatNavigationStack {
			Form {
				Section {
					Picker("", selection: $selectedView) {
						ForEach(ViewOption.allCases) { option in
							Text(option.rawValue)
								.tag(option)
						}
					}
					.pickerStyle(.segmented)
				}.listRowBackground(Color.clear)

				switch selectedView {
				case .chart:
					ForEach(seriesList) { series in
						HStack {
							Path { path in
								path.move(to: CGPoint(x: 10, y: 0))
								path.addLine(to: CGPoint(x: 10, y: 20))
							}
							.stroke(series.foregroundStyle(0.0...100.0) ?? AnyShapeStyle(.clear),
									style: series.strokeStyle)
							.frame(width: 20.0, height: 20.0)
							.rotationEffect(.degrees(90.0))
							Text(series.name)
							Spacer()
							if series.visible {
								Image(systemName: "checkmark")
									.foregroundColor(.blue)
							}
						}.contentShape(Rectangle())  // Ensures the entire row is tappable
							.onTapGesture {
								seriesList.toggleVisibity(for: series)
							}
							.accessibilityElement(children: .combine)
							.accessibilityLabel(series.name)
							.accessibilityValue(series.visible ? String(localized: "Visible") : String(localized: "Hidden"))
							.accessibilityAddTraits(.isButton)
							.accessibilityAction {
								seriesList.toggleVisibity(for: series)
							}
					}
				case .table:
					ForEach(columnList.columns) { column in
						HStack {
							Text(column.name)
							Spacer()
							if column.visible {
								Image(systemName: "checkmark")
									.foregroundColor(.blue)
							}
						}.contentShape(Rectangle())  // Ensures the entire row is tappable
							.onTapGesture {
								columnList.objectWillChange.send()
								columnList.toggleVisibity(for: column)
							}
							.accessibilityElement(children: .combine)
							.accessibilityLabel(column.name)
							.accessibilityValue(column.visible ? String(localized: "Visible") : String(localized: "Hidden"))
							.accessibilityAddTraits(.isButton)
							.accessibilityAction {
								columnList.objectWillChange.send()
								columnList.toggleVisibity(for: column)
							}
					}
				}
			}
			.listStyle(.insetGrouped)
			.listSectionSpacing(12)
			.sheetCloseButton()
		}
		.modifier(SheetPresentationModifiers(
			detents: [.medium, .large],
			selection: $currentDetent,
			contentInteraction: .scrolls,
			dragIndicatorVisible: true,
			backgroundInteractionEnabled: true,
			interactiveDismissDisabled: false
		))
	}
}

private struct SheetPresentationModifiers: ViewModifier {
	let detents: [PresentationDetent]
	@Binding var selection: PresentationDetent
	let contentInteraction: PresentationContentInteraction
	let dragIndicatorVisible: Bool
	let backgroundInteractionEnabled: Bool
	let interactiveDismissDisabled: Bool

	func body(content: Content) -> some View {
		if #available(iOS 16.0, *) {
			content
				.presentationDetents(detents, selection: $selection)
				.presentationContentInteraction(contentInteraction)
				.presentationDragIndicator(dragIndicatorVisible ? .visible : .hidden)
				.presentationBackgroundInteraction(.enabled(upThrough: .medium))
				.interactiveDismissDisabled(interactiveDismissDisabled)
		} else {
			// iOS 15 fallback: fixed height sheet
			content
		}
	}
}

#Preview {
	MetricsColumnDetail(
		columnList: MetricsColumnList(columns: []),
		seriesList: MetricsSeriesList()
	)
}

#Preview {
	MetricsColumnDetail(
		columnList: MetricsColumnList(columns: []),
		seriesList: MetricsSeriesList()
	)
}
