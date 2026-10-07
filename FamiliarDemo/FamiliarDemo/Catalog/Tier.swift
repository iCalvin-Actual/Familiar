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
        case .atoms:        []
        case .molecules:    []
        case .organisms:    []
        }
    }
}
