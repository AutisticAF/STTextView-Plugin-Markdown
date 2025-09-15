# STPluginMarkdown

A Swift package that provides Markdown syntax highlighting for [STTextView](https://github.com/krzyzanowskim/STTextView).

## Features

- **Cross-platform**: Compatible with macOS and iOS
- **Beautiful defaults**: Thoughtfully designed default colors and typography
- **Fully customizable**: Configurable fonts and colors for different Markdown elements
- **Performance-minded**: Built with performance in mind for handling large documents
- **Easy integration**: Simple API for adding to STTextView instances

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/STTextView-Plugin-Markdown", from: "1.0.0")
]
```

## Usage

### Basic Usage

```swift
import STTextView
import STPluginMarkdown

// Create your text view
let textView = STTextView()

// Add Markdown plugin with beautiful default configuration
textView.addMarkdownPlugin()
```

The default configuration provides:
- **Typography**: 16pt body text with appropriately scaled headings (28pt, 24pt, 20pt)
- **Colors**: Semantic colors that work well in both light and dark modes:
  - 🟦 **Headings**: Indigo (distinctive but not overwhelming)
  - 🟪 **Code**: Pink (stands out for inline code)
  - 🔵 **Links**: Blue (standard web convention)
  - 🟢 **Emphasis**: Teal (subtle italic highlighting)
  - 🟠 **Strong**: Orange (warm, attention-grabbing for bold text)

### Custom Configuration

```swift
import STTextView
import STPluginMarkdown

// Create custom fonts
let customFonts = MarkdownFonts(
    body: PlatformFont.systemFont(ofSize: 14),
    heading1: PlatformFont.boldSystemFont(ofSize: 28),
    heading2: PlatformFont.boldSystemFont(ofSize: 24),
    code: PlatformFont.monospacedSystemFont(ofSize: 12, weight: .regular)
)

// Create custom colors
let customColors = MarkdownColors(
    text: PlatformColor.labelColor,
    heading: PlatformColor.systemBlue,
    code: PlatformColor.systemRed,
    link: PlatformColor.systemBlue
)

// Create configuration
let config = MarkdownConfiguration(
    fonts: customFonts,
    colors: customColors
)

// Add plugin with custom configuration
textView.addMarkdownPlugin(configuration: config)
```

### Manual Plugin Setup

```swift
import STTextView
import STPluginMarkdown

let textView = STTextView()
let plugin = STPluginMarkdown(configuration: MarkdownConfiguration())
textView.addPlugin(plugin)
```

## Supported Markdown Elements

Currently supports:
- **Headings** (`# ## ###`)
- **Bold text** (`**bold**`)
- **Italic text** (`*italic*`)
- **Inline code** (`` `code` ``)
- **Links** (`[text](url)`)

## Configuration Options

### MarkdownFonts

Configure fonts for different Markdown elements:

- `body`: Default text font
- `heading1`, `heading2`, `heading3`: Heading fonts
- `code`: Inline code font
- `bold`: Bold text font
- `italic`: Italic text font

### MarkdownColors

Configure colors for different Markdown elements:

- `text`: Default text color
- `heading`: Heading color
- `code`: Inline code color
- `link`: Link color
- `emphasis`: Italic text color
- `strong`: Bold text color

## Requirements

- iOS 18.0+ / macOS 15.0+
- Swift 6.1+
- STTextView 2.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [STTextView](https://github.com/krzyzanowskim/STTextView) for the excellent text view implementation
- [swift-markdown](https://github.com/swiftlang/swift-markdown) for Markdown parsing capabilities