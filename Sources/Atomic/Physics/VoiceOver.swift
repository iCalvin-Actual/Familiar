//
//  VoiceOver.swift
//  Familiar
//
//  Created by Calvin Chestnut on 10/5/26.
//

import SwiftUI

/// What VoiceOver reads for one element. A component builds one and applies
/// it with `spoken(_:)`, which sets the accessibility API from it and reports
/// the same value up the view tree, so a catalog shows exactly what
/// VoiceOver is told.
struct Spoken: Hashable, Sendable {

    struct Traits: OptionSet, Hashable, Sendable {
        let rawValue: Int

        static let button   = Traits(rawValue: 1 << 0)
        static let selected = Traits(rawValue: 1 << 1)
        static let header   = Traits(rawValue: 1 << 2)
        static let image    = Traits(rawValue: 1 << 3)
        /// Reported only: SwiftUI marks disabled views itself.
        static let dimmed   = Traits(rawValue: 1 << 4)

        /// In the order VoiceOver speaks them. For captions, so not localized.
        var names: [String] {
            let names: [(Traits, String)] = [
                (.selected, "Selected"),
                (.button, "Button"),
                (.header, "Heading"),
                (.image, "Image"),
                (.dimmed, "Dimmed"),
            ]
            return names.filter { contains($0.0) }.map(\.1)
        }

        var accessibility: AccessibilityTraits {
            var traits: AccessibilityTraits = []
            if contains(.button)   { traits.formUnion(.isButton) }
            if contains(.selected) { traits.formUnion(.isSelected) }
            if contains(.header)   { traits.formUnion(.isHeader) }
            if contains(.image)    { traits.formUnion(.isImage) }
            return traits
        }
    }

    /// Empty leaves the system's own description in place, such as an SF
    /// Symbol's or a spinner's.
    var label: String
    var value: String
    var traits: Traits
    /// Custom action names, in rotor order. The component that owns the
    /// actions attaches them; this is what they're called.
    var actions: [String]

    init(_ label: String, value: String = "", traits: Traits = [], actions: [String] = []) {
        self.label = label
        self.value = value
        self.traits = traits
        self.actions = actions
    }

    /// Several elements merged into one, the way `.combine` and buttons
    /// merge their children. `nil` when there's nothing to merge.
    ///
    /// A button reads as a button, whatever its label is made of, so it
    /// passes `keepingTraits: false` to drop an icon's Image.
    init?(combining elements: [Spoken], adding traits: Traits = [], keepingTraits: Bool = true) {
        guard !elements.isEmpty else { return nil }
        self.init(
            elements.map(\.label).filter { !$0.isEmpty }.joined(separator: ", "),
            value: elements.map(\.value).filter { !$0.isEmpty }.joined(separator: ", "),
            traits: keepingTraits ? elements.reduce(traits) { $0.union($1.traits) } : traits,
            actions: elements.flatMap(\.actions)
        )
    }
}

struct SpokenKey: PreferenceKey {
    static var defaultValue: [Spoken] { [] }

    static func reduce(value: inout [Spoken], nextValue: () -> [Spoken]) {
        value += nextValue()
    }
}

extension View {
    /// Tells VoiceOver what this element reads, and reports it in place of
    /// anything its children reported, since VoiceOver hears this element
    /// instead of them. `nil` hides it.
    func spoken(_ spoken: Spoken?) -> some View {
        modifier(SpokenModifier(spoken: spoken))
    }

    /// For views whose children VoiceOver already hears as one element, such
    /// as a button or a `.combine`: reports them merged, plus `traits`.
    func spokenCombined(adding traits: Spoken.Traits = [], keepingTraits: Bool = true) -> some View {
        transformPreference(SpokenKey.self) { elements in
            elements = Spoken(combining: elements, adding: traits, keepingTraits: keepingTraits).map { [$0] } ?? []
        }
    }

    /// Adds traits to this element, for VoiceOver and in its report.
    func spokenTraits(_ traits: Spoken.Traits) -> some View {
        accessibilityAddTraits(traits.accessibility)
            .transformPreference(SpokenKey.self) { elements in
                for index in elements.indices {
                    elements[index].traits.formUnion(traits)
                }
            }
    }
}

extension Spoken {
    /// Roughly what VoiceOver says on landing: label, value, traits.
    var phrase: String {
        ([label, value] + traits.names)
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

// MARK: - Captions

extension EnvironmentValues {
    /// Turns on `spokenCaption()`, for a catalog.
    @Entry public var showsSpokenCaptions = false
}

public extension View {
    /// Turns on the captions placed with `spokenCaption()` inside this view.
    func showsSpokenCaptions(_ shows: Bool = true) -> some View {
        environment(\.showsSpokenCaptions, shows)
    }

    /// Writes what VoiceOver reads for this view beneath it, while captions
    /// are turned on. Placed where a component is used, not inside it, so
    /// the caption never lands within the component's own layout.
    func spokenCaption() -> some View {
        modifier(SpokenCaption())
    }
}

private struct SpokenCaption: ViewModifier {
    @Environment(\.showsSpokenCaptions) private var showsCaptions
    @State private var elements: [Spoken] = []

    func body(content: Content) -> some View {
        if showsCaptions {
            let elements = $elements
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                content
                    .onPreferenceChange(SpokenKey.self) { elements.wrappedValue = $0 }
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                }
                .typography(.annotation, emphasis: .secondary)
                // Says what VoiceOver hears; VoiceOver shouldn't hear it twice.
                .accessibilityHidden(true)
            }
        } else {
            content
        }
    }

    /// One line per stop. Stops the system describes for us, like an SF
    /// Symbol, have nothing of ours to show and are left out.
    private var lines: [String] {
        guard !elements.isEmpty else { return ["Hidden"] }
        return elements.filter { !$0.label.isEmpty }.map(\.phrase)
    }
}

private struct SpokenModifier: ViewModifier {
    let spoken: Spoken?

    func body(content: Content) -> some View {
        if let spoken {
            content
                .modifier(LabelAndValue(spoken: spoken))
                .accessibilityAddTraits(spoken.traits.accessibility)
                .transformPreference(SpokenKey.self) { $0 = [spoken] }
        } else {
            content
                .accessibilityHidden(true)
                .transformPreference(SpokenKey.self) { $0 = [] }
        }
    }

    /// Empty strings leave the system's own label and value alone.
    private struct LabelAndValue: ViewModifier {
        let spoken: Spoken

        func body(content: Content) -> some View {
            switch (spoken.label.isEmpty, spoken.value.isEmpty) {
            case (true, true):
                content
            case (false, true):
                content.accessibilityLabel(Text(verbatim: spoken.label))
            case (true, false):
                content.accessibilityValue(Text(verbatim: spoken.value))
            case (false, false):
                content
                    .accessibilityLabel(Text(verbatim: spoken.label))
                    .accessibilityValue(Text(verbatim: spoken.value))
            }
        }
    }
}

extension EnvironmentValues {
    /// Overrides whether components lay themselves out for VoiceOver, so a
    /// catalog or preview can show the VoiceOver shape without VoiceOver on.
    /// `nil` follows the system.
    @Entry public var forcedVoiceOver: Bool? = nil
}

public extension View {
    func forcedVoiceOver(_ isRunning: Bool?) -> some View {
        environment(\.forcedVoiceOver, isRunning)
    }
}
