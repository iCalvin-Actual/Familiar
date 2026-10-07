//
//  Label.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

public struct Label: View {

    public enum Style: Hashable {
        case text(String)
        /// With no text on screen, `label` is what VoiceOver reads.
        case icon(Icon.Source, label: String? = nil)
        case textIcon(String, Icon.Source)

        @MainActor
        public static func systemIcon(_ name: String, label: String? = nil) -> Style {
            .icon(.system(name), label: label)
        }

        @MainActor
        public static func textSystemIcon(_ text: String, _ name: String) -> Style {
            .textIcon(text, .system(name))
        }

        /// What VoiceOver reads, when there are words to read. An SF Symbol
        /// without a label describes itself on screen but has no words here.
        var spokenText: String? {
            switch self {
            case .text(let text), .textIcon(let text, _):  text
            case .icon(let source, let label):             label ?? source.accessibilityLabel
            }
        }
    }

    public let style: Style
    public let typography: Typography
    /// `nil` keeps the foreground it inherits.
    public let emphasis: Typography.Emphasis?
    /// `nil` for no limit.
    public let lineLimit: Int?

    public init(style: Style, size typography: Typography = .body, emphasis: Typography.Emphasis? = nil, lineLimit: Int? = 1) {
        self.style = style
        self.typography = typography
        self.emphasis = emphasis
        self.lineLimit = lineLimit
    }

    public init(text: String, size typography: Typography = .body, emphasis: Typography.Emphasis? = nil, lineLimit: Int? = 1) {
        self.init(style: .text(text), size: typography, emphasis: emphasis, lineLimit: lineLimit)
    }

    public init(icon: Icon.Source, label: String? = nil, size typography: Typography = .body) {
        self.init(style: .icon(icon, label: label), size: typography)
    }

    public init(systemIcon: String, label: String? = nil, size typography: Typography = .body) {
        self.init(style: .systemIcon(systemIcon, label: label), size: typography)
    }

    public init(text: String, systemIcon: String, size typography: Typography = .body, emphasis: Typography.Emphasis? = nil, lineLimit: Int? = 1) {
        self.init(style: .textSystemIcon(text, systemIcon), size: typography, emphasis: emphasis, lineLimit: lineLimit)
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Truncating at accessibility sizes would hide most of the text.
    static func lineLimit(_ limit: Int?, at dynamicTypeSize: DynamicTypeSize) -> Int? {
        dynamicTypeSize.isAccessibilitySize ? nil : limit
    }

    public var body: some View {
        switch style {
        case .text(let text), .textIcon(let text, _):
            IconAndTitle(icon: labelIcon, title: labelText)
                .typography(typography, emphasis: emphasis)
                // One element that reads its words; the icon beside them is decoration.
                .accessibilityElement(children: .combine)
                .spoken(Spoken(text))
        case .icon:
            // The icon speaks for itself.
            labelIcon
                .typography(typography, emphasis: emphasis)
        }
    }

    /// Our own layout rather than SwiftUI.Label, which takes on whatever
    /// style its context imposes. Inside a List that style squeezes icons into
    /// a fixed slot and misreports the title's width, so a button sized to it
    /// clips its own text.
    private struct IconAndTitle<IconView: View, Title: View>: View {
        @Environment(\.typographyPointSize) private var pointSize

        let icon: IconView
        let title: Title

        var body: some View {
            HStack(spacing: pointSize * 0.35) {
                icon
                title
            }
        }
    }

    @ViewBuilder
    private var labelText: some View {
        switch style {
        case .text(let text), .textIcon(let text, _):
            Text(text)
                .lineLimit(Self.lineLimit(lineLimit, at: dynamicTypeSize))
        case .icon:                     EmptyView()
        }
    }

    @ViewBuilder
    private var labelIcon: some View {
        switch style {
        case .icon(let icon, let label):
            Icon(source: icon, label: label)
        case .textIcon(_, let icon):
            Icon(source: icon)
        case .text:                     EmptyView()
        }
    }
}

#Preview("Styles") {
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "Text only")
        Label(systemIcon: "square.and.arrow.up")
        Label(text: "Text and icon", systemIcon: "square.and.arrow.up")
    }
    .padding()
}

#Preview("Sizes") {
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "body")
        Label(text: "title3", systemIcon: "star.fill", size: .title3)
        Label(text: "body", systemIcon: "star.fill", size: .body)
        Label(text: "body2", systemIcon: "star.fill", size: .body2)
        Label(text: "caption", systemIcon: "star.fill", size: .caption)
        Label(text: "custom(24) — fixed", systemIcon: "lock.fill", size: .custom(24))
    }
    .padding()
}

#Preview("Line limit") {
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "A long label that stays on one line by default", systemIcon: "text.alignleft")
        Label(text: "A long label allowed two lines before it truncates", systemIcon: "text.alignleft", lineLimit: 2)
        Label(text: "A long label with no limit wraps as far as it needs to", systemIcon: "text.alignleft", lineLimit: nil)
    }
    .frame(width: 240, alignment: .leading)
    .padding()
}

#Preview("Accessibility sizes") {
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "One line by default, wrapped at accessibility sizes", systemIcon: "textformat.size")
        Label(systemIcon: "trash", label: "Delete")
        Label(icon: .symbol(.wordmark), label: "Familiar")
    }
    .frame(width: 343, alignment: .leading)
    .padding()
    .dynamicTypeSize(.accessibility2)
}

#Preview("Custom icons") {
    VStack(alignment: .leading, spacing: 12) {
        Label(style: .textIcon("Catalog symbol", .symbol(.wordmark)))
        Label(style: .textIcon("Catalog symbol, title3", .symbol(.wordmark)), size: .title3)
        Label(icon: .symbol(.wordmark), size: .title2)
        Label(style: .textIcon("Catalog symbol, highlight", .symbol(.wordmark)))
            .foregroundStyle(.swatch(.highlight))
        ForEach(URL.familiarImages.map(\.familiarImageName), id: \.self) { name in
            Label(style: .textIcon("File · \(name)", .file(name)))
        }
    }
    .padding()
}

#Preview("Emphasis") {
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "Inherited", systemIcon: "star.fill")
        Label(text: "Secondary", systemIcon: "star.fill").foregroundStyle(.secondary)
        Label(text: "Tertiary", systemIcon: "star.fill").foregroundStyle(.tertiary)
        Label(text: "Brand accent", systemIcon: "star.fill").foregroundStyle(.swatch(.accent))
        Label(text: "Tint", systemIcon: "star.fill").foregroundStyle(.tint)
    }
    .tint(SwatchStyle.swatch(.signature))
    .padding()
}

#Preview("Swatches") {
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "System · red", systemIcon: "circle.fill")
            .foregroundStyle(.swatch(.system(.red)))
        Label(text: "Hex · 0x4F46E5", systemIcon: "circle.fill")
            .foregroundStyle(.swatch(.hex(Hex(0x4F46E5))))
        Label(text: "Hex · 50% opacity", systemIcon: "circle.fill")
            .foregroundStyle(.swatch(.hex(Hex(0x4F46E5).opacity(0.5))))

        Divider()

        // Named swatches adapt on their own, whichever way they're defined.
        ForEach(Swatch.brandColors, id: \.self) { swatch in
            Label(text: "Brand · \(swatch.name ?? "")", systemIcon: "circle.fill")
                .foregroundStyle(.swatch(swatch))
        }

        Divider()

        // The catalog adds Increase Contrast and Display P3 (`highlight`).
        ForEach(Swatch.catalog, id: \.self) { swatch in
            Label(text: "Catalog · \(swatch.name ?? "")", systemIcon: "square.fill")
                .foregroundStyle(.swatch(swatch))
        }
    }
    .padding()
}

#Preview("Light and dark") {
    // Every named swatch, brand or catalog, reads the scheme from the
    // environment; each panel only has to set it.
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Swatch.brandColors, id: \.self) { swatch in
                    Label(text: swatch.name ?? "", systemIcon: "circle.fill", size: .body2)
                        .foregroundStyle(.swatch(swatch))
                }
                Divider()
                ForEach(Swatch.catalog, id: \.self) { swatch in
                    Label(text: swatch.name ?? "", systemIcon: "square.fill", size: .body2)
                        .foregroundStyle(.swatch(swatch))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.swatch(.canvas))
            .environment(\.colorScheme, scheme)
        }
    }
}

#Preview("Faces") {
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "System", systemIcon: "textformat", size: .title3)
        Label(text: "Rounded", systemIcon: "textformat", size: .title3.with(face: .rounded))
        Label(text: "Monospaced", systemIcon: "chevron.left.forwardslash.chevron.right", size: .title3.with(face: .monospaced))
        Label(text: "Sharpie", systemIcon: "pencil.tip", size: .title3.with(face: .family(.sharpie)))
        Label(text: "Array", systemIcon: "square.grid.3x3", size: .title3.with(face: .family(.array)))
        Label(text: "Array Wide", systemIcon: "rectangle.grid.3x2", size: .title3.with(face: .family(.arrayWide)))
    }
    .padding()
}

#Preview("Display family") {
    // The same `.display` token, reskinned by the environment.
    VStack(alignment: .leading, spacing: 12) {
        Label(text: "Unset — system", systemIcon: "sparkles", size: .display)
        Label(text: "Sharpie", systemIcon: "sparkles", size: .display)
            .displayFamily(.sharpie)
        Label(text: "Array Wide", systemIcon: "sparkles", size: .display)
            .displayFamily(.arrayWide)
    }
    .padding()
}

#Preview("Catalog card") {
    // Catalog colours: surface, hairline, and a Display P3 highlight.
    VStack(alignment: .leading, spacing: 8) {
        Label(text: "Surface card", systemIcon: "rectangle.stack", size: .headline)
        Label(text: "Hairline border, highlight badge", size: .body2)
            .foregroundStyle(.secondary)
        Label(text: "NEW", systemIcon: "sparkle", size: .annotation)
            .foregroundStyle(.swatch(.highlight))
    }
    .padding(16)
    .background(.swatch(.surface), in: .rect(cornerRadius: 12))
    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.swatch(.hairline)))
    .padding(24)
}

#Preview("Composed") {
    VStack(alignment: .leading, spacing: 8) {
        Label(text: "NEW", size: .annotation)
            .foregroundStyle(.swatch(.signature))
        Label(text: "Familiar", size: .displayLarge)
            .foregroundStyle(.swatch(.ink))
        Label(text: "Shared UI for the Workshop", systemIcon: "hammer.fill", size: .body2)
            .foregroundStyle(.swatch(.muted))
        Label(text: "All checks passed", systemIcon: "checkmark.circle.fill", size: .caption)
            .foregroundStyle(.swatch(.positive))
    }
    .padding(24)
    .background(.swatch(.canvas))
    .displayFamily(.display)
}
