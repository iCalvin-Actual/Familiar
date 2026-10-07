//
//  Bundle+Familiar.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import Foundation

public extension Bundle {
    /// This package's resource bundle: fonts, images, licences.
    ///
    /// `Bundle.module` always means the *current* target's bundle, so tests,
    /// the catalog and other targets reach Familiar's resources through this
    /// instead.
    static let familiar: Bundle = .module
}
