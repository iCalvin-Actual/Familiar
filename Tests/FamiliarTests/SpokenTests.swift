import SwiftUI
import Testing
@testable import Familiar

/// Each component's `spoken` is what it hands VoiceOver, so these pin down
/// what VoiceOver hears.
@MainActor
struct SpokenTests {

    @Test func combiningMergesLabelsAndTraits() {
        let merged = Spoken(combining: [Spoken("Lake", traits: .image), Spoken("", value: "Loading")], adding: .button)
        #expect(merged == Spoken("Lake", value: "Loading", traits: [.image, .button]))
        #expect(Spoken(combining: []) == nil)
    }

    @Test func chipsReadTheirTextAndState() {
        #expect(Familiar.Chip("Unread", badge: "3").spoken == Spoken("Unread, 3"))
        #expect(Familiar.Chip("Tea", isSelected: true, behavior: .button {}).spoken == Spoken("Tea", traits: [.selected, .button]))
        // Leaves the SF Symbol's own description in place.
        #expect(Familiar.Chip(.systemIcon("star")).spoken.label.isEmpty)
    }

    @Test func iconsAreImagesOrHidden() {
        #expect(Icon(source: .symbol(.wordmark)).spoken == Spoken("Wordmark", traits: .image))
        #expect(Icon(source: .system("star")).spoken == Spoken("", traits: .image))
        #expect(Icon(source: .file("nextapp")).spoken == nil)
    }

}
