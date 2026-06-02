//
//  CategoryTabsView.swift
//  QlipX
//
//  Created by Codex on 01/06/2026.
//

import SwiftUI

struct CategoryTabsView: View {
    @EnvironmentObject private var store: QlipXStore
    @FocusState private var focusedCategoryID: UUID?

    @State private var renamingCategoryID: UUID?
    @State private var proposedCategoryName = ""
    @State private var pendingDeleteCategory: Category?
    @State private var isShowingDeleteAlert = false
    @State private var isShowingMoveSheet = false
    @State private var moveDestinationCategoryID: UUID?

    private var allLabel: String {
        String(localized: "mainPanel.category.all", defaultValue: "All")
    }

    private var renameLabel: String {
        String(localized: "button.rename", defaultValue: "Rename")
    }

    private var deleteLabel: String {
        String(localized: "button.delete", defaultValue: "Delete")
    }

    private var cancelLabel: String {
        String(localized: "button.cancel", defaultValue: "Cancel")
    }

    private var deleteItemsLabel: String {
        String(localized: "category.deleteItems", defaultValue: "Delete all items")
    }

    private var moveItemsLabel: String {
        String(localized: "category.moveItems", defaultValue: "Move items to…")
    }

    private var deleteLastCategoryLabel: String {
        String(localized: "category.deleteLastDisabled", defaultValue: "You can’t delete the last remaining category.")
    }

    private var moveItemsPrompt: String {
        String(localized: "category.movePrompt", defaultValue: "Move items to")
    }

    private var deleteCategoryMessage: String {
        if let pendingDeleteCategory, pendingDeleteCategory.items.isEmpty {
            return String(
                localized: "category.deleteEmptyMessage",
                defaultValue: "Delete this empty category?"
            )
        }

        return String(
            localized: "category.deleteMessage",
            defaultValue: "What would you like to do with the items in this category?"
        )
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tabButton(title: allLabel, isSelected: store.selectedCategoryID == nil) {
                    store.selectCategory(id: nil)
                }

                ForEach(store.categories) { category in
                    categoryTab(for: category)
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityElement(children: .contain)
        .alert(deleteLabel, isPresented: $isShowingDeleteAlert, presenting: pendingDeleteCategory) { category in
            if store.categories.count <= 1 {
                Button(cancelLabel, role: .cancel) {
                    pendingDeleteCategory = nil
                }
            } else if category.items.isEmpty {
                Button(cancelLabel, role: .cancel) {
                    pendingDeleteCategory = nil
                }

                Button(deleteLabel, role: .destructive) {
                    store.deleteCategoryAndItems(id: category.id)
                    pendingDeleteCategory = nil
                }
            } else {
                Button(cancelLabel, role: .cancel) {
                    pendingDeleteCategory = nil
                }

                Button(deleteItemsLabel, role: .destructive) {
                    store.deleteCategoryAndItems(id: category.id)
                    pendingDeleteCategory = nil
                }

                Button(moveItemsLabel) {
                    moveDestinationCategoryID = store.categories.first { $0.id != category.id }?.id
                    isShowingMoveSheet = true
                }
            }
        } message: { category in
            Text(store.categories.count <= 1 ? deleteLastCategoryLabel : deleteCategoryMessage)
        }
        .sheet(isPresented: $isShowingMoveSheet, onDismiss: {
            pendingDeleteCategory = nil
        }) {
            if let pendingDeleteCategory {
                MoveItemsSheet(
                    category: pendingDeleteCategory,
                    destinationCategoryID: $moveDestinationCategoryID,
                    cancelLabel: cancelLabel,
                    moveItemsLabel: moveItemsLabel,
                    moveItemsPrompt: moveItemsPrompt,
                    categories: store.categories.filter { $0.id != pendingDeleteCategory.id }
                ) { destinationCategoryID in
                    store.moveItemsAndDeleteCategory(
                        id: pendingDeleteCategory.id,
                        destinationCategoryID: destinationCategoryID
                    )
                    isShowingMoveSheet = false
                    self.pendingDeleteCategory = nil
                }
            }
        }
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

    @ViewBuilder
    private func categoryTab(for category: Category) -> some View {
        if renamingCategoryID == category.id {
            TextField(category.name, text: $proposedCategoryName)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .frame(minWidth: 72)
                .background {
                    Capsule(style: .continuous)
                        .fill(Color.primary.opacity(0.14))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.18), lineWidth: 1)
                }
                .focused($focusedCategoryID, equals: category.id)
                .onSubmit {
                    commitRename(for: category.id)
                }
                .onExitCommand {
                    cancelRename()
                }
                .onAppear {
                    DispatchQueue.main.async {
                        focusedCategoryID = category.id
                    }
                }
        } else {
            tabButton(
                title: category.name,
                isSelected: store.selectedCategoryID == category.id
            ) {
                store.selectCategory(id: category.id)
            }
            .contextMenu {
                Button(renameLabel) {
                    beginRename(for: category)
                }

                Button(deleteLabel, role: .destructive) {
                    pendingDeleteCategory = category
                    isShowingDeleteAlert = true
                }
                .disabled(store.categories.count <= 1)
            }
        }
    }

    private func beginRename(for category: Category) {
        pendingDeleteCategory = nil
        renamingCategoryID = category.id
        proposedCategoryName = category.name
    }

    private func commitRename(for categoryID: UUID) {
        store.renameCategory(id: categoryID, to: proposedCategoryName)
        cancelRename()
    }

    private func cancelRename() {
        renamingCategoryID = nil
        proposedCategoryName = ""
        focusedCategoryID = nil
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
