//
//  LoadingIndicator.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let loadingIndicator = Specimen(
        name: "LoadingIndicator",
        summary: "A spinner sized by the type scope it sits in.",
        variants: [
            Variant("Sizes") {
                HStack(alignment: .top, spacing: 16) {
                    ForEach([Typography.xSmall, .small, .medium, .xLarge, .xxLarge], id: \.self) { size in
                        LoadingIndicator(size: size)
                    }
                }
            },
            Variant("Inherits its scope") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([("title3", Typography.title3), ("body", .body), ("caption", .caption)], id: \.0) { name, size in
                        HStack(alignment: .top, spacing: 8) {
                            LoadingIndicator()
                            Text(name)
                        }
                        .typography(size)
                    }
                }
            },
        ]
    )
}
