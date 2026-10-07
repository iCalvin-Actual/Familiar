//
//  ImageLoader.swift
//  Familiar
//
//  Created by Calvin Chestnut on 10/5/26.
//

import SwiftUI

/// What `Artwork` asks for: where the image is, and the size it'll be drawn
/// at, so a CDN can serve one to fit.
public struct ImageRequest: Hashable, Sendable {
    public var url: URL
    /// In points. `nil` when the container decides, as with `Artwork.Size.fill`.
    public var pointSize: CGSize?
    public var scale: CGFloat

    public init(url: URL, pointSize: CGSize? = nil, scale: CGFloat = 1) {
        self.url = url
        self.pointSize = pointSize
        self.scale = scale
    }
}

/// Turns an image request into the request that goes over the wire. The
/// host app's to own: auth headers, resize parameters, cache policy, a
/// staging host.
public protocol RequestBuilder: Sendable {
    func urlRequest(for request: ImageRequest) -> URLRequest
}

/// The URL as given.
public struct PlainRequestBuilder: RequestBuilder {
    public init() {}

    public func urlRequest(for request: ImageRequest) -> URLRequest {
        URLRequest(url: request.url)
    }
}

/// Fetches the images `Artwork` shows from `.remote` sources.
public protocol ImageLoader: Sendable {
    func image(for request: ImageRequest) async throws -> Image
}

public enum ImageLoadingError: Error, Equatable {
    case badStatus(Int)
    case undecodable
}

/// Loads over a `URLSession`, retrying the failures that tend to clear up
/// on their own.
public struct URLSessionImageLoader: ImageLoader {
    public let session: URLSession
    public let builder: any RequestBuilder
    /// Tries after the first, for transient failures only.
    public let retries: Int

    public init(session: URLSession = .shared, builder: any RequestBuilder = PlainRequestBuilder(), retries: Int = 2) {
        self.session = session
        self.builder = builder
        self.retries = retries
    }

    public func image(for request: ImageRequest) async throws -> Image {
        let urlRequest = builder.urlRequest(for: request)
        var attempt = 0
        while true {
            do {
                return try await load(urlRequest)
            } catch where attempt < retries && Self.isTransient(error) {
                attempt += 1
                // 0.5s, then 1s, …
                try await Task.sleep(for: .milliseconds(250 << attempt))
            }
        }
    }

    private func load(_ request: URLRequest) async throws -> Image {
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ImageLoadingError.badStatus(http.statusCode)
        }
        guard let image = Image(data: data) else { throw ImageLoadingError.undecodable }
        return image
    }

    /// Worth another try: the network blinked, or the server said "later".
    /// A missing host or a 404 won't change by retrying.
    static func isTransient(_ error: any Error) -> Bool {
        if case ImageLoadingError.badStatus(let code) = error {
            return code == 429 || code >= 500
        }
        guard let error = error as? URLError else { return false }
        return [.timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost].contains(error.code)
    }
}
