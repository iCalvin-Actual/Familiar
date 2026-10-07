//
//  Icon.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let icon = Specimen(
        name: "Icon",
        summary: "SF Symbols, bundled glyphs and loose files, sized by the type scope.",
        variants: [
            Variant("Sources") {
                Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text(".system")
                        Icon(source: .system("star.fill"))
                        Icon(source: .system("star.fill")).foregroundStyle(.swatch(.highlight))
                    }
                    GridRow {
                        Text(".symbol")
                        Icon(source: .symbol(.wordmark))
                        Icon(source: .symbol(.wordmark)).foregroundStyle(.swatch(.highlight))
                    }
                    GridRow {
                        Text(".file")
                        Icon(source: .file("nextapp"))
                        Icon(source: .file("nextapp")).foregroundStyle(.swatch(.highlight))
                    }
                }
                .typography(.title3)
            },
            Variant("Sizes") {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    ForEach([Typography.xSmall, .small, .medium, .large, .xLarge, .xxLarge], id: \.self) { size in
                        Icon(source: .system("bolt.fill"), size: size)
                    }
                }
            },
            Variant("Inherits its scope") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([("title3", Typography.title3), ("body", .body), ("caption", .caption)], id: \.0) { name, size in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Icon(source: .system("star.fill"))
                            Text(name)
                        }
                        .typography(size)
                    }
                }
            },
            Variant("Swatches") {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    ForEach(brandSwatches, id: \.0) { _, swatch in
                        Icon(source: .system("circle.fill"))
                            .foregroundStyle(.swatch(swatch))
                    }
                }
                .typography(.title2)
            },
            Variant("Rendering modes") {
                HStack(alignment: .firstTextBaseline, spacing: 20) {
                    Icon(source: .system("person.crop.circle.badge.checkmark"))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.swatch(.accent))
                    Icon(source: .system("person.crop.circle.badge.checkmark"))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.swatch(.accent))
                    Icon(source: .system("person.crop.circle.badge.checkmark"))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.swatch(.signature), .swatch(.accent))
                    Icon(source: .system("person.crop.circle.badge.checkmark"))
                        .symbolRenderingMode(.multicolor)
                }
                .typography(.xxLarge)
            },
        ]
    )
}
