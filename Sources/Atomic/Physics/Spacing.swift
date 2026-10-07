//
//  Spacing.swift
//  Familiar
//
//  Created by Calvin Chestnut on 10/3/26.
//

import CoreGraphics

/// Fixed gaps between and around components. Padding inside a component
/// scales with its type instead, from `typographyPointSize`.
public enum Spacing {
    public static let xxSmall: CGFloat = 2
    public static let xSmall: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 16
    public static let xLarge: CGFloat = 24

    /// The smallest a control's hit area may be, in either direction.
    public static let minimumTapTarget: CGFloat = 44
}
