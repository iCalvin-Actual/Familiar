import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct CardRowTests {

    private let card = Card(image: LabeledImage(.file("nextapp"), title: "Next App"), cta: Familiar.Button("Open") {})

    @Test func defaults() {
        let row = CardRow(cards: [card])
        #expect(row.header == nil)
        #expect(row.cardWidth == 260)
        #expect(row.inset == 24)
    }
}
