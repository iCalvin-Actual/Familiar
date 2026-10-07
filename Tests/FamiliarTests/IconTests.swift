import SwiftUI
import Testing
@testable import Familiar

struct IconTests {

    /// Catches a case added without its image set, or a name typo — either
    /// of which would otherwise render nothing without complaint.
    @Test(arguments: Icon.Symbol.allCases)
    func everySymbolHasAnImage(_ symbol: Icon.Symbol) {
        #expect(Bundle.familiar.image(forResource: symbol.rawValue) != nil, "No image set named \(symbol.rawValue)")
    }

    /// Catches a file dropped into `Resources/Images` that won't decode.
    @Test(arguments: URL.familiarImages)
    func everyLooseImageDecodes(_ url: URL) {
        #expect(Image(contentsOf: url) != nil, "\(url.lastPathComponent) is in Resources/Images but didn't decode")
    }

    /// Catalog images and loose files share the bundle, so the same name for
    /// both would read as one icon at the call site but draw as two.
    @Test func looseImagesDontShadowSymbols() {
        let symbols = Set(Icon.Symbol.allCases.map(\.rawValue))
        #expect(symbols.isDisjoint(with: URL.familiarImages.map(\.familiarImageName)))
    }

    @Test func findsLooseImagesByName() throws {
        let url = try #require(URL.familiarImage(named: "nextapp"))
        #expect(url.familiarImageName == "nextapp")
        #expect(URL.familiarImage(named: "definitely-not-an-icon") == nil)
    }

    @MainActor @Test func systemSymbolsDescribeThemselves() {
        #expect(!Icon(source: .system("star.fill")).isDecorative)
    }

    /// Our own images speak without help from the call site.
    @MainActor @Test(arguments: Icon.Symbol.allCases)
    func bundledSymbolsDescribeThemselves(_ symbol: Icon.Symbol) {
        #expect(!symbol.accessibilityLabel.isEmpty)
        #expect(Icon(source: .symbol(symbol)).spokenLabel == symbol.accessibilityLabel)
        #expect(Icon(source: .symbol(symbol), label: "Home").spokenLabel == "Home")
        #expect(!Icon(source: .symbol(symbol)).isDecorative)
    }

    @MainActor @Test(arguments: [Icon.Source.file("nextapp"), .bundle("cover")])
    func otherSourcesAreDecorativeUnlessLabelled(_ source: Icon.Source) {
        #expect(Icon(source: source).isDecorative)
        #expect(!Icon(source: source, label: "Familiar").isDecorative)
    }
}
