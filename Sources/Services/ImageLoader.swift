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

// icc-imageloader

public enum ImageLoadingError: Error, Equatable {
    case badStatus(Int)
    case undecodable
}
