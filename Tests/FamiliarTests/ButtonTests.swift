import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct ButtonTests {

    @Test func destructiveDrawsInCritical() {
        #expect(Familiar.Button.Style.swatch(for: .destructive, accent: .accent) == .critical)
    }

    @Test(arguments: [nil, ButtonRole.cancel])
    func otherRolesFollowTheAccent(_ role: ButtonRole?) {
        #expect(Familiar.Button.Style.swatch(for: role, accent: .accent) == .accent)
        #expect(Familiar.Button.Style.swatch(for: role, accent: .highlight) == .highlight)
    }

    @Test func defaultsToMatteCTA() {
        let button = Familiar.Button("Continue") {}
        #expect(button.prominence == .matte)
        #expect(button.typography == .cta)
        #expect(button.label == .text("Continue"))
        #expect(button.width == .flexible)

        let style = Familiar.Button.Style()
        #expect(style.prominence == .matte)
        #expect(style.typography == .cta)
        #expect(style.width == .flexible)
    }

    @Test func disabledWinsOverPress() {
        #expect(Familiar.Button.Style.opacity(isEnabled: false, isPressed: true) == 0.4)
    }

    @Test func pressDims() {
        #expect(Familiar.Button.Style.opacity(isEnabled: true, isPressed: true) == 0.7)
        #expect(Familiar.Button.Style.opacity(isEnabled: true, isPressed: false) == 1)
    }

    @Test func textAndSystemIconBuildsTheLabel() {
        let button = Familiar.Button("Share", systemIcon: "square.and.arrow.up") {}
        #expect(button.label == .textIcon("Share", .system("square.and.arrow.up")))
    }
}
