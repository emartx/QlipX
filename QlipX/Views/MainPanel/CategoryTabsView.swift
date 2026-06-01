//
//  CategoryTabsView.swift
//  QlipX
//
//  Created by Codex on 01/06/2026.
//

import SwiftUI

struct CategoryTabsView: View {
    @EnvironmentObject private var store: QlipXStore

    private var allLabel: String {
        String(localized: "mainPanel.category.all", defaultValue: "All")
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tabButton(title: allLabel, isSelected: store.selectedCategoryID == nil) {
                    store.selectCategory(id: nil)
                }

                ForEach(store.categories) { category in
                    tabButton(
                        title: category.name,
                        isSelected: store.selectedCategoryID == category.id
                    ) {
                        store.selectCategory(id: category.id)
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityElement(children: .contain)
    }

    private func tabButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.primary.opacity(0.14) : Color.clear)
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.primary.opacity(0.18) : Color.secondary.opacity(0.16),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Category Tabs") {
    CategoryTabsView()
        .environmentObject(
            QlipXStore(
                categories: [
                    Category(name: "Network", colorIndex: 0),
                    Category(name: "Links", colorIndex: 1),
                    Category(name: "Commands", colorIndex: 2)
                ]
            )
        )
}

#Preview("Category Tabs Selected") {
    let selectedCategory = Category(name: "Network", colorIndex: 0)

    return CategoryTabsView()
        .environmentObject(
            QlipXStore(
                categories: [
                    selectedCategory,
                    Category(name: "Links", colorIndex: 1)
                ],
                selectedCategoryID: selectedCategory.id
            )
        )
}
