//
//  FontFamily.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import CoreText
import Foundation
import SwiftUI

/// A font family and the strategy for getting a weight out of it.
///
/// - **Static**: one file per face. Weight is a name lookup (`Array-Bold`).
/// - **Variable**: one file, one PostScript name, and a `wght` axis.
public struct FontFamily: Equatable, Hashable, Sendable {

    public struct Face: Equatable, Hashable, Sendable {
        public let postScriptName: String
        public let weightClass: CGFloat

        public init(_ postScriptName: String, weightClass: CGFloat) {
            self.postScriptName = postScriptName
            self.weightClass = weightClass
        }
    }

    /// Display name. Only used for diagnostics and the catalog.
    public let name: String

    /// Non-empty. A variable family has exactly one, standing in for the axis.
    public let faces: [Face]

    /// The `wght` axis range for a variable family; `nil` for a static one.
    public let weightAxis: ClosedRange<CGFloat>?

    /// The bundle holding the font files, registered on first use. `nil` for
    /// fonts the system or the app already provides.
    public let bundle: Bundle?

    public static func staticFamily(name: String, faces: [Face], bundle: Bundle? = nil) -> FontFamily {
        FontFamily(name: name, faces: faces, weightAxis: nil, bundle: bundle)
    }

    public static func variableFamily(
        name: String,
        postScriptName: String,
        weightClass: CGFloat,
        weightAxis: ClosedRange<CGFloat>,
        bundle: Bundle? = nil
    ) -> FontFamily {
        FontFamily(
            name: name,
            faces: [Face(postScriptName, weightClass: weightClass)],
            weightAxis: weightAxis,
            bundle: bundle
        )
    }

    private init(name: String, faces: [Face], weightAxis: ClosedRange<CGFloat>?, bundle: Bundle?) {
        precondition(!faces.isEmpty, "A FontFamily needs at least one face.")
        self.name = name
        self.faces = faces
        self.weightAxis = weightAxis
        self.bundle = bundle
    }

    public var isVariable: Bool { weightAxis != nil }

    /// Whether every face resolves.
    public var isAvailable: Bool {
        if let bundle { FontRegistry.register(bundle) }
        return faces.allSatisfy { FontRegistry.isAvailable($0.postScriptName) }
    }
}

// MARK: - Resolution

public extension FontFamily {

    /// The face nearest the requested weight. Ties go to the lighter face.
    func face(for weight: Font.Weight) -> Face {
        let target = weight.numericWeight
        return faces.min { a, b in
            let da = abs(a.weightClass - target)
            let db = abs(b.weightClass - target)
            return da == db ? a.weightClass < b.weightClass : da < db
        } ?? faces[0]
    }

    /// The font at an *already-scaled* point size, or `nil` if the face isn't
    /// available, so callers can fall back instead of rendering a substitute.
    func font(size: CGFloat, weight: Font.Weight) -> Font? {
        if let bundle { FontRegistry.register(bundle) }

        let face = face(for: weight)
        guard FontRegistry.isAvailable(face.postScriptName) else { return nil }

        guard let weightAxis else {
            return .custom(face.postScriptName, fixedSize: size)
        }

        // Without an explicit coordinate, a variable font renders at its
        // default instance for every weight.
        let coordinate = min(max(weight.numericWeight, weightAxis.lowerBound), weightAxis.upperBound)
        let descriptor = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: face.postScriptName,
            kCTFontVariationAttribute: [Self.weightAxisTag: coordinate],
        ] as CFDictionary)
        return Font(CTFontCreateWithFontDescriptor(descriptor, size, nil))
    }
}

extension FontFamily {
    /// Four-character code for the OpenType `wght` axis.
    static let weightAxisTag = 0x77_67_68_74  // 'w', 'g', 'h', 't'
}

public extension Font.Weight {
    /// The CSS / OS/2 number for this weight: matched against `usWeightClass`
    /// for a static family, fed straight to the `wght` axis for a variable one.
    var numericWeight: CGFloat {
        switch self {
        case .ultraLight: 100
        case .thin:       200
        case .light:      300
        case .medium:     500
        case .semibold:   600
        case .bold:       700
        case .heavy:      800
        case .black:      900
        default:          400
        }
    }
}
