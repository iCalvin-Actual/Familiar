//
//  Swatch.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import Foundation
import SwiftUI


public enum Swatch: Equatable, Hashable, Sendable {
    /// A SwiftUI colour — `.red`, or a semantic one like `.primary`.
    case system(Color)

    /// A named colour from an asset catalog.
    case bundle(String, Bundle)

    /// A literal.
    case hex(Hex)

    /// A brand colour's light/dark pair, picked at draw time.
    case brand(BrandColor)

    /// Defaults to `.main`, matching `Icon.Source.bundle(_:)`.
    public static func bundle(_ name: String) -> Swatch {
        .bundle(name, .main)
    }
}

public extension Swatch {
    /// The colour this resolves to in a given scheme.
    func color(in colorScheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> Color {
        switch self {
        case .system(let color):         color
        case .bundle(let name, let box): Color(name, bundle: box)
        case .hex(let hex):              hex.color
        case .brand(let brand):          brand.color(for: colorScheme, contrast: contrast)
        }
    }

    /// The colour's name, for named swatches; `nil` for system colours and
    /// literals. Only used for diagnostics and the catalog.
    var name: String? {
        switch self {
        case .system, .hex:              nil
        case .bundle(let name, _):       name
        case .brand(let brand):          brand.name
        }
    }
}
