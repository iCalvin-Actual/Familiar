//
//  Typography.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import Foundation
import SwiftUI

/// A single type token: a point size, a weight, a face, and a rule for how it
/// responds to Dynamic Type
public struct Typography: Equatable, Hashable, Sendable {

    /// Point size at `DynamicTypeSize.large` (the system default).
    public var size: CGFloat

    public var weight: Font.Weight

    /// The text style whose Dynamic Type curve this token follows. 
    public var relativeTo: Font.TextStyle?

    public var face: Face

    public enum Face: Equatable, Hashable, Sendable {
        case system(Font.Design)

        /// A specific family, falling back to the system font when it isn't
        /// available.
        case family(FontFamily)

        /// Whatever `\.displayFamily` holds, or the system font when nothing
        /// has set one. Brand faces arrive through the environment.
        case display

        public static var system: Face { .system(.default) }
        public static var monospaced: Face { .system(.monospaced) }
        public static var rounded: Face { .system(.rounded) }
        public static var serif: Face { .system(.serif) }
    }

    public init(
        size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo: Font.TextStyle?,
        face: Face = .system
    ) {
        self.size = size
        self.weight = weight
        self.relativeTo = relativeTo
        self.face = face
    }

    /// Derive a variant without restating the whole token.
    public func with(
        size: CGFloat? = nil,
        weight: Font.Weight? = nil,
        relativeTo: Font.TextStyle?? = nil,
        face: Face? = nil
    ) -> Typography {
        Typography(
            size: size ?? self.size,
            weight: weight ?? self.weight,
            relativeTo: relativeTo ?? self.relativeTo,
            face: face ?? self.face
        )
    }
}

// MARK: - Tokens

public extension Typography {

    static let largeTitle  = Typography(size: 34, weight: .bold,     relativeTo: .largeTitle)
    static let title       = Typography(size: 28, weight: .bold,     relativeTo: .title)
    static let title2      = Typography(size: 22, weight: .bold,     relativeTo: .title2)
    static let title3      = Typography(size: 20, weight: .semibold, relativeTo: .title3)

    static let headline    = Typography(size: 17, weight: .semibold, relativeTo: .headline)
    static let subheadline = Typography(size: 15, weight: .regular,  relativeTo: .subheadline)

    static let body        = Typography(size: 17, weight: .regular,  relativeTo: .body)
    static let body2       = Typography(size: 15, weight: .regular,  relativeTo: .body)
    static let body3       = Typography(size: 13, weight: .regular,  relativeTo: .body)

    static let callout     = Typography(size: 16, weight: .regular,  relativeTo: .callout)
    static let footnote    = Typography(size: 13, weight: .regular,  relativeTo: .footnote)
    static let caption     = Typography(size: 12, weight: .regular,  relativeTo: .caption)
    static let caption2    = Typography(size: 11, weight: .regular,  relativeTo: .caption2)

    static let cta         = Typography(size: 17, weight: .semibold, relativeTo: .headline)

    // T-shirt aliases onto the same ramp.

    static let xSmall  = caption2
    static let small   = body3
    static let medium  = body
    static let large   = title3
    static let xLarge  = title2
    static let xxLarge = title

    /// An arbitrary point size. Fixed unless you pass a text style to scale with.
    static func custom(
        _ size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo textStyle: Font.TextStyle? = nil,
        face: Face = .system
    ) -> Typography {
        Typography(size: size, weight: weight, relativeTo: textStyle, face: face)
    }

    // Monospaced

    static let code      = Typography(size: 13, relativeTo: .body, face: .monospaced)
    static let codeSmall = Typography(size: 11, relativeTo: .caption, face: .monospaced)

    /// A small monospaced marker for column headers, spec strings, annotations.
    static let annotation = Typography(size: 11, weight: .semibold, relativeTo: .caption2, face: .monospaced)

    /// Fixed `annotation`, for chrome that labels something being measured.
    static let annotationFixed = Typography(size: 11, weight: .semibold, relativeTo: nil, face: .monospaced)

    // Display — for a hero line or a callout, never body text.

    static let displayLarge = Typography(size: 34, weight: .bold, relativeTo: .largeTitle, face: .display)
    static let display      = Typography(size: 28, weight: .bold, relativeTo: .title, face: .display)
    static let displaySmall = Typography(size: 22, weight: .bold, relativeTo: .title2, face: .display)
}

// MARK: - Emphasis

public extension Typography {
    enum Emphasis: Equatable, Hashable, Sendable {
        case primary
        /// The brand's muted swatch, for supporting text.
        case secondary
        case tertiary
        /// The environment's `accentSwatch`, the brand accent by default.
        case accent

        func style(accent: Swatch) -> AnyShapeStyle {
            switch self {
            case .primary:   AnyShapeStyle(.primary)
            case .secondary: AnyShapeStyle(.swatch(.muted))
            case .tertiary:  AnyShapeStyle(.tertiary)
            case .accent:    AnyShapeStyle(.swatch(accent))
            }
        }
    }
}

// MARK: - Resolution

extension Typography {

    /// `ScaledMetric` needs a concrete style even for fixed tokens, which then
    /// ignore the result.
    var metricTextStyle: Font.TextStyle { relativeTo ?? .body }

    /// - Parameter scaled: the value produced by `ScaledMetric`.
    func resolvedSize(scaled: CGFloat) -> CGFloat {
        relativeTo == nil ? size : scaled
    }

    /// The family this token draws from, or `nil` for the system font.
    func family(display: FontFamily?) -> FontFamily? {
        switch face {
        case .system:              nil
        case .family(let family):  family
        case .display:             display
        }
    }

    /// Builds the font at an *already-scaled* point size.
    func font(at pointSize: CGFloat, display: FontFamily?, legibilityWeight: LegibilityWeight? = nil) -> Font {
        if case .system(let design) = face {
            return .system(size: pointSize, weight: weight, design: design)
        }
        // Bold Text reaches the system font on its own, but not custom families.
        let weight = legibilityWeight == .bold ? weight.bolder : weight
        return family(display: display)?.font(size: pointSize, weight: weight)
            ?? .system(size: pointSize, weight: weight)
    }
}

extension Font.Weight {
    var bolder: Font.Weight {
        switch self {
        case .ultraLight:           .light
        case .thin:                 .regular
        case .light:                .medium
        case .medium, .semibold:    .bold
        case .bold:                 .heavy
        case .heavy, .black:        .black
        default:                    .semibold
        }
    }
}

private struct TypographyModifier: ViewModifier {
    @ScaledMetric private var scaled: CGFloat
    @Environment(\.displayFamily) private var displayFamily
    @Environment(\.legibilityWeight) private var legibilityWeight
    private let typography: Typography
    @Environment(\.accentSwatch) private var accentSwatch
    private let emphasis: Typography.Emphasis?

    init(_ typography: Typography, emphasis: Typography.Emphasis?) {
        self.typography = typography
        self.emphasis = emphasis
        _scaled = ScaledMetric(wrappedValue: typography.size, relativeTo: typography.metricTextStyle)
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        let pointSize = typography.resolvedSize(scaled: scaled)
        let styled = content
            .font(typography.font(at: pointSize, display: displayFamily, legibilityWeight: legibilityWeight))
            .environment(\.typographyPointSize, pointSize)

        // No emphasis leaves the inherited foreground alone.
        if let emphasis {
            styled.foregroundStyle(emphasis.style(accent: accentSwatch))
        } else {
            styled
        }
    }
}

public extension View {
    /// Applies a type token: sets the font, optionally the foreground role,
    /// and publishes the resolved point size for anything beneath it.
    func typography(_ typography: Typography, emphasis: Typography.Emphasis? = nil) -> some View {
        modifier(TypographyModifier(typography, emphasis: emphasis))
    }
}
