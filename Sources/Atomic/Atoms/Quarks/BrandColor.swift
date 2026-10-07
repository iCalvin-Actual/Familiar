//
//  BrandColor.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import Foundation
import SwiftUI

/// A brand colour defined as a light/dark pair of hex values.
///
/// Call sites don't use this directly: each one is also a named `Swatch`
/// (`.swatch(.accent)`), alongside the catalog colours, so a call site never
/// needs to know which way a colour is defined.
public struct BrandColor: Equatable, Hashable, Sendable {

    /// Display name. Only used for diagnostics and the catalog.
    public let name: String

    public let light: Hex

    /// The dark-scheme cut, or `nil` when this colour deliberately doesn't change.
    public let dark: Hex?

    /// Cuts for Increase Contrast. Each falls back to the standard cut for
    /// its scheme.
    public let lightHighContrast: Hex?
    public let darkHighContrast: Hex?

    public init(
        name: String,
        light: Hex,
        dark: Hex? = nil,
        lightHighContrast: Hex? = nil,
        darkHighContrast: Hex? = nil
    ) {
        self.name = name
        self.light = light
        self.dark = dark
        self.lightHighContrast = lightHighContrast
        self.darkHighContrast = darkHighContrast
    }

    /// Whether this colour has a dark cut of its own.
    public var adaptsToDarkMode: Bool { dark != nil }

    public func hex(for colorScheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> Hex {
        let standard = colorScheme == .dark ? dark ?? light : light
        guard contrast == .increased else { return standard }
        return (colorScheme == .dark ? darkHighContrast : lightHighContrast) ?? standard
    }

    public func color(for colorScheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> Color {
        hex(for: colorScheme, contrast: contrast).color
    }
}

public extension BrandColor {

    /// The primary action colour
    static let accent = BrandColor(name: "accent", light: 0x3B5BDB, dark: 0x748FFC, lightHighContrast: 0x334EBC, darkHighContrast: 0x7C96FC)

    /// Primary text and iconography
    static let ink = BrandColor(name: "ink", light: 0x121417, dark: 0xF2F4F7)

    /// The page under everything else.
    static let canvas = BrandColor(name: "canvas", light: 0xFFFFFF, dark: 0x0B0D10)

    /// Secondary text, hairlines, and anything that should recede.
    static let muted = BrandColor(name: "muted", light: 0x5B6472, dark: 0x9AA4B2, lightHighContrast: 0x515965)

    // Status

    static let positive = BrandColor(name: "positive", light: 0x1E864A, dark: 0x51CF66, lightHighContrast: 0x176537)
    static let caution  = BrandColor(name: "caution",  light: 0x8A5A00, dark: 0xFFD43B, lightHighContrast: 0x794F00)
    static let critical = BrandColor(name: "critical", light: 0xC0342B, dark: 0xFF8787, lightHighContrast: 0xA32C25)

    /// The logo's own colour
    /// Below 4.5:1 on a light canvas, so not for text unless Increase
    /// Contrast is on.
    static let signature = BrandColor(name: "signature", light: 0xFF6B00, lightHighContrast: 0x943E00, darkHighContrast: 0xFF710A)

    /// Every brand colour, in the order the catalog should show them.
    static let all: [BrandColor] = [
        .accent, .ink, .canvas, .muted, .positive, .caution, .critical, .signature,
    ]
}

/// The brand colours as named swatches. Declare one here for each
/// `BrandColor` above.
public extension Swatch {
    static let accent    = Swatch.brand(.accent)
    static let ink       = Swatch.brand(.ink)
    static let canvas    = Swatch.brand(.canvas)
    static let muted     = Swatch.brand(.muted)
    static let positive  = Swatch.brand(.positive)
    static let caution   = Swatch.brand(.caution)
    static let critical  = Swatch.brand(.critical)
    static let signature = Swatch.brand(.signature)

    /// Every brand swatch, in `BrandColor.all` order.
    static let brandColors: [Swatch] = BrandColor.all.map(Swatch.brand)
}

// MARK: - Previews

#Preview("Brand colours") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            BrandColorChart(scheme: scheme, contrast: .standard)
        }
    }
}

#Preview("Increase Contrast") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            BrandColorChart(scheme: scheme, contrast: .increased)
        }
    }
}

/// Every brand colour as a chip, with its name and the hex it resolves to.
private struct BrandColorChart: View {
    let scheme: ColorScheme
    let contrast: ColorSchemeContrast

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(BrandColor.all, id: \.self) { brand in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(brand.color(for: scheme, contrast: contrast))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(BrandColor.muted.color(for: scheme, contrast: contrast).opacity(0.3))
                        }
                        .frame(width: 44, height: 44)
                    Text(brand.name)
                    Spacer()
                    Text(brand.hex(for: scheme, contrast: contrast).description)
                        .monospaced()
                        .foregroundStyle(BrandColor.muted.color(for: scheme, contrast: contrast))
                }
            }
        }
        .foregroundStyle(BrandColor.ink.color(for: scheme, contrast: contrast))
        .padding()
        .frame(width: 375)
        .background(BrandColor.canvas.color(for: scheme, contrast: contrast))
    }
}
