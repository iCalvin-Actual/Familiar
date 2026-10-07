//
//  Surface.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

extension View {
    /// Familiar's glass. `tint` of `nil` is native, uncolored glass.
    ///
    /// visionOS has no Liquid Glass; it gets its own glass material, with the tint laid over it.
    @ViewBuilder
    func familiarGlass<S: InsettableShape>(tint: Color? = nil, interactive: Bool = true, in shape: S) -> some View {
        #if os(visionOS)
        background {
            shape.fill(tint ?? .clear)
        }
        .glassBackgroundEffect(in: shape)
        #else
        glassEffect(.regular.tint(tint).interactive(interactive), in: shape)
        #endif
    }
}

/// Something for glass to refract in previews.
struct Backdrop: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        content.background {
            ZStack {
                Swatch.canvas.color(in: colorScheme, contrast: contrast)
                RadialGradient(
                    colors: [Swatch.accent.color(in: colorScheme, contrast: contrast).opacity(0.18), .clear],
                    center: .topLeading, startRadius: 0, endRadius: 320
                )
                RadialGradient(
                    colors: [Swatch.highlight.color(in: colorScheme, contrast: contrast).opacity(0.12), .clear],
                    center: .bottomTrailing, startRadius: 0, endRadius: 280
                )
            }
            .ignoresSafeArea()
        }
    }
}

extension View {
    func backdrop() -> some View { modifier(Backdrop()) }
}
