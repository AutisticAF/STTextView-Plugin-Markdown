import Foundation
import STTextView
import Markdown

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
internal class MarkdownStyleVisitor {
    private let configuration: MarkdownConfiguration
    private let textView: STTextView
    private let sourceText: String

    init(configuration: MarkdownConfiguration, textView: STTextView, sourceText: String) {
        self.configuration = configuration
        self.textView = textView
        self.sourceText = sourceText
    }

    func visit(_ markup: any Markup) {
        // Handle different types of markup
        if let heading = markup as? Heading {
            visitHeading(heading)
        } else if let emphasis = markup as? Emphasis {
            visitEmphasis(emphasis)
        } else if let strong = markup as? Strong {
            visitStrong(strong)
        } else if let inlineCode = markup as? InlineCode {
            visitInlineCode(inlineCode)
        } else if let link = markup as? Link {
            visitLink(link)
        } else if let codeBlock = markup as? CodeBlock {
            visitCodeBlock(codeBlock)
        }

        // Recursively visit children
        for child in markup.children {
            visit(child)
        }
    }

    private func visitHeading(_ heading: Heading) {
        guard let nsRange = getNSRange(for: heading) else { return }

        let style: MarkdownStyle
        switch heading.level {
        case 1: style = configuration.heading1
        case 2: style = configuration.heading2
        case 3: style = configuration.heading3
        default: style = configuration.heading3
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.font,
            .foregroundColor: style.color
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitEmphasis(_ emphasis: Emphasis) {
        guard let nsRange = getNSRange(for: emphasis) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.emphasis.font,
            .foregroundColor: configuration.emphasis.color
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitStrong(_ strong: Strong) {
        guard let nsRange = getNSRange(for: strong) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.strong.font,
            .foregroundColor: configuration.strong.color
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitInlineCode(_ inlineCode: InlineCode) {
        guard let nsRange = getNSRange(for: inlineCode) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.code.font,
            .foregroundColor: configuration.code.color
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitCodeBlock(_ codeBlock: CodeBlock) {
        guard let nsRange = getNSRange(for: codeBlock) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.code.font,
            .foregroundColor: configuration.code.color
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitLink(_ link: Link) {
        guard let nsRange = getNSRange(for: link) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.link.font,
            .foregroundColor: configuration.link.color,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        applyAttributes(attributes, to: nsRange)
    }

    @MainActor
    private func applyAttributes(_ attributes: [NSAttributedString.Key: Any], to nsRange: NSRange) {
        // Use STTextView's built-in method to apply attributes
        textView.setAttributes(attributes, range: nsRange)
    }

    private func getNSRange(for markup: any Markup) -> NSRange? {
        guard let sourceRange = markup.range else { return nil }

        // Convert SourceLocation to character positions
        let startLine = sourceRange.lowerBound.line - 1 // Convert to 0-based
        let startColumn = sourceRange.lowerBound.column - 1 // Convert to 0-based
        let endLine = sourceRange.upperBound.line - 1
        let endColumn = sourceRange.upperBound.column - 1

        let lines = sourceText.components(separatedBy: .newlines)

        // Calculate start position
        var startPosition = 0
        for lineIndex in 0..<min(startLine, lines.count) {
            startPosition += lines[lineIndex].count + 1 // +1 for newline
        }
        startPosition += startColumn

        // Calculate end position
        var endPosition = 0
        for lineIndex in 0..<min(endLine, lines.count) {
            endPosition += lines[lineIndex].count + 1 // +1 for newline
        }
        endPosition += endColumn

        // Ensure positions are within bounds
        startPosition = max(0, min(startPosition, sourceText.count))
        endPosition = max(startPosition, min(endPosition, sourceText.count))

        let length = max(0, endPosition - startPosition)
        let finalRange = NSRange(location: startPosition, length: length)

        // Ensure range is within text bounds
        guard finalRange.location >= 0 && NSMaxRange(finalRange) <= sourceText.count else {
            return nil
        }

        return finalRange
    }
}