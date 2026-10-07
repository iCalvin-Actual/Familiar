//
//  ChipRow.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// A single line of chips that scrolls when it overflows, under an optional
/// header. Inset inside the scroll view, so chips scroll edge to edge but rest
/// in line with the header and the page. The chips share one glass container,
/// so they morph as they change.
public struct ChipRow: View {
    public let header: SectionHeader?
    public let chips: [Chip]
    public let inset: CGFloat

    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled
    @Environment(\.forcedVoiceOver) private var forcedVoiceOver
    @Namespace private var glassNamespace

    public init(header: SectionHeader? = nil, chips: [Chip], inset: CGFloat = Spacing.xLarge) {
        self.header = header
        self.chips = chips
        self.inset = inset
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            if let header {
                header
                    .padding(.horizontal, inset)
            }
            ScrollView(.horizontal) {
                GlassContainer(spacing: Spacing.small) {
                    HStack(spacing: Spacing.small) {
                        // By position: two identical chips are a legitimate request.
                        ForEach(Array(chips.enumerated()), id: \.offset) { index, chip in
                            chip
                                .environment(\.glassNamespace, glassNamespace)
                                .environment(\.glassID, "chip-\(index)")
                        }
                    }
                }
                .padding(.horizontal, inset)
            }
            .scrollIndicators(.hidden)
            .modifier(OneStop(isActive: (forcedVoiceOver ?? isVoiceOverEnabled) && speaksAsOne, row: self))
        }
    }
}

// MARK: - Accessibility

extension ChipRow {

    /// A menu can't open from a custom action, so a row holding one keeps
    /// its chips as separate elements.
    var speaksAsOne: Bool {
        !chips.contains { if case .menu = $0.behavior { true } else { false } }
    }

    /// Overridable with `.accessibilityLabel` where the row is used.
    var spokenLabel: String {
        header?.title ?? String(localized: "Filters", bundle: .familiar, comment: "VoiceOver label for a row of chips with no header.")
    }

    /// What's chosen, then anything the chips only display: "Tea and Juice selected, 12 results".
    var spokenValue: String {
        let selected = chips.filter(\.isSelected).compactMap(\.spokenText)
        let displayed = chips.filter { !$0.isSelected && !$0.behavior.isInteractive }.compactMap(\.spokenText)
        var parts: [String] = []
        if !selected.isEmpty {
            let list = selected.formatted(.list(type: .and))
            parts.append(String(localized: "\(list) selected", bundle: .familiar, comment: "VoiceOver value for a chip row, e.g. “Tea and Juice selected”."))
        } else if chips.contains(where: \.behavior.isInteractive) {
            parts.append(String(localized: "Nothing selected", bundle: .familiar, comment: "VoiceOver value for a chip row with no chip selected."))
        }
        return (parts + displayed).joined(separator: ", ")
    }

    var spoken: Spoken {
        Spoken(spokenLabel, value: spokenValue, actions: spokenActions.map(\.title))
    }

    /// One per button chip, named by its title alone, so the names hold
    /// still as selection changes and the rotor keeps its place.
    var spokenActions: [(title: String, perform: () -> Void)] {
        chips.compactMap { chip in
            guard case .button(let perform) = chip.behavior, let title = chip.spokenTitle else { return nil }
            return (title, perform)
        }
    }

    /// The row reads as one stop, with each chip as a custom action. Only
    /// under VoiceOver: keyboard, Switch Control and UI tests keep the real
    /// per-chip controls. Outside a row, each chip reads on its own.
    private struct OneStop: ViewModifier {
        let isActive: Bool
        let row: ChipRow

        func body(content: Content) -> some View {
            if isActive {
                content
                    .accessibilityElement(children: .ignore)
                    .spoken(row.spoken)
                    .accessibilityActions {
                        ForEach(Array(row.spokenActions.enumerated()), id: \.offset) { _, action in
                            SwiftUI.Button(action.title, action: action.perform)
                        }
                    }
            } else {
                content
            }
        }
    }
}

// MARK: - Previews

#Preview("Row") {
    ChipRow(chips: [
        Chip("All", isSelected: true),
        Chip("Unread", badge: "3"),
        Chip("Starred"),
    ])
    .padding(.vertical, 24)
    .backdrop()
}

#Preview("Overflow") {
    ChipRow(chips: ["Coffee", "Tea", "Juice", "Smoothies", "Cocktails", "Mocktails", "Beer", "Wine"].map { Chip($0) })
        .padding(.vertical, 24)
        .backdrop()
}

#Preview("Header") {
    VStack(alignment: .leading, spacing: 32) {
        ChipRow(
            header: SectionHeader("Drinks"),
            chips: ["Coffee", "Tea", "Juice", "Smoothies", "Cocktails", "Mocktails"].map { Chip($0) }
        )
        ChipRow(
            header: SectionHeader(
                "Drinks",
                subtitle: "Something for every hour",
                action: Button("See all", prominence: .plain) {}
            ),
            chips: ["Coffee", "Tea", "Juice", "Smoothies", "Cocktails", "Mocktails"].map { Chip($0) }
        )
    }
    .padding(.vertical, 24)
    .backdrop()
}

#Preview("Selection") {
    @Previewable @State var selected: Set<String> = ["Tea"]
    let drinks = ["Coffee", "Tea", "Juice", "Smoothies", "Cocktails"]

    ChipRow(chips: drinks.map { drink in
        Chip(drink, isSelected: selected.contains(drink), behavior: .button {
            if selected.remove(drink) == nil { selected.insert(drink) }
        })
    })
    .padding(.vertical, 24)
    .backdrop()
}

#Preview("Mixed behaviors") {
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
    .padding(.vertical, 24)
    .backdrop()
}

#Preview("Accessibility XL") {
    ChipRow(header: SectionHeader("Inbox", subtitle: "Filter by status", action: Button("Edit", prominence: .plain) {}), chips: [
        Chip("All", isSelected: true),
        Chip("Unread", badge: "3"),
        Chip("Starred"),
    ])
    .padding(.vertical, 24)
    .backdrop()
    .dynamicTypeSize(.accessibility3)
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            ChipRow(header: SectionHeader("Inbox", action: Button("Edit", prominence: .plain) {}), chips: [
                Chip("All", isSelected: true),
                Chip("Unread", badge: "3", behavior: .button {}),
                Chip("Starred"),
            ])
            .padding(.vertical, 24)
            .backdrop()
            .environment(\.colorScheme, scheme)
        }
    }
}
