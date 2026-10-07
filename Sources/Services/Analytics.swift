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

// icc-analytics
