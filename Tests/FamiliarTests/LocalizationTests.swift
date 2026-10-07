import Foundation
import Testing
@testable import Familiar

@MainActor
struct LocalizationTests {

    private func localized(_ key: String, in language: String) throws -> String {
        let path = try #require(Bundle.familiar.path(forResource: language, ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    @Test(arguments: [("es", "Cargando", "No disponible"), ("de", "Wird geladen", "Nicht verfügbar")])
    func artworkStatesAreTranslated(_ expected: (String, String, String)) throws {
        #expect(try localized("Loading", in: expected.0) == expected.1)
        #expect(try localized("Unavailable", in: expected.0) == expected.2)
    }

    @Test(arguments: [("es", "4.9 de 5 estrellas"), ("de", "4.9 von 5 Sternen")])
    func ratingIsTranslated(_ expected: (String, String)) throws {
        #expect(String(format: try localized("%@ out of %lld stars", in: expected.0), "4.9", 5) == expected.1)
    }

    @Test(arguments: [("es", "Filtros", "Nada seleccionado", "Seleccionado: Té"), ("de", "Filter", "Nichts ausgewählt", "Ausgewählt: Tee")])
    func chipRowIsTranslated(_ expected: (String, String, String, String)) throws {
        #expect(try localized("Filters", in: expected.0) == expected.1)
        #expect(try localized("Nothing selected", in: expected.0) == expected.2)
        let tea = expected.0 == "es" ? "Té" : "Tee"
        #expect(String(format: try localized("%@ selected", in: expected.0), tea) == expected.3)
    }

    @Test(arguments: [("es", "Logotipo"), ("de", "Wortmarke")])
    func wordmarkIsTranslated(_ expected: (String, String)) throws {
        #expect(try localized("Wordmark", in: expected.0) == expected.1)
    }

    @Test func ratingSpeaksFromThePackageBundle() {
        #expect(Rating(4.9).spokenValue == "4.9 out of 5 stars")
    }
}
