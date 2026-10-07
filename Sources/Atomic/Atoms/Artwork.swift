//
//  Artwork.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

/// Content imagery: a cover, a photo, a thumbnail. Unlike `Icon` it keeps
/// its own colours, is sized by a frame rather than the type scope, and may
/// arrive over the network.
public struct Artwork: View {

    /// An `Icon.Source` minus SF Symbols, plus the web.
    public enum Source: Hashable, Sendable {
        case symbol(Icon.Symbol)
        case file(String)
        case bundle(String, Bundle)
        case remote(URL)
        /// What a `.remote` source shows until it arrives, for a URL that
        /// isn't known yet.
        case loading

        public static func bundle(_ name: String) -> Source {
            .bundle(name, .main)
        }
    }

    public enum Size: Hashable, Sendable {
        case small, medium, large
        /// As big as will fit, keeping the image's aspect ratio.
        case fill

        /// The side of the square frame; `nil` when the container decides.
        var dimension: CGFloat? {
            switch self {
            case .small:        80
            case .medium:       120
            case .large:        200
            case .fill:         nil
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small:        10
            case .medium:       14
            case .large, .fill: 18
            }
        }

        /// For the placeholder's spinner and glyph.
        var glyphTypography: Typography {
            switch self {
            case .small:        .small
            case .medium:       .medium
            case .large, .fill: .xLarge
            }
        }
    }

    enum Status: Equatable {
        case loaded, loading, unavailable
    }

    public let source: Source
    public let size: Size

    /// What VoiceOver reads. `nil` leaves the artwork decorative, for when
    /// nearby text already says what it shows.
    public let label: String?

    /// `.fill` crops to the frame, for photos and covers; `.fit` shows the
    /// whole image, for logos and wordmarks. `nil` crops fixed sizes and fits
    /// `Size.fill`.
    public let contentMode: ContentMode?

    public init(_ source: Source, size: Size = .medium, contentMode: ContentMode? = nil, label: String? = nil) {
        self.source = source
        self.size = size
        self.contentMode = contentMode
        self.label = label
    }

    var resolvedContentMode: ContentMode {
        contentMode ?? (size == .fill ? .fit : .fill)
    }

    public var body: some View {
        content
            .frame(width: size.dimension, height: size.dimension)
            .clipShape(.rect(cornerRadius: size.cornerRadius, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        switch source {
        case .symbol(let symbol):
            fitted(Image(symbol.rawValue, bundle: .familiar))
        case .file(let name):
            if let url = URL.familiarImage(named: name), let image = Image(contentsOf: url) {
                fitted(image)
            } else {
                placeholder(.unavailable)
            }
        case .bundle(let name, let bundle):
            fitted(Image(name, bundle: bundle))
        case .remote(let url):
            Remote(artwork: self, url: url)
        case .loading:
            placeholder(.loading)
        }
    }

    /// Fixed sizes crop to their square and `.fill` shows the whole image,
    /// unless `contentMode` says otherwise.
    private func fitted(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: resolvedContentMode)
            .modifier(Described(label: label, status: .loaded))
    }

    private func placeholder(_ status: Status) -> some View {
        Placeholder(isLoading: status == .loading, size: size)
            .modifier(Described(label: label, status: status))
    }

    /// Loads through the environment's `ImageLoader`, so the host decides how
    /// requests are built and a catalog or test can stand in for the network.
    private struct Remote: View {
        @Environment(\.imageLoader) private var loader
        @Environment(\.displayScale) private var scale
        @State private var image: Image?
        @State private var failed = false

        let artwork: Artwork
        let url: URL

        var body: some View {
            Group {
                if let image {
                    artwork.fitted(image)
                } else {
                    artwork.placeholder(failed ? .unavailable : .loading)
                }
            }
            .task(id: request) {
                image = nil
                failed = false
                do {
                    let loaded = try await loader.image(for: request)
                    withAnimation { image = loaded }
                } catch {
                    if !Task.isCancelled { failed = true }
                }
            }
        }

        private var request: ImageRequest {
            ImageRequest(
                url: url,
                pointSize: artwork.size.dimension.map { CGSize(width: $0, height: $0) },
                scale: scale
            )
        }
    }

    private struct Described: ViewModifier {
        let label: String?
        let status: Status

        func body(content: Content) -> some View {
            content
                .accessibilityElement(children: .ignore)
                .spoken(label.map { Spoken($0, value: Artwork.accessibilityValue(for: status), traits: .image) })
        }
    }

    static func accessibilityValue(for status: Status) -> String {
        switch status {
        case .loaded:       ""
        case .loading:      String(localized: "Loading", bundle: .familiar)
        case .unavailable:  String(localized: "Unavailable", bundle: .familiar)
        }
    }
}

private struct Placeholder: View {
    let isLoading: Bool
    let size: Artwork.Size

    var body: some View {
        Rectangle()
            .fill(.swatch(.surface))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if isLoading {
                    LoadingIndicator()
                } else {
                    Icon(source: .system("photo"))
                        .foregroundStyle(.swatch(.muted))
                }
            }
            .typography(size.glyphTypography)
    }
}

// MARK: - Previews

private let lake = Artwork.Source.bundle("lake", .familiar)
private let remote = URL(string: "https://picsum.photos/id/1025/600/400")!
private let missing = URL(string: "https://example.invalid/missing.png")!

#Preview("Sizes") {
    VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .top, spacing: 16) {
            Artwork(lake, size: .small)
            Artwork(lake, size: .medium)
        }
        Artwork(lake, size: .large)
    }
    .padding()
}

#Preview("Fill") {
    VStack(spacing: 16) {
        Artwork(.remote(remote), size: .fill)
            .frame(width: 320, height: 240)
        Artwork(lake, size: .fill)
            .frame(width: 320, height: 160)
    }
    .padding()
}

#Preview("Sources") {
    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
        GridRow {
            Text(".symbol")
            Artwork(.symbol(.wordmark), size: .small)
        }
        GridRow {
            Text(".file")
            Artwork(.file("nextapp"), size: .small)
        }
        GridRow {
            Text(".bundle")
            Artwork(lake, size: .small)
        }
        GridRow {
            Text(".remote")
            Artwork(.remote(remote), size: .small)
        }
    }
    .padding()
}

#Preview("Content mode") {
    HStack(alignment: .top, spacing: 16) {
        Artwork(.symbol(.wordmark), size: .small)
        Artwork(.symbol(.wordmark), size: .small, contentMode: .fit)
    }
    .padding()
}

#Preview("Loading and failure") {
    Grid(horizontalSpacing: 16, verticalSpacing: 16) {
        GridRow {
            Artwork(.loading, size: .small)
            Artwork(.loading, size: .medium)
        }
        GridRow {
            Artwork(.remote(missing), size: .small)
            Artwork(.remote(missing), size: .medium)
        }
        GridRow {
            Artwork(.file("definitely-not-an-image"), size: .small)
            Artwork(.file("definitely-not-an-image"), size: .medium)
        }
    }
    .padding()
}

#Preview("Accessibility labels") {
    HStack(spacing: 16) {
        Artwork(lake, size: .small, label: "A lake below mountains")
        Artwork(.loading, size: .small, label: "Album cover")
        Artwork(.remote(missing), size: .small, label: "Profile photo")
    }
    .padding()
}

#Preview("Light and dark") {
    VStack(spacing: 0) {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            HStack(spacing: 16) {
                Artwork(lake, size: .small)
                Artwork(.loading, size: .small)
                Artwork(.file("definitely-not-an-image"), size: .small)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(.swatch(.canvas))
            .environment(\.colorScheme, scheme)
        }
    }
}
