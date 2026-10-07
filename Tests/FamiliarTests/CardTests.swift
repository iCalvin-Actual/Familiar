import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct CardTests {

    @Test func chipsAreAlwaysStatic() throws {
        let card = Card(
            image: LabeledImage(.file("nextapp"), title: "Next App"),
            chips: [Familiar.Chip("Tap", badge: "2", isSelected: true, behavior: .button {})],
            cta: Familiar.Button("Open") {}
        )
        let chip = try #require(card.chips.first)
        #expect(chip.behavior.isInteractive == false)
        #expect(chip.label == .text("Tap"))
        #expect(chip.badge == .text("2"))
        #expect(chip.isSelected)
    }

    @Test func labelsAreAlwaysSecondary() throws {
        let card = Card(
            image: LabeledImage(.file("nextapp"), title: "Next App"),
            labels: [Familiar.Label(text: "Loud", emphasis: .accent, lineLimit: 2)],
            cta: Familiar.Button("Open") {}
        )
        let label = try #require(card.labels.first)
        #expect(label.emphasis == .secondary)
        #expect(label.style == .text("Loud"))
        #expect(label.lineLimit == 2)
    }

    @Test func cornersAreConcentricWithTheImage() {
        let card = Card(image: LabeledImage(.file("nextapp"), title: "Next App", size: .small), cta: Familiar.Button("Open") {})
        #expect(card.cornerRadius == Artwork.Size.small.cornerRadius + Card.padding)
    }

    @Test func defaultsToNoLabelsOrChips() {
        let card = Card(image: LabeledImage(.file("nextapp"), title: "Next App"), cta: Familiar.Button("Open") {})
        #expect(card.rating == nil)
        #expect(card.labels.isEmpty)
        #expect(card.chips.isEmpty)
    }
}
