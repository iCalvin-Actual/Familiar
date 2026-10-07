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

    @Test func disabledWinsOverEveryInteraction() {
        #expect(Familiar.Button.Style.opacity(isEnabled: false, isPressed: true, isHovered: true) == 0.4)
    }

    @Test func pressWinsOverHover() {
        #expect(Familiar.Button.Style.opacity(isEnabled: true, isPressed: true, isHovered: true) == 0.7)
        #expect(Familiar.Button.Style.opacity(isEnabled: true, isPressed: false, isHovered: true) == 0.8)
        #expect(Familiar.Button.Style.opacity(isEnabled: true, isPressed: false, isHovered: false) == 1)
    }

    @Test func textAndSystemIconBuildsTheLabel() {
        let button = Familiar.Button("Share", systemIcon: "square.and.arrow.up") {}
        #expect(button.label == .textIcon("Share", .system("square.and.arrow.up")))
    }
}
