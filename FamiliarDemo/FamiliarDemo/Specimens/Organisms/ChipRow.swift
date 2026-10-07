//
//  ChipRow.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

private struct ChipRowSelection: View {
    @State private var selected: Set<String> = ["Tea"]
    private let drinks = ["Coffee", "Tea", "Juice", "Smoothies", "Cocktails", "Mocktails"]

    var body: some View {
        ChipRow(chips: drinks.map { drink in
            Chip(drink, isSelected: selected.contains(drink), behavior: .button {
                if selected.remove(drink) == nil { selected.insert(drink) }
            })
        })
        .spokenCaption()
    }
}

extension Specimen {
    static let chipRow = Specimen(
        name: "ChipRow",
        summary: "A single line of chips that scrolls when it overflows.",
        variants: [
            Variant("Row", bleeds: true) {
                ChipRow(chips: [
                    Chip("All", isSelected: true),
                    Chip("Unread", badge: "3"),
                    Chip("Starred"),
                ])
                .spokenCaption()
            },
            Variant("Header", bleeds: true) {
                ChipRow(
                    header: SectionHeader("Drinks", subtitle: "Something for every hour", action: Button("See all", prominence: .plain) {}),
                    chips: ["Coffee", "Tea", "Juice", "Smoothies", "Cocktails", "Mocktails", "Beer", "Wine"].map { Chip($0) }
                )
                .spokenCaption()
            },
            Variant("Selection", bleeds: true) { ChipRowSelection() },
            Variant("Mixed behaviors", bleeds: true) {
                ChipRow(chips: [
                    Chip(
                        "Sort",
                        systemIcon: "arrow.up.arrow.down",
                        behavior: .menu {
                            SwiftUI.Button("Newest first") {}
                            SwiftUI.Button("Oldest first") {}
                        }
                    ),
                    Chip("Filters", systemIcon: "line.3.horizontal.decrease", badge: "2", isSelected: true, behavior: .button {}),
                    Chip("12 results"),
                ])
                .spokenCaption()
            },
        ]
    )
}
