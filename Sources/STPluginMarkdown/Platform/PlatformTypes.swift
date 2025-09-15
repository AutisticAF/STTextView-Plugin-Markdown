import Foundation

#if canImport(AppKit)
import AppKit
public typealias Font = NSFont
public typealias Color = NSColor
#elseif canImport(UIKit)
import UIKit
public typealias Font = UIFont
public typealias Color = UIColor
#endif