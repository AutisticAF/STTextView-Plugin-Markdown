import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Configuration for Markdown syntax highlighting
///
/// Provides thoughtful defaults with semantic colors and appropriate typography scaling.
/// The default configuration uses:
/// - 16pt body text with scaled headings (28pt, 24pt, 20pt)
/// - Semantic colors: indigo headings, pink code, blue links, teal emphasis, orange strong text
public struct MarkdownConfiguration {
    public let body: MarkdownStyle
    public let heading1: MarkdownStyle
    public let heading2: MarkdownStyle
    public let heading3: MarkdownStyle
    public let code: MarkdownStyle
    public let emphasis: MarkdownStyle
    public let strong: MarkdownStyle
    public let link: MarkdownStyle

    public init(
        body: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.systemFont(ofSize: 16),
            color: PlatformColor.labelColor
        ),
        heading1: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.boldSystemFont(ofSize: 28),
            color: PlatformColor.headingColor
        ),
        heading2: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.boldSystemFont(ofSize: 24),
            color: PlatformColor.headingColor
        ),
        heading3: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.boldSystemFont(ofSize: 20),
            color: PlatformColor.headingColor
        ),
        code: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.monospacedSystemFont(ofSize: 14, weight: .medium),
            color: PlatformColor.codeColor
        ),
        emphasis: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.italicSystemFont(ofSize: 16),
            color: PlatformColor.emphasisColor
        ),
        strong: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.boldSystemFont(ofSize: 16),
            color: PlatformColor.strongColor
        ),
        link: MarkdownStyle = MarkdownStyle(
            font: PlatformFont.systemFont(ofSize: 16),
            color: PlatformColor.linkColor
        )
    ) {
        self.body = body
        self.heading1 = heading1
        self.heading2 = heading2
        self.heading3 = heading3
        self.code = code
        self.emphasis = emphasis
        self.strong = strong
        self.link = link
    }
}