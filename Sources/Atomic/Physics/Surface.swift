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

    /// Lets this glass morph with its neighbours when a row has handed it an
    /// id and namespace. Apply it straight after `familiarGlass`; anywhere
    /// else it does nothing.
    func familiarGlassID() -> some View {
        modifier(GlassID())
    }
}

extension EnvironmentValues {
    /// Set by a row of glass so its members can morph into one another.
    @Entry var glassNamespace: Namespace.ID? = nil
    /// This member's identity within `glassNamespace`.
    @Entry var glassID: String? = nil
}

private struct GlassID: ViewModifier {
    @Environment(\.glassNamespace) private var namespace
    @Environment(\.glassID) private var id

    func body(content: Content) -> some View {
        #if os(visionOS)
        content
        #else
        if let namespace, let id {
            content.glassEffectID(id, in: namespace)
        } else {
            content
        }
        #endif
    }
}

/// Glass that sits close enough to blend and morph. visionOS has no Liquid
/// Glass, so there it's only the content.
struct GlassContainer<Content: View>: View {
    let spacing: CGFloat?
    @ViewBuilder let content: Content

    var body: some View {
        #if os(visionOS)
        content
        #else
        GlassEffectContainer(spacing: spacing) { content }
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
