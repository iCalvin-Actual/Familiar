//
//  Chip.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

private struct ChipSelection: View {
    @State private var selected: Set<String> = ["Tea"]
    private let drinks = ["Coffee", "Tea", "Juice", "Smoothies", "Cocktails"]

    var body: some View {
        FlowLayout {
            ForEach(drinks, id: \.self) { drink in
                Chip(drink, isSelected: selected.contains(drink), behavior: .button {
                    if selected.remove(drink) == nil { selected.insert(drink) }
                })
                .spokenCaption()
            }
        }
    }
}

extension Specimen {
    static let chip = Specimen(
        name: "Chip",
        summary: "A compact capsule token: a filter, a tag, a count.",
        variants: [
            Variant("Behaviors") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Chip("Display")
                            .spokenCaption()
                        Chip("Button", behavior: .button {})
                            .spokenCaption()
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
                        .spokenCaption()
                    }
                    Chip("Disabled", behavior: .button {})
                        .spokenCaption()
                        .disabled(true)
                }
            },
            Variant("Selection") { ChipSelection() },
            Variant("Sizes") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([Typography.xSmall, .small, .medium, .large], id: \.self) { size in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Chip("Plain", size: size)
                                .spokenCaption()
                            Chip("Selected", isSelected: true, size: size)
                                .spokenCaption()
                            Chip("Badged", badge: "3", size: size)
                                .spokenCaption()
                        }
                    }
                }
            },
            Variant("Badges") {
                FlowLayout {
                    Chip("Plain")
                        .spokenCaption()
                    Chip("Badged", badge: "3")
                        .spokenCaption()
                    Chip("Wide badge", badge: "sold out")
                        .spokenCaption()
                    Chip("Selected", badge: "9", isSelected: true, behavior: .button {})
                        .spokenCaption()
                }
            },
            Variant("Accent swatches") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(accentSwatches, id: \.0) { name, swatch in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Chip(name, isSelected: true)
                                .spokenCaption()
                            Chip("Plain")
                                .spokenCaption()
                            Chip("Badged", badge: "2", isSelected: true)
                                .spokenCaption()
                        }
                        .accentSwatch(swatch)
                    }
                }
            },
        ]
    )
}
