//
//  FlowLayout.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// Lays views out left to right, wrapping onto a new line when the next one won't fit.
public struct FlowLayout: Layout {
    public var spacing: CGFloat
    public var lineSpacing: CGFloat

    public init(spacing: CGFloat = Spacing.small, lineSpacing: CGFloat = Spacing.small) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let sizes = sizes(of: subviews, maxWidth: maxWidth)
        let lines = Self.lines(for: sizes.map(\.width), maxWidth: maxWidth, spacing: spacing)

        var width: CGFloat = 0
        var height: CGFloat = 0
        for line in lines {
            let lineWidth = line.reduce(0) { $0 + sizes[$1].width } + spacing * CGFloat(line.count - 1)
            width = max(width, lineWidth)
            height += line.map { sizes[$0].height }.max() ?? 0
        }
        height += lineSpacing * CGFloat(max(lines.count - 1, 0))

        return CGSize(width: width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = sizes(of: subviews, maxWidth: bounds.width)
        var y = bounds.minY

        for line in Self.lines(for: sizes.map(\.width), maxWidth: bounds.width, spacing: spacing) {
            let lineHeight = line.map { sizes[$0].height }.max() ?? 0
            var x = bounds.minX
            for index in line {
                subviews[index].place(
                    at: CGPoint(x: x, y: y + lineHeight / 2),
                    anchor: .leading,
                    proposal: ProposedViewSize(sizes[index])
                )
                x += sizes[index].width + spacing
            }
            y += lineHeight + lineSpacing
        }
    }

    /// A view wider than a whole line is squeezed to fit it.
    private func sizes(of subviews: Subviews, maxWidth: CGFloat) -> [CGSize] {
        subviews.map { subview in
            let ideal = subview.sizeThatFits(.unspecified)
            guard ideal.width > maxWidth else { return ideal }
            return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
        }
    }

    static func lines(for widths: [CGFloat], maxWidth: CGFloat, spacing: CGFloat) -> [[Int]] {
        var lines: [[Int]] = []
        var lineWidth: CGFloat = 0

        for (index, width) in widths.enumerated() {
            if let last = lines.indices.last, lineWidth + spacing + width <= maxWidth {
                lines[last].append(index)
                lineWidth += spacing + width
            } else {
                lines.append([index])
                lineWidth = width
            }
        }
        return lines
    }
}

// MARK: - Previews

#Preview("Wrapping") {
    FlowLayout {
        ForEach(["Coffee", "Tea", "Juice", "Smoothies", "Cocktails", "Mocktails", "Beer", "Wine"], id: \.self) {
            Chip($0)
        }
    }
    .frame(width: 240, alignment: .leading)
    .padding(24)
    .backdrop()
}

#Preview("Oversized") {
    FlowLayout {
        Chip("Short")
        Chip("A chip far too long to fit on any single line of this layout")
        Chip("Short")
    }
    .frame(width: 240, alignment: .leading)
    .padding(24)
    .backdrop()
}
