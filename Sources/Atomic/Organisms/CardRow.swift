//
//  CardRow.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// A line of cards that scrolls and snaps card by card, under an optional
/// header.
public struct CardRow: View {
    public let header: SectionHeader?
    public let cards: [Card]
    public let cardWidth: CGFloat
    public let inset: CGFloat

    public init(header: SectionHeader? = nil, cards: [Card], cardWidth: CGFloat = 260, inset: CGFloat = Spacing.xLarge) {
        self.header = header
        self.cards = cards
        self.cardWidth = cardWidth
        self.inset = inset
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            if let header {
                header
                    .padding(.horizontal, inset)
            }
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: Spacing.large) {
                    ForEach(Array(cards.enumerated()), id: \.offset) { _, card in
                        card
                            .frame(width: cardWidth)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, inset, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Previews

private let lake = Artwork.Source.bundle("lake", .familiar)

@MainActor
private func park(_ name: String, rating: Double? = nil, chips: [String], size: Artwork.Size = .fill) -> Card {
    Card(
        image: LabeledImage(lake, title: name, size: size),
        rating: rating.map { Rating($0, style: .regular) },
        labels: [Label(text: "National park", systemIcon: "leaf", size: .body2)],
        chips: chips.map { Chip($0) },
        cta: Button("Plan a visit", width: .fill) {}
    )
}

#Preview("Row") {
    CardRow(
        header: SectionHeader("Parks", subtitle: "Lakes worth the drive", action: Button("See all", prominence: .plain) {}),
        cards: [
            park("Crater Lake", rating: 4.9, chips: ["Hiking", "Swimming"]),
            park("Yellowstone", rating: 4.2, chips: ["Geysers", "Wildlife", "Hiking", "Camping", "Fishing"]),
            park("Glacier", chips: ["Hiking"]),
        ]
    )
    .padding(.vertical, 24)
    .backdrop()
}

#Preview("No header") {
    CardRow(cards: [
        park("Crater Lake", chips: ["Hiking"], size: .small),
        park("Yellowstone", chips: ["Geysers", "Wildlife", "Camping"], size: .small),
    ])
    .padding(.vertical, 24)
    .backdrop()
}

#Preview("Accessibility XL") {
    ScrollView {
        CardRow(
            header: SectionHeader("Parks", action: Button("See all", prominence: .plain) {}),
            cards: [
                park("Crater Lake", chips: ["Hiking"], size: .small),
                park("Yellowstone", chips: ["Geysers", "Wildlife"], size: .small),
            ],
            cardWidth: 300
        )
        .padding(.vertical, 24)
    }
    .backdrop()
    .dynamicTypeSize(.accessibility3)
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            CardRow(
                header: SectionHeader("Parks", action: Button("See all", prominence: .plain) {}),
                cards: [
                    park("Crater Lake", rating: 4.9, chips: ["Hiking"], size: .small),
                    park("Yellowstone", chips: ["Geysers", "Wildlife", "Camping"], size: .small),
                ]
            )
            .padding(.vertical, 24)
            .backdrop()
            .environment(\.colorScheme, scheme)
        }
    }
}
