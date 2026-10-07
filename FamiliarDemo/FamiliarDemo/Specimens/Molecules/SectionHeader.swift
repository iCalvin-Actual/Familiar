//
//  SectionHeader.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let sectionHeader = Specimen(
        name: "SectionHeader",
        summary: "A title, an optional subtitle, and an optional action.",
        variants: [
            Variant("Variants") {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeader("Drinks")
                    SectionHeader("Drinks", subtitle: "Something for every hour")
                    SectionHeader("Drinks", subtitle: "Something for every hour", action: Button("See all", prominence: .plain) {})
                    SectionHeader("Drinks", action: Button("See all", systemIcon: "chevron.right", prominence: .tinted, size: .small) {})
                }
            },
            Variant("Long title") {
                SectionHeader(
                    "Hand-picked drinks from our favourite cafés",
                    subtitle: "Updated every morning from what our baristas are pouring",
                    action: Button("See all", prominence: .plain) {}
                )
            },
        ]
    )
}
