import SwiftUI
import Testing
@testable import Familiar

struct BrandFontTests {

    /// Catches a missing file or a PostScript name typo, both of which would
    /// otherwise render the system fallback without complaint.
    @Test(arguments: FontFamily.all)
    func everyFaceResolves(_ family: FontFamily) {
        #expect(family.isAvailable, "\(family.name) has a face that didn't register")
        #expect(family.font(size: 17, weight: .regular) != nil)
    }

    @Test func registersEveryBundledFile() {
        let names = FontRegistry.register(.familiar)
        let expected = FontFamily.all.flatMap(\.faces).map(\.postScriptName)
        #expect(Set(expected).isSubset(of: names))
    }
}
