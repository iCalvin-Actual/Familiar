//
//  FeatureGate.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/30/26.
//

import Foundation

public struct FeatureFlag: Hashable, Sendable, ExpressibleByStringLiteral {
    public let key: String

    public init(_ key: String) {
        self.key = key
    }

    public init(stringLiteral key: String) {
        self.init(key)
    }
}

/// Answers whether a flag is on. Main-actor bound so a host can conform an
/// `@Observable` flag service and have gated views update when it changes.
@MainActor
public protocol FeatureGate {
    func isEnabled(_ flag: FeatureFlag) -> Bool
}

/// A fixed set of enabled flags, for previews, tests, and apps without a
/// flag service. Everything is off by default.
public struct StaticFeatureGate: FeatureGate, Sendable {
    public let enabled: Set<FeatureFlag>

    nonisolated public init(enabled: Set<FeatureFlag> = []) {
        self.enabled = enabled
    }

    public func isEnabled(_ flag: FeatureFlag) -> Bool {
        enabled.contains(flag)
    }
}
