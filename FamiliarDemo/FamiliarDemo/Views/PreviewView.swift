//
//  PreviewView.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

struct PreviewView: View {
    let specimen: Specimen

    var body: some View {
        List {
            Section {
                Text(specimen.summary)
                    .foregroundStyle(.secondary)
            }

            ForEach(specimen.variants) { variant in
                Section(variant.title) {
                    variant.content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(variant.bleeds ? EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0) : nil)
                }
            }
        }
        .navigationTitle(specimen.name)
    }
}

#Preview {
    NavigationStack {
        PreviewView(specimen: Specimen(
            name: "Text",
            summary: "A placeholder specimen.",
            variants: [Variant("Plain") { Text("Hello") }]
        ))
    }
}
