import Foundation
import STTextView

// MARK: - Extension for usage convenience
public extension STTextView {
    /// Add Markdown syntax highlighting to the text view
    func addMarkdownPlugin(configuration: MarkdownConfiguration = MarkdownConfiguration()) {
        let plugin = STPluginMarkdown(configuration: configuration)
        self.addPlugin(plugin)
    }
}