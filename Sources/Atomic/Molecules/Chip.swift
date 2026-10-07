//
//  Chip.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// A compact capsule token: a filter, a tag, a count. Unlike `Button` it may
/// not be a control at all, and it carries state.
public struct Chip: View {

    public enum Behavior {
        /// Not focusable; VoiceOver reads it as text, not as a button.
        case display
        case button(() -> Void)
        case menu(MenuContent)

        public var isInteractive: Bool {
            if case .display = self { false } else { true }
        }

        public static func menu<Content: View>(
            @ViewBuilder _ content: @escaping @MainActor () -> Content
        ) -> Behavior {
            .menu(MenuContent(content))
        }
    }

    /// Type-erased so `Chip` isn't generic and a row can mix behaviours.
    public struct MenuContent {
        fileprivate let content: @MainActor () -> AnyView

        public init<Content: View>(
            @ViewBuilder _ content: @escaping @MainActor () -> Content
        ) {
            self.content = { AnyView(content()) }
        }
    }

    public let label: Label.Style
    public let badge: Label.Style?
    /// Fills the glass with the ambient accent: the applied filter, the chosen tag.
    public let isSelected: Bool
    public let typography: Typography
    public let behavior: Behavior

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.analytics) private var analytics
    @Environment(\.tapEvent) private var tapEvent

    public init(
        _ label: Label.Style,
        badge: Label.Style? = nil,
        isSelected: Bool = false,
        size typography: Typography = .small,
        behavior: Behavior = .display
    ) {
        self.label = label
        self.badge = badge
        self.isSelected = isSelected
        self.typography = typography
        self.behavior = behavior
    }

    public init(
        _ text: String,
        badge: String? = nil,
        isSelected: Bool = false,
        size typography: Typography = .small,
        behavior: Behavior = .display
    ) {
        self.init(.text(text), badge: badge.map { .text($0) }, isSelected: isSelected, size: typography, behavior: behavior)
    }

    public init(
        _ text: String,
        systemIcon: String,
        badge: String? = nil,
        isSelected: Bool = false,
        size typography: Typography = .small,
        behavior: Behavior = .display
    ) {
        self.init(.textSystemIcon(text, systemIcon), badge: badge.map { .text($0) }, isSelected: isSelected, size: typography, behavior: behavior)
    }

    public var body: some View {
        Group {
            switch behavior {
            case .display:
                content
            case .button(let action):
                SwiftUI.Button {
                    if let tapEvent { analytics.track(tapEvent) }
                    action()
                } label: { content }
                    .buttonStyle(.plain)
            case .menu(let menu):
                SwiftUI.Menu { menu.content() } label: { content }
                    .buttonStyle(.plain)
                    .menuStyle(.button)
            }
        }
        .modifier(Style(isSelected: isSelected, size: typography, isInteractive: behavior.isInteractive))
        .spoken(spoken)
    }

    private var content: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Label(style: label, size: typography)
            if let badge {
                Label(style: badge, size: badgeTypography)
                    .modifier(BadgeChrome())
                    // So the chrome scales with the badge, not the chip.
                    .typography(badgeTypography)
            }
        }
        // One element, read as "Unread, 3", even when the chip isn't a button.
        .accessibilityElement(children: .combine)
    }

    /// Derived from the label so the two keep their ratio under Dynamic Type.
    var badgeTypography: Typography {
        typography.with(size: typography.size * 0.8)
    }

    /// The words on the chip, without its badge: what a `ChipRow` names it
    /// by. `nil` when an icon has nothing to say.
    var spokenTitle: String? {
        label.spokenText
    }

    /// The chip as it reads on its own, badge included: "Unread, 3".
    var spokenText: String? {
        guard let title = spokenTitle else { return nil }
        guard let badge = badge?.spokenText else { return title }
        return "\(title), \(badge)"
    }

    /// Buttons and menus carry the button trait already; it's here so the
    /// report says so too.
    var spoken: Spoken {
        var traits: Spoken.Traits = isSelected ? .selected : []
        if behavior.isInteractive { traits.insert(.button) }
        if !isEnabled { traits.insert(.dimmed) }
        return Spoken(spokenText ?? "", traits: traits)
    }
}

// MARK: - Style

public extension Chip {

    /// A modifier rather than a `ButtonStyle`: display chips wear it too.
    struct Style: ViewModifier {
        public let isSelected: Bool
        public let typography: Typography
        public let isInteractive: Bool

        public init(isSelected: Bool = false, size typography: Typography = .small, isInteractive: Bool = true) {
            self.isSelected = isSelected
            self.typography = typography
            self.isInteractive = isInteractive
        }

        public func body(content: Content) -> some View {
            // Inside the type scope, so Chrome can read the resolved point size.
            Chrome(content: content, isSelected: isSelected, isInteractive: isInteractive)
                .typography(typography)
        }

        /// Selected fills the glass with the accent; hover hints at it.
        static func tint(isSelected: Bool, isHovered: Bool, accent: Swatch) -> (swatch: Swatch, opacity: Double)? {
            if isSelected { return (accent, 1) }
            return isHovered ? (accent, 0.3) : nil
        }
    }
}

private struct Chrome<Content: View>: View {
    @Environment(\.typographyPointSize) private var pointSize
    @Environment(\.accentSwatch) private var accent
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.forcedInteraction) private var forcedInteraction
    @Environment(\.isFocused) private var isFocused
    @State private var isHovering = false

    let content: Content
    let isSelected: Bool
    let isInteractive: Bool

    var body: some View {
        let state = Interaction.resolve(forced: forcedInteraction, live: .init(isHovered: isHovering, isFocused: isFocused))
        let isLive = isInteractive && isEnabled
        let tint = Chip.Style.tint(isSelected: isSelected, isHovered: state.isHovered && isLive, accent: accent)

        // Padding inside the glass so the whole capsule is tappable.
        content
            .padding(.horizontal, pointSize * 0.6)
            .padding(.vertical, pointSize * 0.3)
            .contentShape(.capsule)
            .familiarGlass(tint: tint.map { $0.swatch.color(in: colorScheme, contrast: contrast).opacity($0.opacity) }, interactive: isInteractive, in: .capsule)
            .focusRing(.capsule, isFocused: state.isFocused && isLive, swatch: accent)
            .opacity(isEnabled ? 1 : 0.4)
            .minimumTapTarget(isInteractive)
            .ownsInteraction($isHovering)
            .animation(.snappy(duration: 0.15), value: state.isHovered)
    }
}

/// A single character reads as a circle: minimum width is its own height.
private struct BadgeChrome: ViewModifier {
    @Environment(\.typographyPointSize) private var pointSize
    @State private var height: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .foregroundStyle(.swatch(.canvas))
            .padding(pointSize * 0.15)
            .frame(minWidth: height)
            .background(.swatch(.ink), in: .capsule)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height = $0 }
            // Here rather than as stack spacing, which sits outside the type scope.
            .padding(.leading, pointSize * 0.55)
    }
}

// MARK: - Previews

#Preview("Behaviors") {
    VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 8) {
            Chip("Display")
            Chip("Button", behavior: .button {})
            Chip(
                "Menu",
                systemIcon: "line.3.horizontal.decrease",
                behavior: .menu {
                    SwiftUI.Button("Newest first") {}
                    SwiftUI.Button("Oldest first") {}
                    Divider()
                    SwiftUI.Button("Reset", role: .destructive) {}
                }
            )
        }
        Chip(
            "Sort: Newest",
            systemIcon: "arrow.up.arrow.down",
            isSelected: true,
            behavior: .menu {
                Picker("Sort", selection: .constant(0)) {
                    Text("Newest").tag(0)
                    Text("Oldest").tag(1)
                }
            }
        )
        Chip("Disabled", behavior: .button {})
            .disabled(true)
    }
    .padding(24)
    .backdrop()
}

#Preview("Interaction") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            Chip("Rest", behavior: .button {})
            Chip("Hover", behavior: .button {})
                .forcedInteraction(.hovered)
            Chip("Focus", behavior: .button {})
                .forcedInteraction(.focused)
            Chip("Selected", isSelected: true, behavior: .button {})
                .forcedInteraction(.focused)
        }
        Chip("Display chips don't hover")
            .forcedInteraction(.hovered)
    }
    .padding(24)
    .backdrop()
}

#Preview("Sizes") {
    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
        ForEach([Typography.xSmall, .small, .medium, .large], id: \.self) { size in
            GridRow {
                Chip("Plain", size: size)
                Chip("Selected", isSelected: true, size: size)
                Chip("Badged", badge: "3", size: size)
            }
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Accessibility XL") {
    HStack(spacing: 8) {
        Chip("small — scales", badge: "3")
        Chip("Selected", isSelected: true)
    }
    .padding(24)
    .backdrop()
    .dynamicTypeSize(.accessibility3)
}

#Preview("Badges") {
    VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 8) {
            Chip("Plain")
            Chip("Badged", badge: "3")
        }
        HStack(spacing: 8) {
            Chip("Wide badge", badge: "sold out")
            Chip("Selected", badge: "9", isSelected: true, behavior: .button {})
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Label colour") {
    // No colour of its own, so the ambient foreground reaches the label.
    HStack(spacing: 8) {
        Chip("Inherited")
        Chip("Critical").foregroundStyle(.swatch(.critical))
        Chip("Selected", isSelected: true)
    }
    .padding(24)
    .backdrop()
}

#Preview("Accent swatches") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach([Swatch.accent, .positive, .caution, .signature, .highlight], id: \.self) { swatch in
            HStack(spacing: 8) {
                Chip(swatch.name ?? "", isSelected: true)
                Chip("Plain")
                Chip("Badged", badge: "2", isSelected: true)
            }
            .accentSwatch(swatch)
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            VStack(alignment: .leading, spacing: 12) {
                Chip("Display")
                Chip("Selected", isSelected: true)
                Chip("Badged", badge: "3", behavior: .button {})
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .backdrop()
            .environment(\.colorScheme, scheme)
        }
    }
}
