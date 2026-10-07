//
//  FontRegistry.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/28/26.
//

import CoreText
import Foundation
import os
import Synchronization

/// Registers the font files in a bundle with Core Text, once per bundle.
///
/// A package has no Info.plist to declare `UIAppFonts` in, so fonts shipped
/// in `Bundle.module` have to be registered at runtime. `.otf`, `.ttf` and
/// `.ttc` all register the same way, static or variable.
public enum FontRegistry {

    private static let registered = Mutex<[Bundle: Set<String>]>([:])

    private static let logger = Logger(subsystem: "Familiar", category: "FontRegistry")

    /// Registers every font file in `bundle` and returns the PostScript names
    /// it contributed. Safe to call repeatedly; only the first call does work.
    @discardableResult
    public static func register(_ bundle: Bundle) -> Set<String> {
        registered.withLock { cache in
            if let names = cache[bundle] { return names }
            let names = registerFonts(in: bundle)
            cache[bundle] = names
            return names
        }
    }

    /// Whether Core Text resolves `postScriptName` to that exact font.
    public static func isAvailable(_ postScriptName: String) -> Bool {
        let font = CTFontCreateWithName(postScriptName as CFString, 12, nil)
        return CTFontCopyPostScriptName(font) as String == postScriptName
    }

    private static func registerFonts(in bundle: Bundle) -> Set<String> {
        let urls = ["otf", "ttf", "ttc"].flatMap { ext in
            (bundle.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [])
                + (bundle.urls(forResourcesWithExtension: ext, subdirectory: "Fonts") ?? [])
        }

        var names: Set<String> = []
        for url in urls {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                let failure = error?.takeRetainedValue()
                let alreadyRegistered = failure.map {
                    CFErrorGetCode($0) == CTFontManagerError.alreadyRegistered.rawValue
                } ?? false

                // Previews reload the bundle, so re-registering is expected.
                guard alreadyRegistered else {
                    let reason = failure.map { String(describing: $0) } ?? "unknown error"
                    logger.error("Font registration failed for \(url.lastPathComponent, privacy: .public): \(reason, privacy: .public)")
                    continue
                }
            }

            // Read the names out of the file rather than assuming them.
            if let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor] {
                names.formUnion(descriptors.compactMap {
                    CTFontDescriptorCopyAttribute($0, kCTFontNameAttribute) as? String
                })
            }
        }
        return names
    }
}
