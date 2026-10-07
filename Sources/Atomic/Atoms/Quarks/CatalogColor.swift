//
//  CatalogColor.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// Colours defined in `Colors.xcassets` rather than as hex pairs in
/// `BrandColor`.
///
/// Reach for the catalog when a colour needs more than light and dark: an
/// Increase Contrast variant, or a wide-gamut (Display P3) value that `Hex`,
/// being sRGB, can't express. The system resolves every variant itself.
///
/// For each colour set added to the catalog, declare it here and list it in
/// `catalog`.
public extension Swatch {

    /// Elevated backgrounds: cards, sheets, grouped rows.
    static let surface = Swatch.bundle("surface", .familiar)

    /// Separators and outlines. Darkens under Increase Contrast.
    static let hairline = Swatch.bundle("hairline", .familiar)

    /// A Display P3 orange, more vivid than sRGB allows on wide-gamut screens.
    static let highlight = Swatch.bundle("highlight", .familiar)

    /// Every catalog colour, in the order the catalog should show them.
    static let catalog: [Swatch] = [.surface, .hairline, .highlight]
}

// MARK: - Previews

#Preview("Catalog colours") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Swatch.catalog, id: \.self) { swatch in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.swatch(swatch))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(.swatch(.hairline))
                            }
                            .frame(width: 44, height: 44)
                        Text(swatch.name ?? "")
                        Spacer()
                    }
                }
            }
            .foregroundStyle(.swatch(.ink))
            .padding()
            .frame(width: 375)
            .background(.swatch(.canvas))
            .environment(\.colorScheme, scheme)
        }
    }
}
