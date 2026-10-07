//
//  Analytics.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/30/26.
//

import Foundation

/// Something that happened, described without naming a vendor.
public struct AnalyticsEvent: Hashable, Sendable {
    public let name: String
    public let properties: [String: String]

    public init(_ name: String, properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties
    }
}

/// Where events go. The package emits them; the host app decides what
/// receives them.
public protocol Analytics: Sendable {
    func track(_ event: AnalyticsEvent)
}

/// Drops every event. The default, so previews and tests need no setup.
public struct NoAnalytics: Analytics {
    public init() {}

    public func track(_ event: AnalyticsEvent) {}
}
