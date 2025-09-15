import Foundation
import STTextView
import Markdown

#if canImport(AppKit)
import AppKit
public typealias Font = NSFont
public typealias Color = NSColor
#elseif canImport(UIKit)
import UIKit
public typealias Font = UIFont
public typealias Color = UIColor
#endif

public struct STPluginMarkdown: STPlugin {
    public typealias Coordinator = MarkdownCoordinator

    private let configuration: MarkdownConfiguration

    // Static storage to keep highlighters alive
    private static var highlighters: [ObjectIdentifier: MarkdownHighlighter] = [:]

    public init(configuration: MarkdownConfiguration = MarkdownConfiguration()) {
        self.configuration = configuration
    }

    public func setUp(context: any Context) {
        guard let pluginContext = context as? STPluginContext<STPluginMarkdown> else { return }

        let highlighter = MarkdownHighlighter(configuration: configuration, textView: pluginContext.textView)

        // Store highlighter in static storage to keep it alive
        let textViewId = ObjectIdentifier(pluginContext.textView)
        Self.highlighters[textViewId] = highlighter

        pluginContext.coordinator.highlighter = highlighter

        // Set up text change monitoring
        pluginContext.events.onDidChangeText { affectedRange, replacementString in
            Self.highlighters[textViewId]?.highlightText(affectedRange: affectedRange, replacementString: replacementString)
        }

        // Initial highlighting
        Task { @MainActor in
            highlighter.highlightText()
        }
    }

    public func makeCoordinator(context: CoordinatorContext) -> Coordinator {
        return MarkdownCoordinator()
    }

    public func tearDown() {
        // Clean up resources
    }
}

public class MarkdownCoordinator: NSObject {
    var highlighter: MarkdownHighlighter? // Strong reference to keep highlighter alive

    deinit {
        highlighter = nil
    }
}

/// Configuration for Markdown syntax highlighting
///
/// Provides thoughtful defaults with semantic colors and appropriate typography scaling.
/// The default configuration uses:
/// - 16pt body text with scaled headings (28pt, 24pt, 20pt)
/// - Semantic colors: indigo headings, pink code, blue links, teal emphasis, orange strong text
public struct MarkdownConfiguration {
    public let fonts: MarkdownFonts
    public let colors: MarkdownColors

    public init(
        fonts: MarkdownFonts = MarkdownFonts(),
        colors: MarkdownColors = MarkdownColors()
    ) {
        self.fonts = fonts
        self.colors = colors
    }
}

/// Font configuration for different Markdown elements
///
/// Default fonts provide a harmonious typography scale:
/// - Body: 16pt system font
/// - Headings: Bold system fonts at 28pt, 24pt, 20pt for H1-H3
/// - Code: 14pt medium-weight monospaced font
/// - Bold/Italic: 16pt system fonts with appropriate styling
public struct MarkdownFonts {
    public let body: Font
    public let heading1: Font
    public let heading2: Font
    public let heading3: Font
    public let code: Font
    public let bold: Font
    public let italic: Font

    public init(
        body: Font = PlatformFont.systemFont(ofSize: 16),
        heading1: Font = PlatformFont.boldSystemFont(ofSize: 28),
        heading2: Font = PlatformFont.boldSystemFont(ofSize: 24),
        heading3: Font = PlatformFont.boldSystemFont(ofSize: 20),
        code: Font = PlatformFont.monospacedSystemFont(ofSize: 14, weight: .medium),
        bold: Font = PlatformFont.boldSystemFont(ofSize: 16),
        italic: Font = PlatformFont.italicSystemFont(ofSize: 16)
    ) {
        self.body = body
        self.heading1 = heading1
        self.heading2 = heading2
        self.heading3 = heading3
        self.code = code
        self.bold = bold
        self.italic = italic
    }
}

/// Color configuration for different Markdown elements
///
/// Default colors use semantic system colors that adapt to light/dark mode:
/// - Text: Primary label color
/// - Headings: System indigo (distinctive but professional)
/// - Code: System pink (high contrast for readability)
/// - Links: System blue (web standard)
/// - Emphasis: System teal (subtle highlighting)
/// - Strong: System orange (warm, attention-grabbing)
public struct MarkdownColors {
    public let text: Color
    public let heading: Color
    public let code: Color
    public let link: Color
    public let emphasis: Color
    public let strong: Color

    public init(
        text: Color = PlatformColor.labelColor,
        heading: Color = PlatformColor.headingColor,
        code: Color = PlatformColor.codeColor,
        link: Color = PlatformColor.linkColor,
        emphasis: Color = PlatformColor.emphasisColor,
        strong: Color = PlatformColor.strongColor
    ) {
        self.text = text
        self.heading = heading
        self.code = code
        self.link = link
        self.emphasis = emphasis
        self.strong = strong
    }
}

// MARK: - Markdown Highlighter Implementation

internal class MarkdownHighlighter {
    private let configuration: MarkdownConfiguration
    private weak var textView: STTextView?
    private var debounceTimer: Timer?

    internal init(configuration: MarkdownConfiguration, textView: STTextView) {
        self.configuration = configuration
        self.textView = textView
    }

    deinit {
        debounceTimer?.invalidate()
    }

    internal func highlightText(affectedRange: NSTextRange? = nil, replacementString: String? = nil) {
        // Use very short debounce for smoother experience
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { [self] _ in
            Task { @MainActor in
                self.performHighlighting()
            }
        }
    }

    @MainActor
    private func performHighlighting() {
        guard let textView = textView else { return }

        let textStorage = textView.textContentManager
        let fullText = textStorage.attributedString(in: textStorage.documentRange)?.string ?? ""
        guard !fullText.isEmpty else { return }

        // Reset all text to default styling first
        let fullRange = NSRange(location: 0, length: fullText.count)
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: configuration.fonts.body,
            .foregroundColor: configuration.colors.text
        ]
        textView.setAttributes(defaultAttributes, range: fullRange)

        // Parse the Markdown
        let document = Document(parsing: fullText)

        // Apply highlighting
        let visitor = MarkdownStyleVisitor(
            configuration: configuration,
            textView: textView,
            sourceText: fullText
        )
        visitor.visit(document)
    }
}

// MARK: - Markdown Visitor for Styling

@MainActor
private class MarkdownStyleVisitor {
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

        let font: Font
        switch heading.level {
        case 1: font = configuration.fonts.heading1
        case 2: font = configuration.fonts.heading2
        case 3: font = configuration.fonts.heading3
        default: font = configuration.fonts.heading3
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: configuration.colors.heading
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitEmphasis(_ emphasis: Emphasis) {
        guard let nsRange = getNSRange(for: emphasis) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.fonts.italic,
            .foregroundColor: configuration.colors.emphasis
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitStrong(_ strong: Strong) {
        guard let nsRange = getNSRange(for: strong) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.fonts.bold,
            .foregroundColor: configuration.colors.strong
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitInlineCode(_ inlineCode: InlineCode) {
        guard let nsRange = getNSRange(for: inlineCode) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.fonts.code,
            .foregroundColor: configuration.colors.code
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitCodeBlock(_ codeBlock: CodeBlock) {
        guard let nsRange = getNSRange(for: codeBlock) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: configuration.fonts.code,
            .foregroundColor: configuration.colors.code
        ]
        applyAttributes(attributes, to: nsRange)
    }

    private func visitLink(_ link: Link) {
        guard let nsRange = getNSRange(for: link) else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: configuration.colors.link,
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

// MARK: - Extension for usage convenience
public extension STTextView {
    /// Add Markdown syntax highlighting to the text view
    func addMarkdownPlugin(configuration: MarkdownConfiguration = MarkdownConfiguration()) {
        let plugin = STPluginMarkdown(configuration: configuration)
        self.addPlugin(plugin)
    }
}
