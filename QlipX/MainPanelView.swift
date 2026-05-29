//
//  ContentView.swift
//  QlipX
//
//  Created by Seyed Emad Armoun on 15/05/2026.
//

import SwiftUI

struct MainPanelView: View {
    @EnvironmentObject private var store: QlipXStore

    private var title: String {
        String(localized: "app.title", defaultValue: "QlipX")
    }

    private var itemCountLabel: String {
        String(localized: "mainPanel.itemCount", defaultValue: "items")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))

                HStack(spacing: 6) {
                    Text("\(store.filteredItems.count)")
                    Text(itemCountLabel)
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }

            CategoryTabsView()

            ItemListView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(16)
        .frame(
            minWidth: 280,
            idealWidth: 320,
            maxWidth: .infinity,
            minHeight: 360,
            idealHeight: 480,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(.ultraThinMaterial)
    }
}

private struct ItemListView: View {
    @EnvironmentObject private var store: QlipXStore

    private var emptyStateLabel: String {
        String(localized: "mainPanel.emptyState", defaultValue: "No snippets yet.")
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(.regularMaterial)
            .overlay {
                if store.filteredCategories.isEmpty {
                    ContentUnavailableView {
                        Text(emptyStateLabel)
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 14) {
                            ForEach(store.filteredCategories) { category in
                                CategorySectionView(category: category)
                            }
                        }
                        .padding(14)
                    }
                }
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
        VStack(alignment: .leading, spacing: 10) {
            Button {
                store.toggleCategoryExpansion(id: category.id)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: category.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 10)

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

            if category.isExpanded {
                VStack(spacing: 8) {
                    ForEach(category.items) { item in
                        ItemRowView(item: item)
                    }
                }
                .padding(.leading, 20)
            }
        }
    }
}

private struct ItemRowView: View {
    let item: Item

    @State private var isCopied = false
    @State private var resetTask: Task<Void, Never>?

    private var copyLabel: String {
        String(localized: "button.copy", defaultValue: "Copy")
    }

    private var copiedLabel: String {
        String(localized: "button.copied", defaultValue: "Copied")
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
        .onDisappear {
            resetTask?.cancel()
            resetTask = nil
        }
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

#Preview {
    MainPanelView()
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
                            Item(content: "https://example.com/docs", label: "Docs", order: 0)
                        ],
                        isExpanded: false
                    )
                ]
            )
        )
}

#Preview("Empty State") {
    MainPanelView()
        .environmentObject(QlipXStore())
}

private struct CategoryTabsView: View {
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
