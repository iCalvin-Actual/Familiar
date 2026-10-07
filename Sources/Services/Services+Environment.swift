//
//  Services+Environment.swift
//  Familiar
//
//  Created by Calvin Chestnut on 9/30/26.
//

import SwiftUI

extension EnvironmentValues {
    @Entry public var analytics: any Analytics = NoAnalytics()
    @Entry public var featureGate: any FeatureGate = StaticFeatureGate()
    @Entry public var imageLoader: any ImageLoader = URLSessionImageLoader()
    /// Set by `tracksTaps(_:)`; Button and Chip track it when tapped.
    @Entry var tapEvent: AnalyticsEvent? = nil
}

public extension View {
    func analytics(_ analytics: some Analytics) -> some View {
        environment(\.analytics, analytics)
    }

    func featureGate(_ gate: some FeatureGate) -> some View {
        environment(\.featureGate, gate)
    }

    func imageLoader(_ loader: some ImageLoader) -> some View {
        environment(\.imageLoader, loader)
    }

    /// Shows this view only while `flag` is on.
    func gated(by flag: FeatureFlag) -> some View {
        modifier(Gated(flag: flag))
    }

    /// Tracks `event` each time this view appears.
    func tracksAppearance(_ event: AnalyticsEvent) -> some View {
        modifier(TracksAppearance(event: event))
    }

    /// Tracks `event` each time a Button or Chip inside this view is tapped.
    func tracksTaps(_ event: AnalyticsEvent) -> some View {
        environment(\.tapEvent, event)
    }
}

private struct Gated: ViewModifier {
    @Environment(\.featureGate) private var gate
    let flag: FeatureFlag

    func body(content: Content) -> some View {
        if gate.isEnabled(flag) {
            content
        }
    }
}

private struct TracksAppearance: ViewModifier {
    @Environment(\.analytics) private var analytics
    let event: AnalyticsEvent

    func body(content: Content) -> some View {
        content.onAppear { analytics.track(event) }
    }
}
