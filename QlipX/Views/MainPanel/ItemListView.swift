//
//  ItemListView.swift
//  QlipX
//
//  Created by Codex on 01/06/2026.
//

import SwiftUI

struct ItemListView: View {
    @EnvironmentObject private var store: QlipXStore
    @FocusState private var isListFocused: Bool

    private var emptyStateLabel: String {
        if store.isSearchActive {
            return String(localized: "alert.noResults", defaultValue: "No results")
        }

        return String(localized: "mainPanel.emptyState", defaultValue: "No snippets yet.")
    }

    var body: some View {
        Group {
            if store.displayedCategories.isEmpty {
                ContentUnavailableView {
                    Text(emptyStateLabel)
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .focusable()
                .focused($isListFocused)
            } else {
                List {
                    ForEach(store.displayedCategories) { category in
                        CategorySectionView(category: category)
                    }
                }
                .focusable()
                .focused($isListFocused)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
        }
        .onChange(of: store.listFocusRequestID) { _, _ in
            isListFocused = true
        }
    }
}

private struct CategorySectionView: View {
    @EnvironmentObject private var store: QlipXStore

    let category: Category

    private var itemCountLabel: String {
        String(localized: "mainPanel.category.itemCount", defaultValue: "items")
    }

    var body: some View {
        Section {
            if category.isExpanded {
                ForEach(category.items) { item in
                    ItemRowView(item: item, categoryID: category.id)
                        .moveDisabled(store.isSearchActive)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 8))
                        .listRowSeparator(.hidden)
                }
                .onMove { source, destination in
                    guard !store.isSearchActive else {
                        return
                    }

                    store.moveItems(
                        inCategoryID: category.id,
                        fromOffsets: source,
                        toOffset: destination
                    )
                }
            }
        } header: {
            Button {
                store.toggleCategoryExpansion(id: category.id)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: category.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 10)

                    Circle()
                        .fill(ColorPalette.color(for: category.colorIndex))
                        .frame(width: 8, height: 8)

                    Text(category.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)

                    Spacer(minLength: 8)

                    Text("\(category.items.count) \(itemCountLabel)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ItemRowView: View {
    @EnvironmentObject private var store: QlipXStore

    let item: Item
    let categoryID: UUID

    @State private var isCopied = false
    @State private var isShowingDeleteConfirmation = false
    @State private var resetTask: Task<Void, Never>?

    private var copyLabel: String {
        String(localized: "button.copy", defaultValue: "Copy")
    }

    private var copiedLabel: String {
        String(localized: "button.copied", defaultValue: "Copied")
    }

    private var editLabel: String {
        String(localized: "button.edit", defaultValue: "Edit")
    }

    private var deleteLabel: String {
        String(localized: "button.delete", defaultValue: "Delete")
    }

    private var confirmDeleteMessage: String {
        String(localized: "alert.confirmDelete", defaultValue: "Are you sure you want to delete this item?")
    }

    private var contentFont: Font {
        if MonospaceDetector.isMonospace(item.content) {
            return .system(size: 12, weight: .regular, design: .monospaced)
        }

        return .system(size: 12)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let label = item.label, !label.isEmpty {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Text(item.content)
                    .font(contentFont)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: copyItem) {
                Text(isCopied ? "✓ \(copiedLabel)" : copyLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isCopied ? Color.green : Color.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background {
                        Capsule(style: .continuous)
                            .fill(isCopied ? Color.green.opacity(0.14) : Color.primary.opacity(0.08))
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .contextMenu {
            Button(editLabel) {
                store.beginEditingItem(id: item.id, categoryID: categoryID)
            }

            Button(deleteLabel, role: .destructive) {
                isShowingDeleteConfirmation = true
            }
        }
        .alert(deleteLabel, isPresented: $isShowingDeleteConfirmation) {
            Button(cancelLabel, role: .cancel) {}
            Button(deleteLabel, role: .destructive) {
                store.removeItem(id: item.id, fromCategoryID: categoryID)
            }
        } message: {
            Text(confirmDeleteMessage)
        }
        .onDisappear {
            resetTask?.cancel()
            resetTask = nil
        }
    }

    private var cancelLabel: String {
        String(localized: "button.cancel", defaultValue: "Cancel")
    }

    private func copyItem() {
        ClipboardManager.copy(item.content)
        isCopied = true

        resetTask?.cancel()
        resetTask = Task {
            try? await Task.sleep(for: .seconds(1.4))

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                isCopied = false
            }
        }
    }
}

#Preview("Item List") {
    ItemListView()
        .environmentObject(
            QlipXStore(
                categories: [
                    Category(
                        name: "Network",
                        colorIndex: 0,
                        items: [
                            Item(content: "192.168.1.10", label: "Local", order: 0),
                            Item(content: "10.0.0.5", label: "Staging", order: 1)
                        ]
                    ),
                    Category(
                        name: "Links",
                        colorIndex: 1,
                        items: [
                            Item(content: "https://example.com/docs", label: "Docs", order: 0),
                            Item(content: "https://example.com/status", order: 1)
                        ],
                        isExpanded: false
                    )
                ]
            )
        )
}
