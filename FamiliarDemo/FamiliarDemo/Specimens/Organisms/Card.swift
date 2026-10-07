//
//  Card.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let card = Specimen(
        name: "Card",
        summary: "A labeled image, a rating, supporting labels, chips, and a call to action.",
        variants: [
            Variant("Default") {
                Card(
                    image: LabeledImage(samplePhoto, title: "Crater Lake", size: .fill),
                    rating: Rating(4.9),
                    labels: [
                        Label(text: "Oregon, United States", systemIcon: "mappin.and.ellipse", size: .body2),
                        Label(text: "The deepest lake in the country, fed almost entirely by snow.", size: .body2, lineLimit: 2),
                    ],
                    chips: ["Hiking", "Swimming", "Camping", "Scenic drives"].map { Chip($0) },
                    cta: Button("Plan a visit", width: .fill) {}
                )
                .spokenCaption()
            },
            Variant("Minimal") {
                Card(
                    image: LabeledImage(samplePhoto, title: "Crater Lake", size: .medium),
                    cta: Button("Plan a visit", prominence: .tinted, width: .fill) {}
                )
                .spokenCaption()
            },
            Variant("Glass CTA") {
                Card(
                    image: LabeledImage(samplePhoto, title: "Crater Lake", size: .small),
                    rating: Rating(4.5, style: .regular),
                    labels: [Label(text: "Oregon, United States", size: .body2)],
                    chips: [Chip("Hiking"), Chip("Swimming", isSelected: true)],
                    cta: Button("Plan a visit", prominence: .glass(.accent), width: .fill) {}
                )
                .spokenCaption()
            },
            Variant("Loading") {
                Card(
                    image: LabeledImage(.loading, title: "Loading…", size: .medium),
                    labels: [Label(text: "Fetching details", size: .body2)],
                    chips: [Chip("Tag"), Chip("Tag")],
                    cta: Button("Plan a visit", width: .fill) {}
                )
                .spokenCaption()
            },
        ]
    )
}

