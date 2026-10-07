//
//  URL+Familiar.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import Foundation

/// Loose image files in `Resources/Images`, the drop-in alternative to the
/// asset catalog beside them: no image set, no enum case, just the file.
///
/// Processing flattens them into the root of `Bundle.familiar`, so they're
/// found by extension there. Only bitmap formats: `UIImage` can't read a
/// loose PDF or SVG, so vectors belong in the catalog.
nonisolated extension URL {

    /// The formats a loose image can use.
    static let familiarImageExtensions = ["png", "jpg", "jpeg", "heic"]

    /// Every loose image bundled from `Resources/Images`, sorted by name.
    static let familiarImages: [URL] = familiarImageExtensions
        .flatMap { Bundle.familiar.urls(forResourcesWithExtension: $0, subdirectory: nil) ?? [] }
        .sorted { $0.familiarImageName < $1.familiarImageName }

    /// The loose image with this name, given without its extension.
    static func familiarImage(named name: String) -> URL? {
        familiarImageExtensions.lazy.compactMap {
            Bundle.familiar.url(forResource: name, withExtension: $0)
        }.first
    }

    /// The name `Icon.Source.file(_:)` takes: the filename without extension.
    var familiarImageName: String {
        deletingPathExtension().lastPathComponent
    }
}
