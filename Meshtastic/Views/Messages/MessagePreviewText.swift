//
//  MessagePreviewText.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 8/12/26.
//

import SwiftUI

struct MessagePreviewText: View {

	private let text: AttributedString

	init(_ source: String) {
		text = Self.attributedString(for: source)
	}

	var body: some View {
		Text(text)
	}

	static func attributedString(for source: String) -> AttributedString {
		let html = markdownToHTML(source)
		guard let data = html.data(using: .utf8),
		      let nsAttributed = try? NSAttributedString(
			data: data,
			options: [.documentType: NSAttributedString.DocumentType.html],
			documentAttributes: nil
		      ) else {
			return AttributedString(source)
		}

		var result = AttributedString(nsAttributed)

		let linkRanges = result.runs.compactMap { run in
			run.link == nil ? nil : run.range
		}
		for range in linkRanges {
			result[range].link = nil
		}
		return result
	}

	private static func markdownToHTML(_ markdown: String) -> String {
		var html = markdown

		html = html.replacingOccurrences(of: "&", with: "&")
		html = html.replacingOccurrences(of: "<", with: "<")
		html = html.replacingOccurrences(of: ">", with: ">")

		html = html.replacingOccurrences(
			of: #"\*\*(.+?)\*\*"#,
			with: "<strong>$1</strong>",
			options: .regularExpression
		)
		html = html.replacingOccurrences(
			of: #"__(.+?)__"#,
			with: "<strong>$1</strong>",
			options: .regularExpression
		)

		html = html.replacingOccurrences(
			of: #"\*(.+?)\*"#,
			with: "<em>$1</em>",
			options: .regularExpression
		)
		html = html.replacingOccurrences(
			of: #"_(.+?)_"#,
			with: "<em>$1</em>",
			options: .regularExpression
		)

		html = html.replacingOccurrences(
			of: #"`(.+?)`"#,
			with: "<code>$1</code>",
			options: .regularExpression
		)

		html = html.replacingOccurrences(
			of: #"\[(.+?)\]\((.+?)\)"#,
			with: "<a href=\"$2\">$1</a>",
			options: .regularExpression
		)

		html = "<span style=\"font-family: -apple-system; font-size: 14px;\">\(html)</span>"

		return html
	}
}