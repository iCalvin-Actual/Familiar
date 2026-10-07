//
//  ContentView.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Specimen?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(Tier.allCases) { tier in
                    Section(tier.title) {
                        ForEach(tier.specimens) { specimen in
                            NavigationLink(value: specimen) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(specimen.name)
                                    Text(specimen.summary)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Familiar")
        } detail: {
            NavigationStack {
                if let selection {
                    PreviewView(specimen: selection)
                } else {
                    ContentUnavailableView("Pick a component", systemImage: "square.grid.2x2")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
