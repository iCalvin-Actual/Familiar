//
//  Icon.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

public struct Icon: View {
    /// Images bundled in `Resources/Images/Images.xcassets`, drawn as
    /// templates. Add a case per image set, with the raw value matching the
    /// set's name; `IconTests` fails if a case has no image behind it.
    public enum Symbol: String, CaseIterable, Sendable {
        case wordmark

        /// What VoiceOver reads when the call site doesn't say. Every case
        /// needs one, so our own images are never silent.
        public var accessibilityLabel: String {
            switch self {
            case .wordmark: String(localized: "Wordmark", bundle: .familiar, comment: "VoiceOver label for the wordmark image.")
            }
        }
    }

    public enum Source: Hashable, Sendable {
        case system(String)
        case bundle(String, Bundle)
        case symbol(Symbol)

        /// A loose image file dropped into `Resources/Images`, named without
        /// its extension, drawn in its own colours. See `URL.familiarImages`.
        case file(String)

        public static func bundle(_ name: String) -> Source {
            .bundle(name, .main)
        }

        /// A bundled symbol's own description. Files and bundle images are
        /// the call site's to describe.
        public var accessibilityLabel: String? {
            if case .symbol(let symbol) = self { symbol.accessibilityLabel } else { nil }
        }
    }

    public let source: Source

    /// `nil` means "inherit" — the icon takes the type scope it's placed in,
    /// which is what you want for an icon inside a `Label`. Set it only when
    /// the icon stands alone or should deliberately differ from its context.
    public let typography: Typography?

    /// What VoiceOver reads. `nil` keeps an SF Symbol's or bundled symbol's
    /// own description and hides any other source, whose asset name wouldn't
    /// mean anything.
    public let label: String?

    public init(source: Source, size typography: Typography? = nil, label: String? = nil) {
        self.source = source
        self.typography = typography
        self.label = label
    }

    public var body: some View {
        Group {
            if let typography {
                Resolved(source: source).typography(typography)
            } else {
                Resolved(source: source)
            }
        }
        .spoken(spoken)
    }

    /// `nil` when decorative. An empty label keeps an SF Symbol's own description.
    var spoken: Spoken? {
        isDecorative ? nil : Spoken(spokenLabel ?? "", traits: .image)
    }

    var spokenLabel: String? {
        label ?? source.accessibilityLabel
    }

    var isDecorative: Bool {
        guard spokenLabel == nil else { return false }
        if case .system = source { return false }
        return true
    }

    /// Split out so that `@Environment` reads the scope *including* any
    /// typography this icon applied to itself. A view can't observe an
    /// environment value it sets on its own body.
    private struct Resolved: View {
        @Environment(\.typographyPointSize) private var pointSize

        let source: Source

        var body: some View {
            switch source {
            case .system(let name):
                // Deliberately no `.resizable()` and no `.frame()`. An SF
                // Symbol sized by the inherited font scales with Dynamic Type
                // for free and baseline-aligns with adjacent text; a fixed
                // frame throws both away.
                Image(systemName: name)
            case .symbol(let symbol):
                Image(symbol.rawValue, bundle: .familiar)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: pointSize)
                    .modifier(GlyphBaseline())
            case .file(let name):
                // Drop-in artwork keeps its own colours. Single-colour glyphs
                // that should follow the text belong in the catalog.
                if let url = URL.familiarImage(named: name), let image = Image(contentsOf: url) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: pointSize)
                        .modifier(GlyphBaseline())
                }
            case .bundle(let name, let bundle):
                // Bitmap and vector assets have no font metrics, so this is the
                // one place a numeric height is unavoidable — hence the
                // resolved point size in the environment.
                Image(name, bundle: bundle)
                    .resizable()
                    .scaledToFit()
                    .frame(height: pointSize)
                    .modifier(GlyphBaseline())
            }
        }
    }
}

/// Sits an image on the text baseline the way a letter of the same size
/// would, with a fifth of it below like a descender. Without it an image's
/// baseline is its bottom edge, so baseline-aligned rows lift it.
private struct GlyphBaseline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .alignmentGuide(.firstTextBaseline) { $0.height * 0.8 }
            .alignmentGuide(.lastTextBaseline) { $0.height * 0.8 }
    }
}

#Preview("Inherits its scope") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Icon(source: .system("star.fill"))
            Text("title3")
        }
        .typography(.title3)

        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Icon(source: .system("star.fill"))
            Text("body")
        }
        .typography(.body)

        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Icon(source: .system("star.fill"))
            Text("caption")
        }
        .typography(.caption)
    }
    .padding()
}

#Preview("Accessibility labels") {
    VStack(alignment: .leading, spacing: 12) {
        Icon(source: .system("star.fill"))
        Icon(source: .system("star.fill"), label: "Favorite")
        Icon(source: .symbol(.wordmark), label: "Familiar")
    }
    .typography(.title2)
    .padding()
}

#Preview("Sizes") {
    HStack(alignment: .bottom, spacing: 16) {
        Icon(source: .system("bolt.fill"), size: .xSmall)
        Icon(source: .system("bolt.fill"), size: .small)
        Icon(source: .system("bolt.fill"), size: .medium)
        Icon(source: .system("bolt.fill"), size: .large)
        Icon(source: .system("bolt.fill"), size: .xLarge)
        Icon(source: .system("bolt.fill"), size: .xxLarge)
    }
    .padding()
}

#Preview("Sources") {
    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
        GridRow {
            Text(".system")
            Icon(source: .system("star.fill"))
            Icon(source: .system("star.fill")).foregroundStyle(.swatch(.highlight))
        }
        GridRow {
            Text(".symbol")
            Icon(source: .symbol(.wordmark))
            Icon(source: .symbol(.wordmark)).foregroundStyle(.swatch(.highlight))
        }
        GridRow {
            Text(".bundle")
            Icon(source: .bundle(Icon.Symbol.wordmark.rawValue, .familiar))
            Icon(source: .bundle(Icon.Symbol.wordmark.rawValue, .familiar)).foregroundStyle(.swatch(.highlight))
        }
        GridRow {
            Text(".file")
            Icon(source: .file("nextapp"))
            Icon(source: .file("nextapp")).foregroundStyle(.swatch(.highlight))
        }
    }
    .typography(.title3)
    .padding()
}

#Preview("Bundled symbols") {
    VStack(alignment: .leading, spacing: 16) {
        ForEach(Icon.Symbol.allCases, id: \.self) { symbol in
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Icon(source: .symbol(symbol), size: .small)
                    Icon(source: .symbol(symbol), size: .medium)
                    Icon(source: .symbol(symbol), size: .xxLarge)
                }
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Icon(source: .symbol(symbol), size: .xxLarge)
                        .foregroundStyle(.swatch(.highlight))
                    Label(style: .textIcon(symbol.rawValue, .symbol(symbol)))
                }
            }
        }
    }
    .padding()
}

#Preview("Directory icons") {
    VStack(alignment: .leading, spacing: 16) {
        if URL.familiarImages.isEmpty {
            Text("No loose files in Resources/Images yet.")
        }
        ForEach(URL.familiarImages.map(\.familiarImageName), id: \.self) { name in
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Icon(source: .file(name), size: .small)
                Icon(source: .file(name), size: .medium)
                Icon(source: .file(name), size: .xxLarge)
                Label(style: .textIcon(name, .file(name)))
            }
        }
    }
    .padding()
}

#Preview("Swatches") {
    VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 16) {
            Icon(source: .system("heart.fill"))
            Icon(source: .system("heart.fill"))
                .foregroundStyle(.swatch(.system(.red)))
            // Explicit `Hex(…)`: a bare literal here crashes Previews.
            Icon(source: .system("heart.fill"))
                .foregroundStyle(.swatch(.hex(Hex(0x4F46E5))))
            Icon(source: .system("heart.fill"))
                .foregroundStyle(.swatch(.hex(Hex(0x4F46E5).opacity(0.4))))
        }

        HStack(spacing: 16) {
            ForEach(Swatch.brandColors, id: \.self) { swatch in
                Icon(source: .system("circle.fill"))
                    .foregroundStyle(.swatch(swatch))
            }
        }

        HStack(spacing: 16) {
            ForEach(Swatch.catalog, id: \.self) { swatch in
                Icon(source: .system("square.fill"))
                    .foregroundStyle(.swatch(swatch))
            }
        }
    }
    .typography(.title2)
    .padding()
}

#Preview("Tint") {
    HStack(spacing: 16) {
        Icon(source: .system("bolt.fill")).foregroundStyle(.tint)
        Icon(source: .system("bolt.fill")).foregroundStyle(.tint.secondary)
        Icon(source: .system("bolt.fill")).foregroundStyle(.tint.tertiary)
    }
    .typography(.title2)
    .tint(SwatchStyle.swatch(.accent))
    .padding()
}

#Preview("Rendering modes") {
    let accent = SwatchStyle.swatch(.accent)
    let signature = SwatchStyle.swatch(.signature)

    HStack(spacing: 20) {
        Icon(source: .system("person.crop.circle.badge.checkmark"))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(accent)
        Icon(source: .system("person.crop.circle.badge.checkmark"))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(accent)
        Icon(source: .system("person.crop.circle.badge.checkmark"))
            .symbolRenderingMode(.palette)
            .foregroundStyle(signature, accent)
        Icon(source: .system("person.crop.circle.badge.checkmark"))
            .symbolRenderingMode(.multicolor)
    }
    .typography(.xxLarge)
    .padding()
}
