import SwiftUI
import Testing
@testable import Familiar

struct SwatchTests {

    @Test func bundleDefaultsToMain() {
        #expect(Swatch.bundle("Brand") == .bundle("Brand", .main))
    }

    @Test func hexResolvesToItsColourInEveryScheme() {
        let hex: Hex = 0x3B5BDB
        for scheme in [ColorScheme.light, .dark] {
            #expect(Swatch.hex(hex).color(in: scheme) == hex.color)
        }
    }

    @Test func systemResolvesToItsColour() {
        #expect(Swatch.system(.red).color(in: .light) == .red)
    }

    @Test func styleResolvesThroughSwatch() {
        let hex: Hex = 0x3B5BDB
        #expect(SwatchStyle(.hex(hex)).resolve(in: EnvironmentValues()) == hex.color)
        #expect(SwatchStyle.swatch(.hex(hex)).swatch == .hex(hex))
    }

    @Test func accentSwatchDefaultsToBrandAccent() {
        #expect(EnvironmentValues().accentSwatch == .accent)
    }

    // MARK: Brand

    @Test func brandPicksItsShadeForTheScheme() throws {
        let dark = try #require(BrandColor.accent.dark)
        #expect(Swatch.accent.color(in: .light) == BrandColor.accent.light.color)
        #expect(Swatch.accent.color(in: .dark) == dark.color)
    }

    @Test func brandWithoutDarkHoldsStill() {
        #expect(BrandColor.signature.dark == nil)
        #expect(Swatch.signature.color(in: .dark) == BrandColor.signature.light.color)
    }

    /// The point of the case: the shade is picked at draw time, from the
    /// environment, not by the call site.
    @Test func styleResolvesBrandAgainstTheEnvironment() throws {
        var environment = EnvironmentValues()
        environment.colorScheme = .dark
        let dark = try #require(BrandColor.accent.dark)
        #expect(SwatchStyle(.accent).resolve(in: environment) == dark.color)
    }

    @Test func brandSwatchesFollowBrandColors() {
        #expect(Swatch.brandColors == BrandColor.all.map(Swatch.brand))
        #expect(Swatch.brandColors.map(\.name) == BrandColor.all.map(\.name))
    }

    // MARK: Names

    @Test func namedSwatchesHaveNames() {
        #expect(Swatch.accent.name == "accent")
        #expect(Swatch.surface.name == "surface")
        #expect(Swatch.system(.red).name == nil)
        #expect(Swatch.hex(Hex(0x3B5BDB)).name == nil)
    }
}
