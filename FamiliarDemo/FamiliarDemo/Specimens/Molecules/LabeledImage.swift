//
//  LabeledImage.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let labeledImage = Specimen(
        name: "LabeledImage",
        summary: "Artwork with a title beneath it.",
        variants: [
            Variant("Sizes") {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top, spacing: 24) {
                        LabeledImage(samplePhoto, title: "small", size: .small)
                        LabeledImage(samplePhoto, title: "medium", size: .medium)
                    }
                    LabeledImage(samplePhoto, title: "large", size: .large)
                }
            },
            Variant("Fill") {
                LabeledImage(samplePhoto, title: "Big as will fit", size: .fill)
                    .frame(height: 260)
            },
            Variant("Sources") {
                HStack(alignment: .top, spacing: 16) {
                    LabeledImage(.symbol(.wordmark), title: ".symbol", size: .small)
                    LabeledImage(.file("nextapp"), title: ".file", size: .small)
                    LabeledImage(samplePhoto, title: ".remote", size: .small)
                }
            },
            Variant("Loading and failure") {
                HStack(alignment: .top, spacing: 16) {
                    LabeledImage(.loading, title: "Loading", size: .small)
                    LabeledImage(missingPhoto, title: "Failed", size: .small)
                    LabeledImage(.file("definitely-not-an-image"), title: "Missing", size: .small)
                }
            },
        ]
    )
}
