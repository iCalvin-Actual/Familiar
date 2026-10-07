//
//  Backdrop.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

/// Something for glass to refract.
struct Backdrop: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
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
