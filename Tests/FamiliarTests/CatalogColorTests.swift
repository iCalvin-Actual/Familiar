import SwiftUI
import Testing
@testable import Familiar

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct CatalogColorTests {

    /// Catches a swatch declared without its colour set, or a name typo —
    /// `Color(_:bundle:)` would otherwise draw clear without complaint.
    @Test(arguments: Swatch.catalog)
    func everyCatalogColorExists(_ swatch: Swatch) {
        guard case .bundle(let name, let bundle) = swatch else {
            Issue.record("\(swatch) isn't a catalog colour")
            return
        }
        #if canImport(AppKit)
        #expect(NSColor(named: name, bundle: bundle) != nil, "No colour set named \(name)")
        #elseif canImport(UIKit)
        #expect(UIColor(named: name, in: bundle, compatibleWith: nil) != nil, "No colour set named \(name)")
        #endif
    }

    #if canImport(AppKit)
    /// The dark variants survive compilation into `Assets.car`. (Increase
    /// Contrast variants can't be checked this way: `NSAppearance(named:)`
    /// won't produce a real high-contrast appearance.)
    @Test(arguments: Swatch.catalog)
    func darkVariantDiffers(_ swatch: Swatch) throws {
        guard case .bundle(let name, let bundle) = swatch else { return }
        let color = try #require(NSColor(named: name, bundle: bundle))
        #expect(srgb(color, in: .aqua) != srgb(color, in: .darkAqua))
    }

    private func srgb(_ color: NSColor, in name: NSAppearance.Name) -> [CGFloat] {
        var components: [CGFloat] = []
        NSAppearance(named: name)?.performAsCurrentDrawingAppearance {
            let resolved = color.usingColorSpace(.sRGB)
            components = [resolved?.redComponent, resolved?.greenComponent, resolved?.blueComponent].compactMap { $0 }
        }
        return components
    }
    #endif
}
