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
                                Button("Delete", role: .destructive, prominence: prominence) {}
                            }
                            GridRow {
                                Button("Off", prominence: prominence) {}
                                    .disabled(true)
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
                            Button("Glass", prominence: .glass(.accent), size: size) {}
                        }
                    }
                    Button("Display", size: .display) {}
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
                        Button("Intrinsic: continue to checkout", width: .intrinsic) {}
                    }
                    Button("Fill", width: .fill) {}
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Button("Cancel", prominence: .outlined, width: .fill) {}
                        Button("Continue", prominence: .glass(.accent), width: .fill) {}
                    }
                }
            },
            Variant("Icons") {
                Pairs {
                    GridRow {
                        Button("Share", systemIcon: "square.and.arrow.up") {}
                        Button(.icon(.symbol(.wordmark)), prominence: .outlined) {}
                    }
                    GridRow {
                        Button(.systemIcon("trash"), role: .destructive, prominence: .tinted) {}
                        Button(.systemIcon("trash"), role: .destructive, prominence: .glass()) {}
                    }
                    GridRow {
                        Button(.textIcon("Open the app", .file("nextapp")), prominence: .glass(), size: .title3) {}
                            .gridCellColumns(2)
                    }
                    GridRow {
                        Button("Remove", systemIcon: "trash", role: .destructive, prominence: .plain) {}
                    }
                }
            },
            Variant("Accent swatches") {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(accentSwatches, id: \.0) { name, swatch in
                        Pairs {
                            GridRow {
                                Button(name) {}
                                Button("Tinted", prominence: .tinted) {}
                            }
                            GridRow {
                                Button("Outlined", prominence: .outlined) {}
                            }
                        }
                        .accentSwatch(swatch)
                    }
                }
            },
            Variant("SwiftUI.Button") {
                VStack(alignment: .leading, spacing: 12) {
                    SwiftUI.Button {} label: { Label(text: "Matte") }
                        .buttonStyle(.familiar)
                    SwiftUI.Button {} label: { Label(text: "Glass") }
                        .buttonStyle(.familiar(.glass(.accent)))
                    SwiftUI.Button {} label: { Label(icon: .symbol(.wordmark)) }
                        .buttonStyle(.familiar(.outlined))
                }
            },
        ]
    )
}

#Preview {
    NavigationStack {
        PreviewView(specimen: .button)
    }
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

