//
//  Samples.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

let brandSwatches = BrandColor.all.map { ($0.name, Swatch.brand($0)) }
