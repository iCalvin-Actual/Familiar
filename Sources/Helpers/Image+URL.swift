//
//  Image+URL.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

nonisolated extension Image {

    /// Decodes an image file by URL, or `nil` if it won't decode.
    ///
    /// `Image(_:bundle:)` only searches asset catalogs reliably, so loose
    /// files go through the platform image type instead.
    init?(contentsOf url: URL) {
        #if canImport(UIKit)
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        self.init(uiImage: image)
        #elseif canImport(AppKit)
        guard let image = NSImage(contentsOf: url) else { return nil }
        self.init(nsImage: image)
        #endif
    }

    /// Decodes image data, such as a download, or `nil` if it won't decode.
    init?(data: Data) {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        self.init(uiImage: image)
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        self.init(nsImage: image)
        #endif
    }
}
