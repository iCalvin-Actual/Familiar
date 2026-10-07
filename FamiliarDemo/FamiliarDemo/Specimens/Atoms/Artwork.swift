//
//  Artwork.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let artwork = Specimen(
        name: "Artwork",
        summary: "Content imagery that keeps its own colours and may arrive over the network.",
        variants: [
            Variant("Sizes") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        Artwork(samplePhoto, size: .small)
                        Artwork(samplePhoto, size: .medium)
                    }
                    Artwork(samplePhoto, size: .large)
                }
            },
            Variant("Fill") {
                Artwork(samplePhoto, size: .fill)
                    .frame(height: 200)
            },
            Variant("Sources") {
                HStack(alignment: .top, spacing: 16) {
                    // A wordmark is wide: fit it rather than crop it to the square.
                    Artwork(.symbol(.wordmark), size: .small, contentMode: .fit)
                    Artwork(.file("nextapp"), size: .small)
                    Artwork(samplePhoto, size: .small)
                }
            },
            Variant("Loading and failure") {
                HStack(alignment: .top, spacing: 16) {
                    Artwork(.loading, size: .small)
                    Artwork(missingPhoto, size: .small)
                    Artwork(.file("definitely-not-an-image"), size: .small)
                }
            },
            // Each one a `mock://` URL, held in its state by MockImageLoader.
            Variant("Remote") {
                HStack(alignment: .top, spacing: 16) {
                    Artwork(samplePhoto, size: .small)
                    Artwork(slowPhoto, size: .small)
                    Artwork(loadingPhoto, size: .small)
                    Artwork(missingPhoto, size: .small)
                }
            },
        ]
    )
}
