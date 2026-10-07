//
//  Rating.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let rating = Specimen(
        name: "Rating",
        summary: "A score, compact as one star and a value, or as a row of stars.",
        variants: [
            Variant("Styles") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach([0, 2.2, 3.5, 4.74, 5], id: \.self) { value in
                        HStack(alignment: .firstTextBaseline, spacing: 24) {
                            Rating(value, style: .compact)
                                .spokenCaption()
                            Rating(value, style: .regular)
                                .spokenCaption()
                        }
                    }
                }
            },
            Variant("Formats") {
                VStack(alignment: .leading, spacing: 12) {
                    Rating(4.74)
                        .spokenCaption()
                    Rating(4.74, format: .number.precision(.fractionLength(0)))
                        .spokenCaption()
                    Rating(4.74, format: .number.precision(.fractionLength(2)))
                        .spokenCaption()
                    Rating(4.74, formatter: {
                        let formatter = NumberFormatter()
                        formatter.maximumFractionDigits = 1
                        formatter.positiveSuffix = " / 5"
                        return formatter
                    }())
                    .spokenCaption()
                }
            },
            Variant("Scales and sizes") {
                VStack(alignment: .leading, spacing: 12) {
                    Rating(7.5, outOf: 10, style: .regular)
                        .spokenCaption()
                    Rating(2, outOf: 3, style: .regular)
                        .spokenCaption()
                    ForEach([Typography.caption, .small, .body, .title3], id: \.self) { size in
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Rating(3.5, size: size)
                                .spokenCaption()
                            Rating(3.5, style: .regular, size: size)
                                .spokenCaption()
                        }
                    }
                }
            },
            Variant("Swatches") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([Swatch.caution, .accent, .signature, .positive], id: \.self) { swatch in
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Rating(4.5, swatch: swatch)
                                .spokenCaption()
                            Rating(4.5, style: .regular, swatch: swatch)
                                .spokenCaption()
                        }
                    }
                }
            },
        ]
    )
}
