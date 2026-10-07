import SwiftUI
import Testing
@testable import Familiar

struct FontFamilyTests {

    let family = FontFamily.staticFamily(
        name: "Test",
        faces: [
            .init("Test-Bold", weightClass: 700),
            .init("Test-Regular", weightClass: 400),
            .init("Test-Semibold", weightClass: 500),
        ]
    )

    @Test(arguments: [
        (Font.Weight.ultraLight, "Test-Regular"),
        (.regular, "Test-Regular"),
        (.medium, "Test-Semibold"),
        (.semibold, "Test-Semibold"),  // 600 is equidistant from 500 and 700; ties go lighter
        (.bold, "Test-Bold"),
        (.black, "Test-Bold"),
    ])
    func picksNearestFace(_ weight: Font.Weight, _ expected: String) {
        #expect(family.face(for: weight).postScriptName == expected)
    }

    @Test func variableFamilyHasOneFaceAndAnAxis() {
        let variable = FontFamily.variableFamily(
            name: "Variable", postScriptName: "Variable-Black", weightClass: 900, weightAxis: 300...900
        )
        #expect(variable.isVariable)
        #expect(variable.faces.count == 1)
        #expect(!family.isVariable)
    }

    @Test func unavailableFamilyReturnsNoFont() {
        #expect(!family.isAvailable)
        #expect(family.font(size: 17, weight: .regular) == nil)
    }

    @Test func availableFamilyReturnsAFont() {
        let helvetica = FontFamily.staticFamily(name: "Helvetica", faces: [.init("Helvetica", weightClass: 400)])
        #expect(helvetica.isAvailable)
        #expect(helvetica.font(size: 17, weight: .regular) != nil)
    }
}

struct FontRegistryTests {

    @Test func detectsSubstitution() {
        #expect(FontRegistry.isAvailable("Helvetica"))
        #expect(!FontRegistry.isAvailable("NotARealFont-Bold"))
    }

    @Test func bundleWithoutFontsRegistersNothing() {
        #expect(FontRegistry.register(Bundle(for: BundleToken.self)).isEmpty)
    }

    private final class BundleToken {}
}

struct TypographyTests {

    @Test func withChangesOnlyWhatItsGiven() {
        let token = Typography.body.with(weight: .bold)
        #expect(token.size == Typography.body.size)
        #expect(token.relativeTo == .body)
        #expect(token.weight == .bold)
    }

    @Test func withCanClearRelativeTo() {
        #expect(Typography.body.with(relativeTo: .some(nil)).relativeTo == nil)
    }

    @Test func fixedTokensIgnoreScaling() {
        #expect(Typography.custom(20).resolvedSize(scaled: 40) == 20)
        #expect(Typography.custom(20, relativeTo: .body).resolvedSize(scaled: 40) == 40)
    }

    @Test func displayFollowsTheEnvironmentFamily() {
        let brand = FontFamily.staticFamily(name: "Brand", faces: [.init("Brand-Bold", weightClass: 700)])
        #expect(Typography.display.family(display: nil) == nil)
        #expect(Typography.display.family(display: brand) == brand)
        #expect(Typography.body.family(display: brand) == nil)
    }

    @Test func displayFamilyDefaultsToNil() {
        #expect(EnvironmentValues().displayFamily == nil)
    }

    @Test(arguments: [Font.Weight.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy])
    func boldTextGoesHeavier(_ weight: Font.Weight) {
        #expect(weight.bolder.numericWeight > weight.numericWeight)
    }
}
