//
//  BrandFont.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import Foundation
import SwiftUI

/// The families bundled with this package. Each carries `Bundle.module`, so
/// its files are registered the first time it's used.
public extension FontFamily {

    /// Sharpie Variable — Indian Type Foundry, via Fontshare, ITF Free Font
    /// License. One file, `wght` 300–900.
    static let sharpie = variableFamily(
        name: "Sharpie Variable",
        postScriptName: "SharpieVariable-Black",
        weightClass: 900,
        weightAxis: 300...900,
        bundle: .module
    )

    /// Array — Indian Type Foundry, via Fontshare, ITF Free Font License.
    static let array = staticFamily(
        name: "Array",
        faces: [
            Face("Array-Regular", weightClass: 400),
            Face("Array-Semibold", weightClass: 500),
            Face("Array-Bold", weightClass: 700),
        ],
        bundle: .module
    )

    /// Array's wide cut. Width ships as separate files rather than an axis,
    /// so it's a separate family.
    static let arrayWide = staticFamily(
        name: "Array Wide",
        faces: [
            Face("Array-Wide", weightClass: 400),
            Face("Array-SemiboldWide", weightClass: 500),
            Face("Array-BoldWide", weightClass: 700),
        ],
        bundle: .module
    )

    /// The brand's display family. Apps opt in with `.displayFamily(.display)`.
    static let display = sharpie

    /// Every bundled family, in the order the catalog should show them.
    static let all: [FontFamily] = [.sharpie, .array, .arrayWide]
}

// MARK: - Previews

#Preview("Families") {
    VStack(alignment: .leading, spacing: 16) {
        ForEach(FontFamily.all, id: \.self) { family in
            VStack(alignment: .leading, spacing: 4) {
                Text(family.isAvailable ? family.name : "\(family.name): not registered")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                ForEach([Font.Weight.regular, .semibold, .bold, .black], id: \.self) { weight in
                    Text("Familiar · \(Int(weight.numericWeight))")
                        .font(family.font(size: 24, weight: weight) ?? .system(size: 24, weight: weight))
                }
            }
        }
    }
    .padding()
    .frame(width: 375, alignment: .leading)
}
