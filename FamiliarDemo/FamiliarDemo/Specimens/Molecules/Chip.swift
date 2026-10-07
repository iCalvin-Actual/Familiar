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
                // icc-spoken
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
                    Chip("Disabled", behavior: .button {})
                        .disabled(true)
                }
            },
            Variant("Selection") { ChipSelection() },
            Variant("Sizes") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([Typography.xSmall, .small, .medium, .large], id: \.self) { size in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Chip("Plain", size: size)
                            Chip("Selected", isSelected: true, size: size)
                            Chip("Badged", badge: "3", size: size)
                        }
                    }
                }
            },
            Variant("Badges") {
                FlowLayout {
                    Chip("Plain")
                    Chip("Badged", badge: "3")
                    Chip("Wide badge", badge: "sold out")
                    Chip("Selected", badge: "9", isSelected: true, behavior: .button {})
                }
            },
            Variant("Accent swatches") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(accentSwatches, id: \.0) { name, swatch in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Chip(name, isSelected: true)
                            Chip("Plain")
                            Chip("Badged", badge: "2", isSelected: true)
                        }
                        .accentSwatch(swatch)
                    }
                }
            },
        ]
    )
}
