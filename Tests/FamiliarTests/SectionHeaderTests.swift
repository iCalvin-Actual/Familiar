import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct SectionHeaderTests {

    @Test func defaultsToTitleOnly() {
        let header = SectionHeader("Drinks")
        #expect(header.title == "Drinks")
        #expect(header.subtitle == nil)
        #expect(header.action == nil)
    }
}
