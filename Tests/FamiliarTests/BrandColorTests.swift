import SwiftUI
import Testing
@testable import Familiar

struct BrandColorTests {

    static let textColors = BrandColor.all.filter { $0 != .canvas && $0 != .signature }

    @Test(arguments: textColors, [ColorScheme.light, .dark])
    func textMeetsAA(_ brand: BrandColor, _ scheme: ColorScheme) {
        let ratio = contrast(brand.hex(for: scheme), BrandColor.canvas.hex(for: scheme))
        #expect(ratio >= 4.5, "\(brand.name) is \(ratio):1 on \(scheme) canvas")
    }

    @Test(arguments: BrandColor.all.filter { $0 != .canvas }, [ColorScheme.light, .dark])
    func increasedContrastMeetsAAA(_ brand: BrandColor, _ scheme: ColorScheme) {
        let canvas = BrandColor.canvas.hex(for: scheme, contrast: .increased)
        let ratio = contrast(brand.hex(for: scheme, contrast: .increased), canvas)
        #expect(ratio >= 7, "\(brand.name) is \(ratio):1 on \(scheme) canvas under Increase Contrast")
    }

    @Test func highContrastCutsFallBackToTheirScheme() {
        let brand = BrandColor(name: "test", light: 0x111111, dark: 0xEEEEEE, lightHighContrast: 0x000000)
        #expect(brand.hex(for: .light, contrast: .increased) == 0x000000)
        #expect(brand.hex(for: .dark, contrast: .increased) == 0xEEEEEE)
        #expect(brand.hex(for: .light) == 0x111111)
    }

    private func contrast(_ a: Hex, _ b: Hex) -> Double {
        let (hi, lo) = (max(luminance(a), luminance(b)), min(luminance(a), luminance(b)))
        return (hi + 0.05) / (lo + 0.05)
    }

    private func luminance(_ hex: Hex) -> Double {
        let channels = [16, 8, 0].map { Double((hex.rgb >> $0) & 0xFF) / 255 }
            .map { $0 <= 0.03928 ? $0 / 12.92 : pow(($0 + 0.055) / 1.055, 2.4) }
        return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]
    }
}
