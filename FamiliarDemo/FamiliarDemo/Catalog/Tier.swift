//
//  Tier.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI

enum Tier: String, CaseIterable, Identifiable {
    case atoms, molecules, organisms

    var id: Self { self }

    var title: String { rawValue.capitalized }

    var specimens: [Specimen] {
        switch self {
        case .atoms:        [.icon, .label, .artwork, .loadingIndicator]
        case .molecules:    [.button, .chip, .rating]
        // icc-tier
        case .organisms:    []
        }
    }
}
