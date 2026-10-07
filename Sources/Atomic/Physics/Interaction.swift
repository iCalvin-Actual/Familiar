//
//  Interaction.swift
//  Familiar
//
//  Created by Calvin Chestnut on 10/3/26.
//

import SwiftUI

/// A pointer, touch or keyboard state a control only holds for a moment.
public enum Interaction: Hashable, Sendable, CaseIterable {
    case hovered
    case pressed
    /// Keyboard focus: iPad with a keyboard, Mac, Full Keyboard Access.
    case focused

    struct State: Equatable {
        var isHovered = false
        var isPressed = false
        var isFocused = false
    }

    /// A forced state wins over the live one, so a catalog or preview can pin it.
    static func resolve(forced: Interaction?, live: State) -> State {
        guard let forced else { return live }
        return State(isHovered: forced == .hovered, isPressed: forced == .pressed, isFocused: forced == .focused)
    }
}

extension EnvironmentValues {
    /// Pins every control beneath it in one interaction state. `nil` follows the pointer, touches and keyboard.
    @Entry public var forcedInteraction: Interaction? = nil
}

public extension View {
    func forcedInteraction(_ interaction: Interaction?) -> some View {
        environment(\.forcedInteraction, interaction)
    }
}

extension View {
    /// Swaps the system pointer highlight and focus ring for our own, so they look the same everywhere.
    @ViewBuilder
    func ownsInteraction(_ isHovering: Binding<Bool>) -> some View {
        #if os(macOS)
        onHover { isHovering.wrappedValue = $0 }
            .focusEffectDisabled()
        #else
        onHover { isHovering.wrappedValue = $0 }
            .hoverEffectDisabled()
            .focusEffectDisabled()
        #endif
    }

    /// The ring drawn around a focused control, `gap` outside its shape.
    func focusRing<S: InsettableShape>(_ shape: S, isFocused: Bool, swatch: Swatch, gap: CGFloat = 3) -> some View {
        overlay {
            if isFocused {
                shape.inset(by: -gap).strokeBorder(.swatch(swatch), lineWidth: 2)
            }
        }
    }

    /// Grows the hit area to the minimum tap target without growing what's drawn.
    func minimumTapTarget(_ applies: Bool = true) -> some View {
        frame(minWidth: applies ? Spacing.minimumTapTarget : nil, minHeight: applies ? Spacing.minimumTapTarget : nil)
            .contentShape(.rect)
    }
}
