//
//  MockImageLoader.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 10/5/26.
//

import SwiftUI
import Familiar

/// Answers `mock://` image requests from a table instead of the network, so
/// the catalog works offline and can hold any loading state on demand. Any
/// other URL goes to the real loader.
///
///     Artwork(.remote(URL(string: "mock://slow")!))
struct MockImageLoader: ImageLoader {

    enum Response: Sendable {
        /// Arrives after `delay`.
        case image(Image, after: Duration = .zero)
        /// Never arrives.
        case loading
        /// Fails after `delay`.
        case failure(after: Duration = .zero)
    }

    struct NotFound: Error {}

    /// Keyed by the URL's host: `mock://lake` is `"lake"`.
    let responses: [String: Response]
    let fallback: any ImageLoader

    init(_ responses: [String: Response], fallback: any ImageLoader = URLSessionImageLoader()) {
        self.responses = responses
        self.fallback = fallback
    }

    func image(for request: ImageRequest) async throws -> Image {
        guard request.url.scheme == "mock" else {
            return try await fallback.image(for: request)
        }
        switch responses[request.url.host() ?? ""] {
        case .image(let image, let delay):
            try await Task.sleep(for: delay)
            return image
        case .loading:
            // Until the view goes away and cancels the task, which makes sleep throw.
            while true {
                try await Task.sleep(for: .seconds(3600))
            }
        case .failure(let delay):
            try await Task.sleep(for: delay)
            throw NotFound()
        case nil:
            throw NotFound()
        }
    }
}

extension MockImageLoader {
    /// Everything the catalog's specimens ask for.
    static let catalog = MockImageLoader([
        "lake":    .image(Image("lake", bundle: .familiar)),
        "slow":    .image(Image("lake", bundle: .familiar), after: .seconds(2)),
        "loading": .loading,
        "missing": .failure(after: .milliseconds(300)),
    ])
}
