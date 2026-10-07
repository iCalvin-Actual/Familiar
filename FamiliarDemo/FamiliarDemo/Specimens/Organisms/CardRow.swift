//
//  CardRow.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

private func park(_ name: String, rating: Double? = nil, chips: [String], size: Artwork.Size = .fill) -> Card {
    Card(
        image: LabeledImage(samplePhoto, title: name, size: size),
        rating: rating.map { Rating($0, style: .regular) },
        labels: [Label(text: "National park", systemIcon: "leaf", size: .body2)],
        chips: chips.map { Chip($0) },
        cta: Button("Plan a visit", width: .fill) {}
    )
}

extension Specimen {
    static let cardRow = Specimen(
        name: "CardRow",
        summary: "Cards that scroll and snap one by one.",
        variants: [
            Variant("Row", bleeds: true) {
                CardRow(
                    header: SectionHeader("Parks", subtitle: "Lakes worth the drive", action: Button("See all", prominence: .plain) {}),
                    cards: [
                        park("Crater Lake", rating: 4.9, chips: ["Hiking", "Swimming"]),
                        park("Yellowstone", rating: 4.2, chips: ["Geysers", "Wildlife", "Hiking", "Camping", "Fishing"]),
                        park("Glacier", chips: ["Hiking"]),
                    ]
                )
            },
            Variant("No header", bleeds: true) {
                CardRow(cards: [
                    park("Crater Lake", chips: ["Hiking"], size: .small),
                    park("Yellowstone", chips: ["Geysers", "Wildlife", "Camping"], size: .small),
                    park("Glacier", chips: ["Hiking"], size: .small),
                ])
            },
        ]
    )
}
