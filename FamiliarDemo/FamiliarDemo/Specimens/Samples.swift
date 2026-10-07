//
//  Samples.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

// Served by `MockImageLoader.catalog`.
let samplePhoto = Artwork.Source.remote(URL(string: "mock://lake")!)
let slowPhoto = Artwork.Source.remote(URL(string: "mock://slow")!)
let loadingPhoto = Artwork.Source.remote(URL(string: "mock://loading")!)
let missingPhoto = Artwork.Source.remote(URL(string: "mock://missing")!)

let brandSwatches = BrandColor.all.map { ($0.name, Swatch.brand($0)) }

let accentSwatches: [(String, Swatch)] = [
    ("accent", .accent), ("positive", .positive), ("caution", .caution), ("signature", .signature), ("highlight", .highlight),
]
