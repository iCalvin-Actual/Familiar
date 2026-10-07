//
//  Button.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

public struct Button: View {

    public enum Prominence: Hashable, Sendable {
        case matte
        /// `nil` is native, uncolored glass.
        case glass(Swatch? = nil)
        case tinted, outlined, plain
    }

    public enum Width: Hashable, Sendable {
        /// May be compressed; text truncates at its line limit.
        case flexible
        case intrinsic
        case fill
    }

    public let label: Label.Style
    public let role: ButtonRole?
    public let prominence: Prominence
    public let typography: Typography
    public let width: Width
    private let action: () -> Void

    @Environment(\.analytics) private var analytics
    @Environment(\.tapEvent) private var tapEvent

    public init(
        _ label: Label.Style,
        role: ButtonRole? = nil,
        prominence: Prominence = .matte,
        size typography: Typography = .cta,
        width: Width = .flexible,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.role = role
        self.prominence = prominence
        self.typography = typography
        self.width = width
        self.action = action
    }

    public init(
        _ text: String,
        role: ButtonRole? = nil,
        prominence: Prominence = .matte,
        size typography: Typography = .cta,
        width: Width = .flexible,
        action: @escaping () -> Void
    ) {
        self.init(.text(text), role: role, prominence: prominence, size: typography, width: width, action: action)
    }

    public init(
        _ text: String,
        systemIcon: String,
        role: ButtonRole? = nil,
        prominence: Prominence = .matte,
        size typography: Typography = .cta,
        width: Width = .flexible,
        action: @escaping () -> Void
    ) {
        self.init(.textSystemIcon(text, systemIcon), role: role, prominence: prominence, size: typography, width: width, action: action)
    }

    public var body: some View {
        SwiftUI.Button(role: role) {
            if let tapEvent { analytics.track(tapEvent) }
            action()
        } label: {
            Label(style: label, size: typography)
        }
        .buttonStyle(Style(prominence, size: typography, width: width))
    }
}

// MARK: - Style

public extension Button {

    struct Style: ButtonStyle {
        public let prominence: Prominence
        public let typography: Typography
        public let width: Width

        public init(_ prominence: Prominence = .matte, size typography: Typography = .cta, width: Width = .flexible) {
            self.prominence = prominence
            self.typography = typography
            self.width = width
        }

        public func makeBody(configuration: Configuration) -> some View {
            // Inside the type scope, so Chrome can read the resolved point size.
            Chrome(configuration: configuration, prominence: prominence, width: width)
                .typography(typography)
        }

        static func swatch(for role: ButtonRole?, accent: Swatch) -> Swatch {
            role == .destructive ? .critical : accent
        }

        /// Plain buttons have no surface to change, so hover dims the label instead.
        static func opacity(isEnabled: Bool, isPressed: Bool, isHovered: Bool) -> Double {
            guard isEnabled else { return 0.4 }
            if isPressed { return 0.7 }
            return isHovered ? 0.8 : 1
        }
    }
}

private struct Chrome: View {
    @Environment(\.typographyPointSize) private var pointSize
    @Environment(\.accentSwatch) private var accent
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.forcedInteraction) private var forcedInteraction
    @Environment(\.isFocused) private var isFocused
    @State private var isHovering = false

    let configuration: ButtonStyleConfiguration
    let prominence: Button.Prominence
    let width: Button.Width

    private var tint: Swatch? {
        if case .glass(let tint) = prominence { tint } else { nil }
    }

    var body: some View {
        let swatch = Button.Style.swatch(for: configuration.role, accent: tint ?? accent)
        let shape = RoundedRectangle(cornerRadius: pointSize * 0.6, style: .continuous)
        let glassTint: Color?? = switch prominence {
        case .glass(.some):  .some(swatch.color(in: colorScheme, contrast: contrast))
        case .glass(.none):  .some(nil)
        default:             nil
        }
        let isGlass = glassTint != nil
        let state = Interaction.resolve(
            forced: forcedInteraction,
            live: .init(isHovered: isHovering, isPressed: configuration.isPressed, isFocused: isFocused)
        )
        // Interactive glass has its own hover and press response.
        let isPressed = state.isPressed && !isGlass
        let isHovered = state.isHovered && !isGlass && isEnabled

        let content = configuration.label
            .frame(maxWidth: width == .fill ? .infinity : nil)
            .foregroundStyle(labelStyle(swatch))
            .padding(.horizontal, prominence == .plain ? 0 : pointSize)
            .padding(.vertical, prominence == .plain ? 0 : pointSize * 0.6)
            .background {
                switch prominence {
                case .matte:
                    shape.fill(.swatch(swatch)).opacity(isHovered ? 0.85 : 1)
                case .tinted:
                    shape.fill(.swatch(swatch)).opacity(isHovered ? 0.25 : 0.15)
                case .outlined:
                    shape.fill(.swatch(swatch)).opacity(isHovered ? 0.1 : 0)
                        .overlay(shape.strokeBorder(.swatch(swatch), lineWidth: 1.5))
                case .glass, .plain:
                    EmptyView()
                }
            }

        Group {
            if let glassTint {
                content.familiarGlass(tint: glassTint, in: shape)
            } else {
                content
            }
        }
        // Plain has no padding of its own, so its ring needs more room.
        .focusRing(shape, isFocused: state.isFocused && isEnabled, swatch: swatch, gap: prominence == .plain ? pointSize * 0.4 : 3)
        .opacity(Button.Style.opacity(isEnabled: isEnabled, isPressed: isPressed, isHovered: isHovered && prominence == .plain))
        .scaleEffect(isPressed ? 0.97 : 1)
        .minimumTapTarget()
        // Outside the tap-target frame, which would otherwise take only the
        // space it's offered and centre a wider label inside it.
        .fixedSize(horizontal: width == .intrinsic, vertical: false)
        .ownsInteraction($isHovering)
        // SwiftUI.Button supplies the trait and dims itself; this reports them.
        .spokenCombined(adding: isEnabled ? .button : [.button, .dimmed], keepingTraits: false)
        .animation(.snappy(duration: 0.15), value: isPressed)
        .animation(.snappy(duration: 0.15), value: isHovered)
    }

    private func labelStyle(_ swatch: Swatch) -> AnyShapeStyle {
        switch prominence {
        case .matte, .glass(.some):
            AnyShapeStyle(.swatch(.canvas))
        case .glass(.none):
            configuration.role == .destructive ? AnyShapeStyle(.swatch(.critical)) : AnyShapeStyle(.primary)
        case .tinted, .outlined, .plain:
            AnyShapeStyle(.swatch(swatch))
        }
    }
}

public extension ButtonStyle where Self == Button.Style {
    static var familiar: Button.Style { Button.Style() }

    static func familiar(
        _ prominence: Button.Prominence,
        size typography: Typography = .cta,
        width: Button.Width = .flexible
    ) -> Button.Style {
        Button.Style(prominence, size: typography, width: width)
    }
}

// MARK: - Previews

private let prominences: [Button.Prominence] = [.matte, .glass(.accent), .glass(), .tinted, .outlined, .plain]

#Preview("Prominence") {
    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 16) {
        ForEach(prominences, id: \.self) { prominence in
            GridRow {
                Button("Continue", prominence: prominence) {}
                Button("Delete", role: .destructive, prominence: prominence) {}
                Button("Disabled", prominence: prominence) {}
                    .disabled(true)
            }
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Interaction") {
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 12) {
        ForEach(prominences, id: \.self) { prominence in
            GridRow {
                Button("Rest", prominence: prominence, size: .small) {}
                ForEach(Interaction.allCases, id: \.self) { interaction in
                    Button("\(interaction)".capitalized, prominence: prominence, size: .small) {}
                        .forcedInteraction(interaction)
                }
            }
        }
    }
    .padding(24)
    .backdrop()
}

#Preview("Sizes") {
    VStack(alignment: .leading, spacing: 12) {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
            ForEach([Typography.caption, .small, .cta, .title3], id: \.self) { size in
                GridRow {
                    Button("Matte", size: size) {}
                    Button("Glass", prominence: .glass(.accent), size: size) {}
                    Button("Native", prominence: .glass(), size: size) {}
                }
            }
        }
        HStack(spacing: 12) {
            Button("Matte", size: .display) {}
            Button("Glass", prominence: .glass(.accent), size: .display) {}
        }
        .displayFamily(.display)
        Button("Native", prominence: .glass(), size: .display) {}
            .displayFamily(.display)
    }
    .padding(24)
    .backdrop()
}

#Preview("Accessibility XL") {
    VStack(alignment: .leading, spacing: 12) {
        Button("cta — scales") {}
        Button("glass — scales", prominence: .glass(.accent)) {}
        Button("custom(17) — fixed", size: .custom(17, weight: .semibold)) {}
    }
    .padding(24)
    .backdrop()
    .dynamicTypeSize(.accessibility3)
}

#Preview("Width") {
    VStack(alignment: .leading, spacing: 16) {
        ForEach([Button.Width.flexible, .intrinsic], id: \.self) { width in
            HStack(spacing: 12) {
                Button("Continue", width: width) {}
                Button("Delete", role: .destructive, width: width) {}
                Button("Disabled", width: width) {}
                    .disabled(true)
            }
            .frame(width: 260, alignment: .leading)
        }
        Button("Continue", width: .fill) {}
        HStack(spacing: 12) {
            Button("Cancel", prominence: .outlined, width: .fill) {}
            Button("Continue", prominence: .glass(.accent), width: .fill) {}
        }
    }
    .frame(width: 320)
    .padding(24)
    .backdrop()
}

#Preview("Icons") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 12) {
            Button("Share", systemIcon: "square.and.arrow.up") {}
            Button(.systemIcon("trash"), role: .destructive, prominence: .tinted) {}
        }
        HStack(spacing: 12) {
            Button("Share", systemIcon: "square.and.arrow.up", prominence: .glass(.accent)) {}
            Button(.systemIcon("trash"), role: .destructive, prominence: .glass(.accent)) {}
        }
        HStack(spacing: 12) {
            Button("Share", systemIcon: "square.and.arrow.up", prominence: .glass()) {}
            Button(.systemIcon("trash"), role: .destructive, prominence: .glass()) {}
        }
        Button(.icon(.symbol(.wordmark)), prominence: .outlined) {}
        Button(.textIcon("Open the app", .file("nextapp")), prominence: .glass(), size: .title3) {}
        Button("Remove", systemIcon: "trash", role: .destructive, prominence: .plain) {}
    }
    .padding(24)
    .backdrop()
}

#Preview("Accent swatches") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach([Swatch.accent, .positive, .caution, .signature, .highlight], id: \.self) { swatch in
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Button(swatch.name ?? "") {}
                    Button("Glass", prominence: .glass(swatch)) {}
                }
                HStack(spacing: 12) {
                    Button("Tinted", prominence: .tinted) {}
                    Button("Outlined", prominence: .outlined) {}
                }
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
                ForEach(prominences, id: \.self) { prominence in
                    HStack(spacing: 12) {
                        Button("Continue", prominence: prominence) {}
                        Button("Delete", role: .destructive, prominence: prominence) {}
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .backdrop()
            .environment(\.colorScheme, scheme)
        }
    }
}

#Preview("SwiftUI.Button") {
    VStack(alignment: .leading, spacing: 12) {
        SwiftUI.Button("Matte") {}
            .buttonStyle(.familiar)
        SwiftUI.Button("Glass") {}
            .buttonStyle(.familiar(.glass(.accent)))
        SwiftUI.Button("Native glass") {}
            .buttonStyle(.familiar(.glass()))
        SwiftUI.Button {} label: {
            HStack(spacing: 6) {
                Icon(source: .symbol(.wordmark))
                Text("Custom label")
            }
        }
        .buttonStyle(.familiar(.outlined))
    }
    .padding(24)
    .backdrop()
}
