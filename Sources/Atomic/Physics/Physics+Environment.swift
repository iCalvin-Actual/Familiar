//
//  Physics+Environment.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    /// The colour `Typography.Emphasis.accent` draws in.
    @Entry public var accentSwatch: Swatch = .accent

    /// The family `Typography.Face.display` resolves to. `nil` means the
    /// system font.
    @Entry public var displayFamily: FontFamily? = nil

    /// The resolved (post-Dynamic-Type) point size of the nearest enclosing
    /// `typography(_:)` scope.
    @Entry public var typographyPointSize: CGFloat = 17
}

// Before @Entry, each value needed its own key and accessor:
//
// private struct AccentSwatchKey: EnvironmentKey {
//     static let defaultValue: Swatch = .accent
// }
//
// extension EnvironmentValues {
//     public var accentSwatch: Swatch {
//         get { self[AccentSwatchKey.self] }
//         set { self[AccentSwatchKey.self] = newValue }
//     }
// }

public extension View {
    func accentSwatch(_ swatch: Swatch) -> some View {
        environment(\.accentSwatch, swatch)
    }

    /// Any SwiftUI colour as the accent, such as one from the app's own palette.
    func accentSwatch(_ color: Color) -> some View {
        accentSwatch(.system(color))
    }

    func displayFamily(_ family: FontFamily?) -> some View {
        environment(\.displayFamily, family)
    }
}
