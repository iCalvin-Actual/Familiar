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

}
