//
//  Label.swift
//  FamiliarDemo
//
//  Created by Calvin Chestnut on 9/29/26.
//

import SwiftUI
import Familiar

extension Specimen {
    static let label = Specimen(
        name: "Label",
        summary: "Text, an icon, or both, set in a type token.",
        variants: [
            Variant("Styles") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "Text only")
                    Label(systemIcon: "square.and.arrow.up")
                    Label(text: "Text and icon", systemIcon: "square.and.arrow.up")
                    Label(style: .textIcon("Catalog symbol", .symbol(.wordmark)))
                    Label(style: .textIcon("Loose file", .file("nextapp")))
                }
            },
            Variant("Sizes") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "title3", systemIcon: "star.fill", size: .title3)
                    Label(text: "body", systemIcon: "star.fill", size: .body)
                    Label(text: "body2", systemIcon: "star.fill", size: .body2)
                    Label(text: "caption", systemIcon: "star.fill", size: .caption)
                    Label(text: "custom(24) — fixed", systemIcon: "lock.fill", size: .custom(24))
                }
            },
            Variant("Emphasis") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "Primary", systemIcon: "star.fill", emphasis: .primary)
                    Label(text: "Secondary", systemIcon: "star.fill", emphasis: .secondary)
                    Label(text: "Tertiary", systemIcon: "star.fill", emphasis: .tertiary)
                    Label(text: "Accent", systemIcon: "star.fill", emphasis: .accent)
                }
            },
            Variant("Monospaced") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "code", size: .code)
                    Label(text: "codeSmall", size: .codeSmall)
                    Label(text: "annotation", size: .annotation)
                    Label(text: "annotationFixed — doesn't scale", size: .annotationFixed)
                }
            },
            Variant("Line limit") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "A long label that stays on one line by default", systemIcon: "text.alignleft")
                    Label(text: "A long label allowed two lines before it truncates", systemIcon: "text.alignleft", lineLimit: 2)
                    Label(text: "A long label with no limit wraps as far as it needs to", systemIcon: "text.alignleft", lineLimit: nil)
                }
            },
            Variant("Composed") {
                VStack(alignment: .leading, spacing: 8) {
                    Label(text: "NEW", size: .annotation)
                        .foregroundStyle(.swatch(.signature))
                    Label(text: "Familiar", size: .displayLarge)
                    Label(text: "Shared UI for the Workshop", systemIcon: "hammer.fill", size: .body2, emphasis: .secondary)
                    Label(text: "All checks passed", systemIcon: "checkmark.circle.fill", size: .caption)
                        .foregroundStyle(.swatch(.positive))
                }
                .displayFamily(.display)
            },
        ]
    )
}
