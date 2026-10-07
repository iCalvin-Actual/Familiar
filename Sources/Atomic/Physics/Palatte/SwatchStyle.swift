//
//  SwatchStyle.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import Foundation
import SwiftUI

public struct SwatchStyle: ShapeStyle {
    public let swatch: Swatch

    public init(_ swatch: Swatch) {
        self.swatch = swatch
    }

    public func resolve(in environment: EnvironmentValues) -> Color {
        swatch.color(in: environment.colorScheme, contrast: environment.colorSchemeContrast)
    }
}

public extension ShapeStyle where Self == SwatchStyle {
    /// `.foregroundStyle(.swatch(.hex(0x4F46E5)))`
    static func swatch(_ swatch: Swatch) -> SwatchStyle {
        SwatchStyle(swatch)
    }
}
