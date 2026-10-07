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
                        Artwork(samplePhoto, size: .small, label: lakeDescription)
                            .spokenCaption()
                        Artwork(samplePhoto, size: .medium, label: lakeDescription)
                            .spokenCaption()
                    }
                    Artwork(samplePhoto, size: .large, label: lakeDescription)
                        .spokenCaption()
                }
            },
            Variant("Fill") {
                Artwork(samplePhoto, size: .fill, label: lakeDescription)
                    .spokenCaption()
                    .frame(height: 200)
            },
            Variant("Sources") {
                HStack(alignment: .top, spacing: 16) {
                    // A wordmark is wide: fit it rather than crop it to the square.
                    Artwork(.symbol(.wordmark), size: .small, contentMode: .fit, label: "next.app wordmark")
                        .spokenCaption()
                    Artwork(.file("nextapp"), size: .small, label: "next.app icon")
                        .spokenCaption()
                    Artwork(samplePhoto, size: .small, label: lakeDescription)
                        .spokenCaption()
                }
            },
            Variant("Loading and failure") {
                HStack(alignment: .top, spacing: 16) {
                    Artwork(.loading, size: .small, label: lakeDescription)
                        .spokenCaption()
                    Artwork(missingPhoto, size: .small, label: lakeDescription)
                        .spokenCaption()
                    // No label: decorative, so VoiceOver skips it.
                    Artwork(.file("definitely-not-an-image"), size: .small)
                        .spokenCaption()
                }
            },
            // Each one a `mock://` URL, held in its state by MockImageLoader.
            Variant("Remote") {
                HStack(alignment: .top, spacing: 16) {
                    Artwork(samplePhoto, size: .small, label: lakeDescription)
                        .spokenCaption()
                    Artwork(slowPhoto, size: .small, label: lakeDescription)
                        .spokenCaption()
                    Artwork(loadingPhoto, size: .small, label: lakeDescription)
                        .spokenCaption()
                    Artwork(missingPhoto, size: .small, label: lakeDescription)
                        .spokenCaption()
                }
            },
        ]
    )
}
