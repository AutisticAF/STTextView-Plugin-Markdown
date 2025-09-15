import XCTest
@testable import STPluginMarkdown

final class STPluginMarkdownTests: XCTestCase {

    func testDefaultConfiguration() {
        let config = MarkdownConfiguration()

        XCTAssertNotNil(config.fonts)
        XCTAssertNotNil(config.colors)
    }

    func testCustomConfiguration() {
        let customFonts = MarkdownFonts()
        let customColors = MarkdownColors()

        let customConfig = MarkdownConfiguration(
            fonts: customFonts,
            colors: customColors
        )

        XCTAssertNotNil(customConfig.fonts)
        XCTAssertNotNil(customConfig.colors)
    }

    @MainActor func testPluginInitialization() {
        let plugin = STPluginMarkdown()
        XCTAssertNotNil(plugin)
    }

    @MainActor func testPluginWithCustomConfiguration() {
        let customConfig = MarkdownConfiguration()
        let plugin = STPluginMarkdown(configuration: customConfig)
        XCTAssertNotNil(plugin)
    }

    func testMarkdownFonts() {
        let fonts = MarkdownFonts()

        XCTAssertNotNil(fonts.body)
        XCTAssertNotNil(fonts.heading1)
        XCTAssertNotNil(fonts.code)
        XCTAssertNotNil(fonts.bold)
        XCTAssertNotNil(fonts.italic)
    }

    func testMarkdownColors() {
        let colors = MarkdownColors()

        XCTAssertNotNil(colors.text)
        XCTAssertNotNil(colors.heading)
        XCTAssertNotNil(colors.code)
        XCTAssertNotNil(colors.link)
    }

    func testCustomFonts() {
        let customFonts = MarkdownFonts(
            body: PlatformFont.systemFont(ofSize: 16),
            heading1: PlatformFont.boldSystemFont(ofSize: 28)
        )

        XCTAssertNotNil(customFonts.body)
        XCTAssertNotNil(customFonts.heading1)
    }

    func testCustomColors() {
        let customColors = MarkdownColors(
            text: PlatformColor.labelColor,
            heading: PlatformColor.systemBlue
        )

        XCTAssertNotNil(customColors.text)
        XCTAssertNotNil(customColors.heading)
    }
}