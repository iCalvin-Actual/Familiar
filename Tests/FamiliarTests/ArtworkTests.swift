import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct ArtworkTests {

    @Test func defaultsToMedium() {
        #expect(Artwork(.file("nextapp")).size == .medium)
    }

    @Test func standardSizesGrow() {
        let dimensions = [Artwork.Size.small, .medium, .large].compactMap(\.dimension)
        #expect(dimensions.count == 3)
        #expect(dimensions == dimensions.sorted())
    }

    @Test func fillLetsTheContainerDecide() {
        #expect(Artwork.Size.fill.dimension == nil)
    }

    @Test func cropsFixedSizesAndFitsFill() {
        #expect(Artwork(.file("nextapp"), size: .small).resolvedContentMode == .fill)
        #expect(Artwork(.file("nextapp"), size: .fill).resolvedContentMode == .fit)
        #expect(Artwork(.file("nextapp"), size: .small, contentMode: .fit).resolvedContentMode == .fit)
    }

    @Test func bundleDefaultsToMain() {
        #expect(Artwork.Source.bundle("cover") == .bundle("cover", .main))
    }

}
