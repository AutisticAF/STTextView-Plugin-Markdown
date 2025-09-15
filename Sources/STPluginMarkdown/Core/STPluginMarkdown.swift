import Foundation
import STTextView

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

        // Set up text change monitoring
        pluginContext.events.onDidChangeText { _, _ in
            Self.highlighters[textViewId]?.highlightText()
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