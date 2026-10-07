//
//  Card.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// A labeled image, an optional rating, supporting labels, a row of static
/// chips, and a call to action.
public struct Card: View {

    public let image: LabeledImage
    public let rating: Rating?
    /// Always secondary, whatever emphasis they were built with.
    public let labels: [Label]
    /// Always shown as display chips, whatever behavior they were built with.
    public let chips: [Chip]
    public let cta: Button

    static let padding = Spacing.large
    /// Wide enough for a phone; on iPad and Mac a card stays card-shaped
    /// instead of stretching across the page.
    public static let maxWidth: CGFloat = 400

    public init(image: LabeledImage, rating: Rating? = nil, labels: [Label] = [], chips: [Chip] = [], cta: Button) {
        self.image = image
        self.rating = rating
        self.labels = labels.map {
            Label(style: $0.style, size: $0.typography, emphasis: .secondary, lineLimit: $0.lineLimit)
        }
        self.chips = chips.map {
            Chip($0.label, badge: $0.badge, isSelected: $0.isSelected, size: $0.typography)
        }
        self.cta = cta
    }

    /// Concentric with the image's corners.
    var cornerRadius: CGFloat {
        image.size.cornerRadius + Self.padding
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        VStack(alignment: .leading, spacing: Spacing.large) {
            image
            if rating != nil || !labels.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    rating
                    // By position, like ChipRow.
                    ForEach(Array(labels.enumerated()), id: \.offset) { _, label in
                        label
                    }
                }
            }
            if !chips.isEmpty {
                FlowLayout {
                    ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
                        chip
                    }
                }
            }
            cta
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Self.padding)
        .background(.swatch(.surface), in: shape)
        .overlay(shape.strokeBorder(.swatch(.hairline)))
        .frame(maxWidth: Self.maxWidth)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Previews

private let lake = Artwork.Source.bundle("lake", .familiar)

#Preview("Default") {
    ScrollView {
        Card(
            image: LabeledImage(lake, title: "Crater Lake", size: .fill),
            rating: Rating(4.9),
            labels: [
                Label(text: "Oregon, United States", systemIcon: "mappin.and.ellipse", size: .body2),
                Label(text: "The deepest lake in the country, fed almost entirely by snow.", size: .body2, lineLimit: 2),
            ],
            chips: [
                Chip("Hiking"),
                Chip("Swimming"),
                Chip("Camping"),
                Chip("Scenic drives"),
            ],
            cta: Button("Plan a visit", width: .fill) {}
        )
        .padding(24)
    }
    .backdrop()
}

#Preview("Minimal") {
    Card(
        image: LabeledImage(lake, title: "Crater Lake", size: .medium),
        cta: Button("Plan a visit", prominence: .tinted, width: .fill) {}
    )
    .padding(24)
    .backdrop()
}

#Preview("Loading") {
    Card(
        image: LabeledImage(.loading, title: "Loading…", size: .medium),
        labels: [Label(text: "Fetching details", size: .body2)],
        chips: [Chip("Tag"), Chip("Tag")],
        cta: Button("Plan a visit", width: .fill) {}
    )
    .padding(24)
    .backdrop()
}

#Preview("Accessibility XL") {
    ScrollView {
        Card(
            image: LabeledImage(lake, title: "Crater Lake", size: .medium),
            rating: Rating(4.9),
            labels: [Label(text: "Oregon, United States", systemIcon: "mappin.and.ellipse", size: .body2)],
            chips: [Chip("Hiking"), Chip("Swimming"), Chip("Camping")],
            cta: Button("Plan a visit", width: .fill) {}
        )
        .padding(24)
    }
    .backdrop()
    .dynamicTypeSize(.accessibility3)
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            Card(
                image: LabeledImage(lake, title: "Crater Lake", size: .small),
                rating: Rating(4.5, style: .regular),
                labels: [Label(text: "Oregon, United States", size: .body2)],
                chips: [Chip("Hiking"), Chip("Swimming", isSelected: true)],
                cta: Button("Plan a visit", prominence: .glass(.accent), width: .fill) {}
            )
            .padding(24)
            .backdrop()
            .environment(\.colorScheme, scheme)
        }
    }
}
