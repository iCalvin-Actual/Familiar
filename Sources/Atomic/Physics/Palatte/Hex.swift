//
//  Hex.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import Foundation
import SwiftUI


public struct Hex: Equatable, Hashable, Sendable, ExpressibleByIntegerLiteral, CustomStringConvertible {

    /// Packed `0xRRGGBB`. Alpha is kept separate — it's a compositing
    /// decision, not part of the colour's identity
    public let rgb: UInt32

    public let opacity: Double

    public init(_ rgb: UInt32, opacity: Double = 1) {
        self.rgb = rgb & 0xFF_FF_FF
        self.opacity = opacity
    }

    public init(integerLiteral value: UInt32) {
        self.init(value)
    }

    /// Parses `"#3B5BDB"`, `"3B5BDB"`, or the 8-digit `"#3B5BDBFF"` form.
    /// Failable rather than defaulting to a colour
    public init?(_ string: String) {
        var text = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }

        guard let value = UInt32(text, radix: 16) else { return nil }

        switch text.count {
        case 6:
            self.init(value)
        case 8:
            self.init(value >> 8, opacity: Double(value & 0xFF) / 255)
        default:
            return nil
        }
    }

    public var color: Color {
        Color(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// The same colour at a different alpha, for scrims and hairlines.
    public func opacity(_ opacity: Double) -> Hex {
        Hex(rgb, opacity: opacity)
    }

    /// `#RRGGBB`, for the catalog and for handing a value back to a designer.
    /// Translucent values use `#RRGGBBAA` so the string parses back to the same `Hex`.
    public var description: String {
        guard opacity < 1 else { return String(format: "#%06X", rgb) }
        let alpha = UInt32((min(max(opacity, 0), 1) * 255).rounded())
        return String(format: "#%06X%02X", rgb, alpha)
    }
}
