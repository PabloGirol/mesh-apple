//
//  PersistentTipStyle.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 2025.
//
import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
import TipKit

@available(iOS 16.0, macOS 13.0, *)
struct PersistentTipStyle: TipViewStyle {
	func makeBody(configuration: Configuration) -> some View {
		HStack(alignment: .top, spacing: 12) {
			if let image = configuration.image {
				image
					.font(.title2)
					.foregroundStyle(.tint)
			}
			VStack(alignment: .leading, spacing: 4) {
				if let title = configuration.title {
					title
						.font(.subheadline)
						.fontWeight(.semibold)
				}
				if let message = configuration.message {
					message
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}
