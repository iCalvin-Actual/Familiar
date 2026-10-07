import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct LabeledImageTests {

    @Test func defaultsToMedium() {
        let image = LabeledImage(.file("nextapp"), title: "Next App")
        #expect(image.title == "Next App")
        #expect(image.size == .medium)
    }
}
