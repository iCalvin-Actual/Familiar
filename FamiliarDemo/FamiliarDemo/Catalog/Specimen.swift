//
//  Specimen.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// One component in the catalog, shown as a run of variants.
struct Specimen: Identifiable, Hashable {
    let name: String
    let summary: String
    let variants: [Variant]

    var id: String { name }

    static func == (lhs: Specimen, rhs: Specimen) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Variant: Identifiable {
    let title: String
    /// Runs to the screen edges, for rows that inset their own content.
    let bleeds: Bool
    let content: AnyView

    var id: String { title }

    init<Content: View>(_ title: String, bleeds: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.bleeds = bleeds
        self.content = AnyView(content())
    }
}
