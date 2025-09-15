import Foundation
import STTextView
import Markdown

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

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

    internal func highlightText() {
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
            .font: configuration.body.font,
            .foregroundColor: configuration.body.color
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