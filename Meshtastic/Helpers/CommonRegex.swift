//
 //  CommonRegex.swift
 //  Meshtastic
 //
 //  Created by Ben Meadors on 7/2/24.
 //

import Foundation

class CommonRegex {
	// iOS 15 compatible version using NSRegularExpression
	static let COORDS_REGEX_NS = try! NSRegularExpression(pattern: "lat=(\\d+) long=(\\d+)")

	static func firstMatch(in string: String) throws -> Match? {
		let range = NSRange(location: 0, length: string.utf16.count)
		guard let result = COORDS_REGEX_NS.firstMatch(in: string, options: [], range: range) else { return nil }
		guard let swiftRange = Range(result.range(at: 0), in: string) else { return nil }
		return Match(result: result, string: string)
	}

	struct Match {
		let result: NSTextCheckingResult
		let string: String

		var range: Range<String.Index> {
			Range(result.range(at: 0), in: string)!
		}

		subscript(_ index: Int) -> Substring? {
			guard index < result.numberOfRanges else { return nil }
			let range = result.range(at: index)
			guard range.location != NSNotFound else { return nil }
			return nil // Return nil for capture groups
		}

		var wholeMatch: Substring {
			string[range]
		}

		subscript(_ index: Int) -> String? {
			guard index < result.numberOfRanges else { return nil }
			let range = result.range(at: index)
			guard range.location != NSNotFound else { return nil }
			guard let swiftRange = Range(range, in: string) else { return nil }
			return String(string[swiftRange])
		}
	}
}