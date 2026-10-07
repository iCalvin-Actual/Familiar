import SwiftUI
import Testing
@testable import Familiar

struct FlowLayoutTests {

    @Test func wrapsWhenTheNextViewWontFit() {
        let lines = FlowLayout.lines(for: [40, 40, 40], maxWidth: 100, spacing: 8)
        #expect(lines == [[0, 1], [2]])
    }

    @Test func spacingCountsTowardTheLine() {
        #expect(FlowLayout.lines(for: [50, 50], maxWidth: 100, spacing: 0) == [[0, 1]])
        #expect(FlowLayout.lines(for: [50, 50], maxWidth: 100, spacing: 8) == [[0], [1]])
    }

    @Test func oversizedViewsGetALineOfTheirOwn() {
        let lines = FlowLayout.lines(for: [20, 500, 20], maxWidth: 100, spacing: 8)
        #expect(lines == [[0], [1], [2]])
    }

    @Test func unboundedWidthIsOneLine() {
        #expect(FlowLayout.lines(for: [40, 40, 40], maxWidth: .infinity, spacing: 8) == [[0, 1, 2]])
    }

    @Test func noViewsNoLines() {
        #expect(FlowLayout.lines(for: [], maxWidth: 100, spacing: 8).isEmpty)
    }
}
