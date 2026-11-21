// MARK: MessagePreview

import SwiftUI

struct MessagePreview: View {
	let text: String

	var body: some View {
		if containsMarkdownSyntax(text) {
			HStack {
				Spacer()
				if let attributed = markdownToAttributedString(text) {
					Text(attributed)
						.tint(.white)
						.padding(.vertical, 10)
						.padding(.horizontal, 8)
						.foregroundColor(.white)
						.background(Color.accentFill)
						.cornerRadius(15)
				} else {
					Text(LocalizedStringKey(text))
						.tint(.white)
						.padding(.vertical, 10)
						.padding(.horizontal, 8)
						.foregroundColor(.white)
						.background(Color.accentFill)
						.cornerRadius(15)
				}
			}
			.padding(.horizontal, 15)
			.padding(.bottom, 4)
			.allowsHitTesting(false)
		}
	}
}

/// Converts markdown text to an AttributedString using HTML parsing (iOS 15 compatible).
private func markdownToAttributedString(_ markdown: String) -> AttributedString? {
	let html = markdownToHTML(markdown)
	guard let data = html.data(using: .utf8) else { return nil }
	let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
		.documentType: NSAttributedString.DocumentType.html,
		.characterEncoding: String.Encoding.utf8.rawValue
	]
	guard let nsAttributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
		return nil
	}
	var attributed = AttributedString(nsAttributed)
	// Remove link attributes so they render as plain text (consistent with iOS 16+ behavior)
	for run in attributed.runs where run.link != nil {
		attributed[run.range].link = nil
	}
	return attributed
}

/// Converts basic markdown syntax to HTML for NSAttributedString parsing.
/// Supports: **bold**, *italic*, ~~strikethrough~~, `code`, [text](url)
private func markdownToHTML(_ markdown: String) -> String {
	var result = markdown

	// Escape HTML special characters first
	result = result
		.replacingOccurrences(of: "&", with: "&")
		.replacingOccurrences(of: "<", with: "<")
		.replacingOccurrences(of: ">", with: ">")

	// Links: [text](url) -> <a href="url">text</a>
	// Must be done before other inline formatting
	result = result.replacingOccurrences(
		of: "\\[([^\\]]+)\\]\\(([^)]+)\\)",
		with: "<a href=\"$2\">$1</a>",
		options: .regularExpression
	)

	// Bold: **text** -> <strong>text</strong>
	result = result.replacingOccurrences(
		of: "\\*\\*([^*]+)\\*\\*",
		with: "<strong>$1</strong>",
		options: .regularExpression
	)

	// Italic: *text* -> <em>text</em> (but not **)
	result = result.replacingOccurrences(
		of: "(?<!\\*)\\*([^*]+)\\*(?!\\*)",
		with: "<em>$1</em>",
		options: .regularExpression
	)

	// Strikethrough: ~~text~~ -> <s>text</s>
	result = result.replacingOccurrences(
		of: "~~([^~]+)~~",
		with: "<s>$1</s>",
		options: .regularExpression
	)

	// Code: `text` -> <code>text</code>
	result = result.replacingOccurrences(
		of: "`([^`]+)`",
		with: "<code>$1</code>",
		options: .regularExpression
	)

	// Wrap in minimal HTML document for proper parsing
	return """
	<!DOCTYPE html>
	<html>
	<head>
		<meta charset="utf-8">
		<style>
			body { font-family: -apple-system; font-size: 17px; margin: 0; padding: 0; }
			strong { font-weight: bold; }
			em { font-style: italic; }
			s { text-decoration: line-through; }
			code { font-family: monospace; font-size: 0.9em; background-color: #e8e8e8; padding: 0.1em 0.3em; border-radius: 3px; }
			a { color: inherit; text-decoration: none; }
		</style>
	</head>
	<body>\(result)</body>
	</html>
	"""
}
