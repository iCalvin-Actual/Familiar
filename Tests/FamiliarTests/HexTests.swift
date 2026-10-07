import SwiftUI
import Testing
@testable import Familiar

struct HexTests {

    // MARK: Parsing

    @Test(arguments: ["#3B5BDB", "3B5BDB", "  #3B5BDB\n", "#3b5bdb"])
    func parsesSixDigits(_ string: String) throws {
        let hex = try #require(Hex(string))
        #expect(hex.rgb == 0x3B5BDB)
        #expect(hex.opacity == 1)
    }

    @Test func parsesEightDigitsWithAlpha() throws {
        let hex = try #require(Hex("#3B5BDB80"))
        #expect(hex.rgb == 0x3B5BDB)
        #expect(hex.opacity == 128.0 / 255)
    }

    @Test(arguments: ["", "#", "#FFF", "#FFFFF", "#FFFFFFF", "#FFFFFFFFF", "#GGGGGG", "#3B 5BD"])
    func rejectsInvalid(_ string: String) {
        #expect(Hex(string) == nil)
    }

    // MARK: Values

    @Test func masksToTwentyFourBits() {
        let literal: Hex = 0x1FF_FFFF
        #expect(literal.rgb == 0xFF_FFFF)
        #expect(Hex(0xAB_12_34_56).rgb == 0x12_34_56)
    }

    @Test func opacityKeepsRGB() {
        let hex = Hex(0x3B5BDB).opacity(0.5)
        #expect(hex.rgb == 0x3B5BDB)
        #expect(hex.opacity == 0.5)
    }

    @Test func equalityIncludesOpacity() {
        #expect(Hex(0x3B5BDB) == 0x3B5BDB)
        #expect(Hex(0x3B5BDB) != Hex(0x3B5BDB, opacity: 0.5))
    }

    // MARK: Description

    @Test(arguments: [
        (Hex(0x3B5BDB), "#3B5BDB"),
        (Hex(0x00000F), "#00000F"),
        (Hex(0x000000), "#000000"),
        (Hex(0x3B5BDB, opacity: 128.0 / 255), "#3B5BDB80"),
        (Hex(0x3B5BDB, opacity: 0), "#3B5BDB00"),
        (Hex(0x3B5BDB, opacity: -1), "#3B5BDB00"),
    ])
    func description(_ hex: Hex, _ expected: String) {
        #expect(hex.description == expected)
        #expect("\(hex)" == expected)
    }

    @Test(arguments: [
        Hex(0x3B5BDB),
        Hex(0x00000F),
        Hex(0xFFFFFF, opacity: 128.0 / 255),
        Hex(0x3B5BDB, opacity: 0),
    ])
    func roundTripsThroughDescription(_ hex: Hex) {
        #expect(Hex(hex.description) == hex)
    }

    // MARK: Colour

    @Test func resolvesToSRGBComponents() {
        let resolved = Hex(0x3B5BDB, opacity: 0.5).color.resolve(in: EnvironmentValues())
        #expect(abs(Double(resolved.red) - 0x3B / 255.0) < 0.001)
        #expect(abs(Double(resolved.green) - 0x5B / 255.0) < 0.001)
        #expect(abs(Double(resolved.blue) - 0xDB / 255.0) < 0.001)
        #expect(abs(Double(resolved.opacity) - 0.5) < 0.001)
    }
}
