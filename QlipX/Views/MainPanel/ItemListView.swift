//
//  ItemListView.swift
//  QlipX
//
//  Created by Codex on 01/06/2026.
//

import SwiftUI

struct ItemListView: View {
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
