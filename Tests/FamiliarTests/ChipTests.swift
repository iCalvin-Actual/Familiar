import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct ChipTests {

    @Test func selectedDrawsInTheFullAccent() {
        let tint = Familiar.Chip.Style.tint(isSelected: true, accent: .highlight)
        #expect(tint?.swatch == .highlight)
        #expect(tint?.opacity == 1)
    }

    @Test func restLeavesTheGlassClear() {
        #expect(Familiar.Chip.Style.tint(isSelected: false, accent: .accent) == nil)
    }

    @Test func defaultsToUnselectedSmallDisplay() {
        let chip = Familiar.Chip("Tag")
        #expect(chip.label == .text("Tag"))
        #expect(chip.badge == nil)
        #expect(chip.isSelected == false)
        #expect(chip.typography == .small)
        #expect(chip.behavior.isInteractive == false)

        let style = Familiar.Chip.Style()
        #expect(style.isSelected == false)
        #expect(style.typography == .small)
    }

    @Test func buttonsAndMenusAreInteractive() {
        #expect(Familiar.Chip.Behavior.button {}.isInteractive)
        #expect(Familiar.Chip.Behavior.menu { EmptyView() }.isInteractive)
    }

    @Test func textAndSystemIconBuildsTheLabel() {
        let chip = Familiar.Chip("Sort", systemIcon: "arrow.up.arrow.down", badge: "3")
        #expect(chip.label == .textIcon("Sort", .system("arrow.up.arrow.down")))
        #expect(chip.badge == .text("3"))
    }

    @Test func speaksItsTitleThenItsBadge() {
        let chip = Familiar.Chip("Unread", badge: "3")
        #expect(chip.spokenTitle == "Unread")
        #expect(chip.spokenText == "Unread, 3")
    }

    @Test func iconOnlyChipsSpeakTheirLabel() {
        #expect(Familiar.Chip(.icon(.symbol(.wordmark))).spokenText == "Wordmark")
        #expect(Familiar.Chip(.systemIcon("star", label: "Starred")).spokenText == "Starred")
        // An unlabelled SF Symbol or file has nothing for a row to say.
        #expect(Familiar.Chip(.systemIcon("star")).spokenText == nil)
        #expect(Familiar.Chip(.icon(.file("nextapp"))).spokenText == nil)
    }

    @Test func badgeScalesWithTheLabel() {
        let chip = Familiar.Chip("Filter", badge: "3", size: .medium)
        #expect(chip.badgeTypography.size == Typography.medium.size * 0.8)
        #expect(chip.badgeTypography.relativeTo == Typography.medium.relativeTo)
    }
}
