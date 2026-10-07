//
//  LoadingIndicator.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

public struct LoadingIndicator: View {

    /// `nil` inherits the type scope, like `Icon`.
    public let typography: Typography?

    public init(size typography: Typography? = nil) {
        self.typography = typography
    }

    public var body: some View {
        Group {
            if let typography {
                Resolved().typography(typography)
            } else {
                Resolved()
            }
        }
    }

    /// Spinners size by control size, not font, so the type scope picks one.
    static func controlSize(for pointSize: CGFloat) -> ControlSize {
        switch pointSize {
        case ..<12: .mini
        case ..<15: .small
        case ..<20: .regular
        case ..<28: .large
        default:    .extraLarge
        }
    }

    private struct Resolved: View {
        @Environment(\.typographyPointSize) private var pointSize

        var body: some View {
            ProgressView()
                .controlSize(LoadingIndicator.controlSize(for: pointSize))
        }
    }
}

#Preview("Inherits its scope") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            LoadingIndicator()
            Text("title3")
        }
        .typography(.title3)

        HStack(spacing: 8) {
            LoadingIndicator()
            Text("body")
        }
        .typography(.body)

        HStack(spacing: 8) {
            LoadingIndicator()
            Text("caption")
        }
        .typography(.caption)
    }
    .padding()
}

#Preview("Sizes") {
    HStack(alignment: .center, spacing: 16) {
        LoadingIndicator(size: .xSmall)
        LoadingIndicator(size: .small)
        LoadingIndicator(size: .medium)
        LoadingIndicator(size: .xLarge)
        LoadingIndicator(size: .xxLarge)
    }
    .padding()
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            LoadingIndicator(size: .xLarge)
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(.swatch(.canvas))
                .environment(\.colorScheme, scheme)
        }
    }
}
