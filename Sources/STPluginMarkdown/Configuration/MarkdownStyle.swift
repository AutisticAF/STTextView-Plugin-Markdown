import Foundation

/// A combined style containing both font and color for a specific Markdown syntax element
public struct MarkdownStyle {
    public let font: Font
    public let color: Color

    public init(font: Font, color: Color) {
        self.font = font
        self.color = color
    }
}