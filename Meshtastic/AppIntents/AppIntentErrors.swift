//
//  AppIntentErrors.swift
//  Meshtastic
//
//  Created by Benjamin Faershtein on 8/11/24.
//

import Foundation
import OSLog

class AppIntentErrors {
	#if canImport(AppIntents) && compiler(>=5.9) && !MESHTASTIC_IOS15
	enum AppIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
		case notConnected
		case message(_ message: String)

		var localizedStringResource: LocalizedStringResource {
			switch self {
			case let .message(message):
				Logger.services.error("App Intent: \(message, privacy: .public)")
				return "Error: \(message)"
			case .notConnected:
				Logger.services.error("App Intent: No Connected Node")
				return "No Connected Node"
			}
		}
	}
	#else
	enum AppIntentError: Swift.Error {
		case notConnected
		case message(_ message: String)

		var localizedDescription: String {
			switch self {
			case let .message(message):
				Logger.services.error("App Intent: \(message, privacy: .public)")
				return "Error: \(message)"
			case .notConnected:
				Logger.services.error("App Intent: No Connected Node")
				return "No Connected Node"
			}
		}
	}
	#endif
}