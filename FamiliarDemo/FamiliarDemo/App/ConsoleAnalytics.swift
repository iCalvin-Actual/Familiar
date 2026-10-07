//
//  ConsoleAnalytics.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/30/26.
//

import Familiar
import os

/// The catalog's analytics vendor: the console.
struct ConsoleAnalytics: Analytics {
    private let logger = Logger(subsystem: "FamiliarDemo", category: "Analytics")

    func track(_ event: AnalyticsEvent) {
        logger.info("\(event.name, privacy: .public) \(event.properties, privacy: .public)")
    }
}
