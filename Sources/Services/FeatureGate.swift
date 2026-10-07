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

// icc-featuregate
