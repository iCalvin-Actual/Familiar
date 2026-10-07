//
//  LabeledImage.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// An image with a title beneath it: a cover in a grid, or a hero that takes
/// whatever room it's given.
public struct LabeledImage: View {

    public let source: Artwork.Source
    public let title: String
    public let size: Artwork.Size

    public init(_ source: Artwork.Source, title: String, size: Artwork.Size = .medium) {
        self.source = source
        self.title = title
        self.size = size
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Artwork(source, size: size)
            Label(text: title, size: .headline)
                // A cover's caption stays under its cover.
                .frame(width: size.dimension, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .spokenCombined()
    }
}

// MARK: - Previews

private let lake = Artwork.Source.bundle("lake", .familiar)
private let remote = URL(string: "https://picsum.photos/id/1025/600/400")!
private let missing = URL(string: "https://example.invalid/missing.png")!

#Preview("Default") {
    LabeledImage(lake, title: "Lake")
        .padding(24)
}

#Preview("Sizes") {
    VStack(alignment: .leading, spacing: 24) {
        HStack(alignment: .top, spacing: 24) {
            LabeledImage(lake, title: "small", size: .small)
            LabeledImage(lake, title: "medium", size: .medium)
        }
        LabeledImage(lake, title: "large", size: .large)
    }
    .padding(24)
}

#Preview("Fill") {
    LabeledImage(.remote(remote), title: "Big as will fit", size: .fill)
        .frame(width: 320, height: 400)
        .padding(24)
}

#Preview("Sources") {
    Grid(alignment: .topLeading, horizontalSpacing: 24, verticalSpacing: 24) {
        GridRow {
            LabeledImage(.symbol(.wordmark), title: ".symbol")
            LabeledImage(.file("nextapp"), title: ".file")
        }
        GridRow {
            LabeledImage(lake, title: ".bundle")
            LabeledImage(.remote(remote), title: ".remote")
        }
    }
    .padding(24)
}

#Preview("Loading and failure") {
    HStack(alignment: .top, spacing: 16) {
        LabeledImage(.loading, title: "Loading", size: .small)
        LabeledImage(.remote(missing), title: "Failed", size: .small)
        LabeledImage(.file("definitely-not-an-image"), title: "Missing", size: .small)
    }
    .padding(24)
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            HStack(alignment: .top, spacing: 16) {
                LabeledImage(lake, title: "Lake")
                LabeledImage(.loading, title: "Loading")
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.swatch(.canvas))
            .environment(\.colorScheme, scheme)
        }
    }
}
