import SwiftUI
import Testing
@testable import Familiar

@MainActor
struct LabelTests {

    @Test func defaultsToOneLine() {
        #expect(Familiar.Label(text: "Continue").lineLimit == 1)
        #expect(Familiar.Label(style: .text("Continue")).lineLimit == 1)
        #expect(Familiar.Label(text: "Share", systemIcon: "square.and.arrow.up").lineLimit == 1)
    }

    @Test func keepsItsInheritedForegroundByDefault() {
        #expect(Familiar.Label(text: "Continue").emphasis == nil)
        #expect(Familiar.Label(text: "Muted", emphasis: .secondary).emphasis == .secondary)
    }

    @Test func lineLimitCanBeRaisedOrRemoved() {
        #expect(Familiar.Label(text: "Wraps", lineLimit: 3).lineLimit == 3)
        #expect(Familiar.Label(text: "Wraps", lineLimit: nil).lineLimit == nil)
    }

    @Test func accessibilitySizesLiftTheLineLimit() {
        #expect(Familiar.Label.lineLimit(1, at: .xxxLarge) == 1)
        #expect(Familiar.Label.lineLimit(2, at: .accessibility1) == nil)
        #expect(Familiar.Label.lineLimit(nil, at: .large) == nil)
    }
}
