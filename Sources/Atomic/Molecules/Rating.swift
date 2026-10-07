//
//  Rating.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

public extension FeatureFlag {
    /// Ratings with no style of their own draw every star instead of one.
    static let expandedRatings: FeatureFlag = "expandedRatings"
}

public struct Rating: View {
    @Environment(\.featureGate) private var featureGate

    public enum Style: Hashable, Sendable {
        /// One star and the value: "★ 4.9".
        case compact
        /// A star per point of the scale, filled to the nearest half.
        case regular
    }

    enum Star: Hashable {
        case full, half, empty

        var systemName: String {
            switch self {
            case .full:     "star.fill"
            case .half:     "star.leadinghalf.filled"
            case .empty:    "star"
            }
        }
    }

    public let value: Double
    public let maximum: Int
    /// `nil` lets ``FeatureFlag/expandedRatings`` choose.
    public let style: Style?
    public let swatch: Swatch
    public let typography: Typography
    private let format: (Double) -> String

    public init<F: FormatStyle>(
        _ value: Double,
        outOf maximum: Int = 5,
        style: Style? = nil,
        swatch: Swatch = .caution,
        size typography: Typography = .small,
        format: F = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1))
    ) where F.FormatInput == Double, F.FormatOutput == String {
        self.value = value
        self.maximum = maximum
        self.style = style
        self.swatch = swatch
        self.typography = typography
        self.format = { format.format($0) }
    }

    public init(
        _ value: Double,
        outOf maximum: Int = 5,
        style: Style? = nil,
        swatch: Swatch = .caution,
        size typography: Typography = .small,
        formatter: NumberFormatter
    ) {
        self.value = value
        self.maximum = maximum
        self.style = style
        self.swatch = swatch
        self.typography = typography
        self.format = { formatter.string(from: $0 as NSNumber) ?? "" }
    }

    var formattedValue: String {
        format(value)
    }

    // icc-spokenvalue

    var stars: [Star] {
        Self.stars(for: value, outOf: maximum)
    }

    static func stars(for value: Double, outOf maximum: Int) -> [Star] {
        let halves = Int((min(max(value, 0), Double(maximum)) * 2).rounded())
        return (0..<max(maximum, 0)).map { index in
            switch halves - index * 2 {
            case 2...:  .full
            case 1:     .half
            default:    .empty
            }
        }
    }

    public var body: some View {
        Group {
            switch style ?? (featureGate.isEnabled(.expandedRatings) ? .regular : .compact) {
            case .compact:
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xSmall) {
                    Icon(source: .system(Star.full.systemName))
                        .foregroundStyle(.swatch(swatch))
                    Label(text: formattedValue, size: typography)
                }
            case .regular:
                HStack(spacing: Spacing.xxSmall) {
                    ForEach(Array(stars.enumerated()), id: \.offset) { _, star in
                        Icon(source: .system(star.systemName))
                    }
                }
                .foregroundStyle(.swatch(swatch))
            }
        }
        .typography(typography)
    }
}

// MARK: - Previews

#Preview("Styles") {
    VStack(alignment: .leading, spacing: 16) {
        ForEach([0, 2.2, 3.5, 4.74, 5], id: \.self) { value in
            HStack(spacing: 24) {
                Rating(value)
                Rating(value, style: .regular)
            }
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Gated") {
    VStack(alignment: .leading, spacing: 12) {
        Rating(4.5)
        Rating(4.5)
            .featureGate(StaticFeatureGate(enabled: [.expandedRatings]))
    }
    .padding(24)
    .backdrop()
}

#Preview("Formats") {
    VStack(alignment: .leading, spacing: 12) {
        Rating(4.74)
        Rating(4.74, format: .number.precision(.fractionLength(0)))
        Rating(4.74, format: .number.precision(.fractionLength(2)))
        Rating(4.74, formatter: {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 1
            formatter.positiveSuffix = " / 5"
            return formatter
        }())
    }
    .padding(24)
    .backdrop()
}

#Preview("Scales and sizes") {
    VStack(alignment: .leading, spacing: 12) {
        Rating(7.5, outOf: 10, style: .regular)
        Rating(2, outOf: 3, style: .regular)
        ForEach([Typography.caption, .small, .body, .title3], id: \.self) { size in
            HStack(spacing: 16) {
                Rating(3.5, size: size)
                Rating(3.5, style: .regular, size: size)
            }
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Swatches") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach([Swatch.caution, .accent, .signature, .positive], id: \.self) { swatch in
            HStack(spacing: 16) {
                Rating(4.5, swatch: swatch)
                Rating(4.5, style: .regular, swatch: swatch)
            }
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Accessibility XL") {
    VStack(alignment: .leading, spacing: 12) {
        Rating(4.5)
        Rating(4.5, style: .regular)
    }
    .padding(24)
    .backdrop()
    .dynamicTypeSize(.accessibility3)
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            HStack(spacing: 24) {
                Rating(4.5)
                Rating(4.5, style: .regular)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .backdrop()
            .environment(\.colorScheme, scheme)
        }
    }
}
