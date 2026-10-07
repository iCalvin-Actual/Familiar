//
//  Samples.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

/// What VoiceOver reads for the sample photo. Loading and failure arrive as
/// its value, so the label stays the same in every state.
let lakeDescription = "A lake below snowy mountains"

// Served by `MockImageLoader.catalog`.
let samplePhoto = Artwork.Source.remote(URL(string: "mock://lake")!)
let slowPhoto = Artwork.Source.remote(URL(string: "mock://slow")!)
let loadingPhoto = Artwork.Source.remote(URL(string: "mock://loading")!)
let missingPhoto = Artwork.Source.remote(URL(string: "mock://missing")!)

let brandSwatches = BrandColor.all.map { ($0.name, Swatch.brand($0)) }

let accentSwatches: [(String, Swatch)] = [
    ("accent", .accent), ("positive", .positive), ("caution", .caution), ("signature", .signature), ("highlight", .highlight),
]
