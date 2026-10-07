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
                        .spokenCaption()
                    Label(systemIcon: "square.and.arrow.up", label: "Share")
                        .spokenCaption()
                    Label(text: "Text and icon", systemIcon: "square.and.arrow.up")
                        .spokenCaption()
                    Label(style: .textIcon("Catalog symbol", .symbol(.wordmark)))
                        .spokenCaption()
                    Label(style: .textIcon("Loose file", .file("nextapp")))
                        .spokenCaption()
                }
            },
            Variant("Sizes") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "title3", systemIcon: "star.fill", size: .title3)
                        .spokenCaption()
                    Label(text: "body", systemIcon: "star.fill", size: .body)
                        .spokenCaption()
                    Label(text: "body2", systemIcon: "star.fill", size: .body2)
                        .spokenCaption()
                    Label(text: "caption", systemIcon: "star.fill", size: .caption)
                        .spokenCaption()
                    Label(text: "custom(24) — fixed", systemIcon: "lock.fill", size: .custom(24))
                        .spokenCaption()
                }
            },
            Variant("Emphasis") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "Primary", systemIcon: "star.fill", emphasis: .primary)
                        .spokenCaption()
                    Label(text: "Secondary", systemIcon: "star.fill", emphasis: .secondary)
                        .spokenCaption()
                    Label(text: "Tertiary", systemIcon: "star.fill", emphasis: .tertiary)
                        .spokenCaption()
                    Label(text: "Accent", systemIcon: "star.fill", emphasis: .accent)
                        .spokenCaption()
                }
            },
            Variant("Monospaced") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "code", size: .code)
                        .spokenCaption()
                    Label(text: "codeSmall", size: .codeSmall)
                        .spokenCaption()
                    Label(text: "annotation", size: .annotation)
                        .spokenCaption()
                    Label(text: "annotationFixed — doesn't scale", size: .annotationFixed)
                        .spokenCaption()
                }
            },
            Variant("Line limit") {
                VStack(alignment: .leading, spacing: 12) {
                    Label(text: "A long label that stays on one line by default", systemIcon: "text.alignleft")
                        .spokenCaption()
                    Label(text: "A long label allowed two lines before it truncates", systemIcon: "text.alignleft", lineLimit: 2)
                        .spokenCaption()
                    Label(text: "A long label with no limit wraps as far as it needs to", systemIcon: "text.alignleft", lineLimit: nil)
                        .spokenCaption()
                }
            },
            Variant("Composed") {
                VStack(alignment: .leading, spacing: 8) {
                    Label(text: "NEW", size: .annotation)
                        .spokenCaption()
                        .foregroundStyle(.swatch(.signature))
                    Label(text: "Familiar", size: .displayLarge)
                        .spokenCaption()
                    Label(text: "Shared UI for the Workshop", systemIcon: "hammer.fill", size: .body2, emphasis: .secondary)
                        .spokenCaption()
                    Label(text: "All checks passed", systemIcon: "checkmark.circle.fill", size: .caption)
                        .spokenCaption()
                        .foregroundStyle(.swatch(.positive))
                }
                .displayFamily(.display)
            },
        ]
    )
}
