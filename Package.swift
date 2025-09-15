// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STTextView-Plugin-Markdown",
	platforms: [
		.macOS(.v15),
		.iOS(.v18),
		.macCatalyst(.v18)
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "STPluginMarkdown",
            targets: ["STPluginMarkdown"]),
    ],
	dependencies: [
		.package(url: "https://github.com/krzyzanowskim/STTextView", from: "2.0.0"),
		.package(url: "https://github.com/swiftlang/swift-markdown", from: "0.6.0")
	],
    targets: [
        .target(
            name: "STPluginMarkdown",
            dependencies: [
                .product(name: "STTextView", package: "STTextView"),
                .product(name: "Markdown", package: "swift-markdown")
            ]
        ),
        .testTarget(
            name: "STPluginMarkdownTests",
            dependencies: ["STPluginMarkdown"]
        ),
    ]
)
