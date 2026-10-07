//
//  PreviewView.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

struct PreviewView: View {
    let specimen: Specimen

    @State private var scheme: ColorScheme?
    @State private var isAccessibilitySize = false
    @State private var showsVoiceOver = true
    @State private var accent: Accent = .app

    var body: some View {
        List {
            Section {
                Text(specimen.summary)
                    .typography(.body2)
                    .foregroundStyle(.swatch(.muted))
            }

            ForEach(specimen.variants) { variant in
                Section(variant.title) {
                    variant.content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(variant.bleeds ? EdgeInsets(top: Spacing.medium, leading: 0, bottom: Spacing.medium, trailing: 0) : nil)
                }
            }
        }
        .foregroundStyle(.swatch(.ink))
        // Grouped rows over the brand canvas, so glass still has something to refract.
        .scrollContentBackground(.hidden)
        .background { Backdrop() }
        .dynamicTypeSize(isAccessibilitySize ? .accessibility3 ... .accessibility3 : .xSmall ... .accessibility5)
        .preferredColorScheme(scheme)
        .accentSwatch(accent.swatch)
        // Each component captions itself with what VoiceOver reads, laid out
        // as it would be for VoiceOver.
        .showsSpokenCaptions(showsVoiceOver)
        .forcedVoiceOver(showsVoiceOver ? true : nil)
        .navigationTitle(specimen.name)
        .tracksAppearance(AnalyticsEvent("specimen_viewed", properties: ["name": specimen.name]))
        .tracksTaps(AnalyticsEvent("specimen_tapped", properties: ["name": specimen.name]))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Appearance", selection: $scheme) {
                        Text("System").tag(ColorScheme?.none)
                        Text("Light").tag(ColorScheme?.some(.light))
                        Text("Dark").tag(ColorScheme?.some(.dark))
                    }
                    Picker("Accent", selection: $accent) {
                        ForEach(Accent.allCases, id: \.self) { accent in
                            Text(accent.title).tag(accent)
                        }
                    }
                    Toggle("Accessibility XL", isOn: $isAccessibilitySize)
                    Toggle("VoiceOver", isOn: $showsVoiceOver)
                } label: {
                    Label(systemIcon: "slider.horizontal.3", label: "Options")
                }
                .menuStyle(.button)
                .buttonStyle(.familiar(.glass(), size: .body))
            }
            #if !os(visionOS)
            .sharedBackgroundVisibility(.hidden)
            #endif
        }
    }
}

/// Whose colour the components wear: the app's AccentColor asset, passed in
/// as a plain Color the way any host would, or Familiar's brand accent.
private enum Accent: CaseIterable {
    case app, brand

    var title: String {
        switch self {
        case .app:      "App"
        case .brand:    "Brand"
        }
    }

    var swatch: Swatch {
        switch self {
        case .app:      .system(Color("AccentColor"))
        case .brand:    .accent
        }
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
