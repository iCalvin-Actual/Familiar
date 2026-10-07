//
//  Button.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

private let prominences: [(String, Familiar.Button.Prominence)] = [
    ("matte", .matte), ("glass", .glass(.accent)), ("native glass", .glass()), ("tinted", .tinted), ("outlined", .outlined), ("plain", .plain),
]

extension Specimen {
    static let button = Specimen(
        name: "Button",
        summary: "An action in one of six prominences, tinted by the ambient accent.",
        variants: [
            Variant("Prominence") {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(prominences, id: \.0) { name, prominence in
                        Pairs {
                            GridRow {
                                Button(name.capitalized, prominence: prominence) {}
                                    .spokenCaption()
                                Button("Delete", role: .destructive, prominence: prominence) {}
                                    .spokenCaption()
                            }
                            GridRow {
                                Button("Off", prominence: prominence) {}
                                    .spokenCaption()
                                    .disabled(true)
                            }
                        }
                    }
                }
            },
            Variant("Interaction") {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(prominences, id: \.0) { name, prominence in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(name.capitalized)
                                .typography(.annotation)
                                .foregroundStyle(.swatch(.muted))
                            Pairs {
                                GridRow {
                                    Button("Rest", prominence: prominence) {}
                                        .spokenCaption()
                                    Button("Hovered", prominence: prominence) {}
                                        .spokenCaption()
                                        .forcedInteraction(.hovered)
                                }
                                GridRow {
                                    Button("Pressed", prominence: prominence) {}
                                        .spokenCaption()
                                        .forcedInteraction(.pressed)
                                    Button("Focused", prominence: prominence) {}
                                        .spokenCaption()
                                        .forcedInteraction(.focused)
                                }
                            }
                        }
                    }
                }
            },
            Variant("Sizes") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([Typography.caption, .small, .cta, .title3], id: \.self) { size in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Button("Matte", size: size) {}
                                .spokenCaption()
                            Button("Glass", prominence: .glass(.accent), size: size) {}
                                .spokenCaption()
                        }
                    }
                    Button("Display", size: .display) {}
                        .spokenCaption()
                        .displayFamily(.display)
                }
            },
            Variant("Width") {
                VStack(alignment: .leading, spacing: 16) {
                    // With room to spare these two look the same. In a tight
                    // space, flexible truncates and intrinsic keeps its whole
                    // label, running past the edge.
                    TightSpace {
                        Button("Flexible: continue to checkout") {}
                            .spokenCaption()
                        Button("Intrinsic: continue to checkout", width: .intrinsic) {}
                            .spokenCaption()
                    }
                    Button("Fill", width: .fill) {}
                        .spokenCaption()
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Button("Cancel", prominence: .outlined, width: .fill) {}
                            .spokenCaption()
                        Button("Continue", prominence: .glass(.accent), width: .fill) {}
                            .spokenCaption()
                    }
                }
            },
            Variant("Icons") {
                Pairs {
                    GridRow {
                        Button("Share", systemIcon: "square.and.arrow.up") {}
                            .spokenCaption()
                        Button(.icon(.symbol(.wordmark)), prominence: .outlined) {}
                            .spokenCaption()
                    }
                    GridRow {
                        Button(.systemIcon("trash", label: "Delete"), role: .destructive, prominence: .tinted) {}
                            .spokenCaption()
                        Button(.systemIcon("trash", label: "Delete"), role: .destructive, prominence: .glass()) {}
                            .spokenCaption()
                    }
                    GridRow {
                        Button(.textIcon("Open the app", .file("nextapp")), prominence: .glass(), size: .title3) {}
                            .spokenCaption()
                            .gridCellColumns(2)
                    }
                    GridRow {
                        Button("Remove", systemIcon: "trash", role: .destructive, prominence: .plain) {}
                            .spokenCaption()
                    }
                }
            },
            Variant("Accent swatches") {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(accentSwatches, id: \.0) { name, swatch in
                        Pairs {
                            GridRow {
                                Button(name) {}
                                    .spokenCaption()
                                Button("Tinted", prominence: .tinted) {}
                                    .spokenCaption()
                            }
                            GridRow {
                                Button("Outlined", prominence: .outlined) {}
                                    .spokenCaption()
                            }
                        }
                        .accentSwatch(swatch)
                    }
                }
            },
            Variant("SwiftUI.Button") {
                VStack(alignment: .leading, spacing: 12) {
                    // Familiar's Label rather than a bare string, so the style
                    // can caption what VoiceOver reads.
                    SwiftUI.Button {} label: { Label(text: "Matte") }
                        .buttonStyle(.familiar)
                        .spokenCaption()
                    SwiftUI.Button {} label: { Label(text: "Glass") }
                        .buttonStyle(.familiar(.glass(.accent)))
                        .spokenCaption()
                    SwiftUI.Button {} label: { Label(icon: .symbol(.wordmark)) }
                        .buttonStyle(.familiar(.outlined))
                        .spokenCaption()
                }
            },
        ]
    )
}

#Preview {
    NavigationStack {
        PreviewView(specimen: .button)
    }
    .imageLoader(MockImageLoader.catalog)
}

/// A narrow box with its edge drawn, so what a button does when it runs out
/// of room is visible.
private struct TightSpace<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .frame(width: 220, alignment: .leading)
        .padding(8)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.swatch(.muted), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }
}

/// Two columns at most, so a phone-width page has room for each button and
/// its caption.
private struct Pairs<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 16) {
            content
        }
    }
}

