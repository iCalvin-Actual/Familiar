import Synchronization
import SwiftUI
import Testing
@testable import Familiar

private final class RecordingAnalytics: Analytics {
    let events = Mutex<[AnalyticsEvent]>([])

    func track(_ event: AnalyticsEvent) {
        events.withLock { $0.append(event) }
    }
}

@MainActor
struct ServicesTests {

    @Test func staticGateIsOffByDefault() {
        #expect(StaticFeatureGate().isEnabled("anything") == false)
    }

    @Test func staticGateEnablesOnlyItsFlags() {
        let gate = StaticFeatureGate(enabled: ["new-badge"])
        #expect(gate.isEnabled("new-badge"))
        #expect(gate.isEnabled(FeatureFlag("unshipped")) == false)
    }

    @Test func environmentDefaultsNeedNoSetup() {
        let environment = EnvironmentValues()
        #expect(environment.featureGate.isEnabled("new-badge") == false)
        environment.analytics.track(AnalyticsEvent("ignored"))
    }

    @Test func eventsReachTheInjectedAnalytics() {
        let recorder = RecordingAnalytics()
        var environment = EnvironmentValues()
        environment.analytics = recorder

        environment.analytics.track(AnalyticsEvent("chip_selected", properties: ["label": "Tea"]))

        #expect(recorder.events.withLock { $0 } == [AnalyticsEvent("chip_selected", properties: ["label": "Tea"])])
    }
}
