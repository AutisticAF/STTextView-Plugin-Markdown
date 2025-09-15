import Foundation

#if canImport(AppKit)
import AppKit

public struct PlatformFont {
    public static func monospacedSystemFont(ofSize size: CGFloat, weight: NSFont.Weight) -> NSFont {
        return NSFont.monospacedSystemFont(ofSize: size, weight: weight)
    }

    public static func boldSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.boldSystemFont(ofSize: size)
    }

    public static func italicSystemFont(ofSize size: CGFloat) -> NSFont {
        let fontDescriptor = NSFont.systemFont(ofSize: size).fontDescriptor
        let italicDescriptor = fontDescriptor.withSymbolicTraits(.italic)
        return NSFont(descriptor: italicDescriptor, size: size) ?? NSFont.systemFont(ofSize: size)
    }

    public static func systemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: size)
    }
}

public struct PlatformColor {
    public static var labelColor: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.labelColor
        } else {
            return NSColor.textColor
        }
    }

    public static var secondaryLabelColor: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.secondaryLabelColor
        } else {
            return NSColor.disabledControlTextColor
        }
    }

    public static var quaternarySystemFill: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.quaternarySystemFill
        } else {
            return NSColor.controlBackgroundColor
        }
    }

    public static var systemRed: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.systemRed
        } else {
            return NSColor.red
        }
    }

    public static var systemBlue: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.systemBlue
        } else {
            return NSColor.blue
        }
    }

    // MARK: - Semantic Colors for Markdown

    public static var headingColor: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.systemIndigo
        } else {
            return NSColor.purple
        }
    }

    public static var codeColor: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.systemPink
        } else {
            return NSColor.magenta
        }
    }

    public static var linkColor: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.systemBlue
        } else {
            return NSColor.blue
        }
    }

    public static var emphasisColor: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.systemTeal
        } else {
            return NSColor.cyan
        }
    }

    public static var strongColor: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.systemOrange
        } else {
            return NSColor.orange
        }
    }
}

#elseif canImport(UIKit)
import UIKit

public struct PlatformFont {
    public static func monospacedSystemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
    }

    public static func boldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }

    public static func italicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.italicSystemFont(ofSize: size)
    }

    public static func systemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
}

public struct PlatformColor {
    public static var labelColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }

    public static var secondaryLabelColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor.gray
        }
    }

    public static var quaternarySystemFill: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.quaternarySystemFill
        } else {
            return UIColor.systemGray6
        }
    }

    public static var systemRed: UIColor {
        return UIColor.systemRed
    }

    public static var systemBlue: UIColor {
        return UIColor.systemBlue
    }

    // MARK: - Semantic Colors for Markdown

    public static var headingColor: UIColor {
        return UIColor.systemIndigo
    }

    public static var codeColor: UIColor {
        return UIColor.systemPink
    }

    public static var linkColor: UIColor {
        return UIColor.systemBlue
    }

    public static var emphasisColor: UIColor {
        return UIColor.systemTeal
    }

    public static var strongColor: UIColor {
        return UIColor.systemOrange
    }
}

#endif