//
//  SectionHeader.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// Heads a row of content: a title, an optional subtitle, and an optional
/// action such as "See all".
public struct SectionHeader: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public let title: String
    public let subtitle: String?
    public let action: Button?

    public init(_ title: String, subtitle: String? = nil, action: Button? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        // Accessibility sizes leave no room beside the title, so the action drops below.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.small))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: Spacing.medium))

        layout {
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Label(text: title, size: .title3, lineLimit: 2)
                    .spokenTraits(.header)
                if let subtitle {
                    Label(text: subtitle, size: .body2, emphasis: .secondary, lineLimit: 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            action
        }
    }
}

// MARK: - Previews

#Preview("Variants") {
    VStack(alignment: .leading, spacing: 24) {
        SectionHeader("Drinks")
        SectionHeader("Drinks", subtitle: "Something for every hour")
        SectionHeader("Drinks", subtitle: "Something for every hour", action: Button("See all", prominence: .plain) {})
        SectionHeader("Drinks", action: Button("See all", systemIcon: "chevron.right", prominence: .tinted, size: .small) {})
    }
    .padding(24)
    .backdrop()
}

#Preview("Long title") {
    SectionHeader(
        "Hand-picked drinks from our favourite cafés",
        subtitle: "Updated every morning from what our baristas are pouring",
        action: Button("See all", prominence: .plain) {}
    )
    .padding(24)
    .backdrop()
}

#Preview("Accessibility XL") {
    SectionHeader("Drinks", subtitle: "Something for every hour", action: Button("See all", prominence: .plain) {})
        .padding(24)
        .backdrop()
        .dynamicTypeSize(.accessibility3)
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            SectionHeader("Drinks", subtitle: "Something for every hour", action: Button("See all", prominence: .plain) {})
                .padding(24)
                .backdrop()
                .environment(\.colorScheme, scheme)
        }
    }
}
