//
//  MoveItemsSheet.swift
//  QlipX
//
//  Created by Codex on 02/06/2026.
//

import SwiftUI

struct MoveItemsSheet: View {
    let category: Category
    @Binding var destinationCategoryID: UUID?
    let cancelLabel: String
    let moveItemsLabel: String
    let moveItemsPrompt: String
    let categories: [Category]
    let onConfirm: (UUID) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(moveItemsLabel)
                .font(.system(size: 15, weight: .semibold))

            Text(category.name)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Picker(moveItemsPrompt, selection: $destinationCategoryID) {
                ForEach(categories) { category in
                    Text(category.name)
                        .tag(Optional(category.id))
                }
            }
            .pickerStyle(.menu)

            HStack(spacing: 8) {
                Spacer()

                Button(cancelLabel) {
                    dismiss()
                }

                Button(moveItemsLabel) {
                    guard let destinationCategoryID else {
                        return
                    }

                    onConfirm(destinationCategoryID)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(destinationCategoryID == nil)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}
