import SwiftUI
import Testing
@testable import Familiar

struct LoadingIndicatorTests {

    @Test func defaultsToInheritingTheScope() {
        #expect(LoadingIndicator().typography == nil)
    }

    @Test func followsTheTypeRamp() {
        #expect(LoadingIndicator.controlSize(for: Typography.xSmall.size) == .mini)
        #expect(LoadingIndicator.controlSize(for: Typography.small.size) == .small)
        #expect(LoadingIndicator.controlSize(for: Typography.medium.size) == .regular)
        #expect(LoadingIndicator.controlSize(for: Typography.xLarge.size) == .large)
        #expect(LoadingIndicator.controlSize(for: Typography.xxLarge.size) == .extraLarge)
    }

    @MainActor @Test func keepsTheSystemLabelByDefault() {
        #expect(LoadingIndicator().label == nil)
        #expect(LoadingIndicator(label: "Loading photos").label == "Loading photos")
    }
}
