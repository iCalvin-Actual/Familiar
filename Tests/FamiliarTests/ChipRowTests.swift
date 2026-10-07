import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct ChipRowTests {

    @Test func namedByItsHeader() {
        #expect(ChipRow(header: SectionHeader("Drinks"), chips: []).spokenLabel == "Drinks")
        #expect(ChipRow(chips: []).spokenLabel == "Filters")
    }

    @Test func readsWhatsSelected() {
        let row = ChipRow(chips: [
            Familiar.Chip("Coffee", behavior: .button {}),
            Familiar.Chip("Tea", isSelected: true, behavior: .button {}),
            Familiar.Chip("Juice", isSelected: true, behavior: .button {}),
        ])
        #expect(row.spokenValue == "Tea and Juice selected")
    }

    @Test func saysWhenNothingIsSelected() {
        let row = ChipRow(chips: [Familiar.Chip("Coffee", behavior: .button {})])
        #expect(row.spokenValue == "Nothing selected")
    }

    @Test func displayChipsJoinTheValue() {
        let row = ChipRow(chips: [
            Familiar.Chip("Filters", badge: "2", isSelected: true, behavior: .button {}),
            Familiar.Chip("12 results"),
        ])
        #expect(row.spokenValue == "Filters, 2 selected, 12 results")
    }

    @Test func displayOnlyRowsReadEveryChip() {
        let row = ChipRow(chips: [Familiar.Chip("Unread", badge: "3"), Familiar.Chip("Starred")])
        #expect(row.spokenValue == "Unread, 3, Starred")
    }

    @Test func actionsAreButtonChipsByTitle() {
        var tapped: [String] = []
        let row = ChipRow(chips: [
            Familiar.Chip("Coffee", badge: "4", behavior: .button { tapped.append("Coffee") }),
            Familiar.Chip("Tea", isSelected: true, behavior: .button { tapped.append("Tea") }),
            Familiar.Chip("12 results"),
        ])
        // Badge and selection stay out of the name, so it doesn't change under the rotor.
        #expect(row.spokenActions.map(\.title) == ["Coffee", "Tea"])
        row.spokenActions.forEach { $0.perform() }
        #expect(tapped == ["Coffee", "Tea"])
    }

    @Test func menusKeepTheirOwnElements() {
        #expect(ChipRow(chips: [Familiar.Chip("Coffee", behavior: .button {})]).speaksAsOne)
        #expect(!ChipRow(chips: [Familiar.Chip("Sort", behavior: .menu { EmptyView() })]).speaksAsOne)
    }
}
