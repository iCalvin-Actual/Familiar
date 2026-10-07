import Foundation
import Testing
@testable import Familiar

@MainActor
struct RatingTests {

    @Test func defaultsToTheGateOutOfFiveWithOneDecimal() {
        let rating = Rating(4.74)
        #expect(rating.style == nil)
        #expect(rating.maximum == 5)
        #expect(rating.swatch == .caution)
        #expect(rating.typography == .small)
        #expect(rating.formattedValue == 4.74.formatted(.number.precision(.fractionLength(1))))
    }

    @Test func customFormatStyleSnapsToWholeNumbers() {
        let rating = Rating(4.74, format: .number.precision(.fractionLength(0)))
        #expect(rating.formattedValue == 5.0.formatted(.number.precision(.fractionLength(0))))
    }

    @Test func numberFormatter() {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        #expect(Rating(3.2, formatter: formatter).formattedValue == "3")
    }

    @Test func starsFillToTheNearestHalf() {
        #expect(Rating.stars(for: 3.5, outOf: 5) == [.full, .full, .full, .half, .empty])
        #expect(Rating.stars(for: 3.74, outOf: 5) == [.full, .full, .full, .half, .empty])
        #expect(Rating.stars(for: 3.76, outOf: 5) == [.full, .full, .full, .full, .empty])
        #expect(Rating.stars(for: 0.2, outOf: 5) == [.empty, .empty, .empty, .empty, .empty])
    }

    @Test func starsClampToTheScale() {
        #expect(Rating.stars(for: 9, outOf: 3) == [.full, .full, .full])
        #expect(Rating.stars(for: -1, outOf: 3) == [.empty, .empty, .empty])
        #expect(Rating.stars(for: 3, outOf: 0).isEmpty)
    }
}
