import Testing
@testable import Familiar

struct InteractionTests {

    @Test func unforcedFollowsTheLiveState() {
        let live = Interaction.State(isHovered: true, isPressed: true, isFocused: true)
        #expect(Interaction.resolve(forced: nil, live: live) == live)
        #expect(Interaction.resolve(forced: nil, live: .init()) == .init())
    }

    @Test(arguments: Interaction.allCases)
    func forcedPinsExactlyOneState(_ forced: Interaction) {
        let state = Interaction.resolve(forced: forced, live: .init(isHovered: true, isPressed: true, isFocused: true))
        #expect(state.isHovered == (forced == .hovered))
        #expect(state.isPressed == (forced == .pressed))
        #expect(state.isFocused == (forced == .focused))
    }

    @Test func minimumTapTargetMeetsTheGuideline() {
        #expect(Spacing.minimumTapTarget >= 44)
    }
}
