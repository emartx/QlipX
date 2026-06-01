//
//  PanelControlsView.swift
//  QlipX
//
//  Created by Codex on 01/06/2026.
//

import SwiftUI

struct PanelControlsView: View {
    @EnvironmentObject private var store: QlipXStore
    @FocusState private var isSearchFocused: Bool

    private var searchLabel: String {
        String(localized: "label.search", defaultValue: "Search snippets")
    }

    private var searchPlaceholder: String {
        String(localized: "placeholder.search", defaultValue: "Search...")
    }

    private var addItemLabel: String {
        String(localized: "button.addItem", defaultValue: "Add Item")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        searchLabel,
                        text: Binding(
                            get: { store.searchQuery },
                            set: store.updateSearchQuery
                        ),
                        prompt: Text(searchPlaceholder)
                    )
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .onExitCommand {
                        store.updateSearchQuery("")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.regularMaterial)
                }

                Button {
                    store.toggleAddForm()
                } label: {
                    Image(systemName: store.isAddFormVisible ? "xmark" : "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.primary.opacity(0.08))
                        }
                }
                .buttonStyle(.plain)
                .help(addItemLabel)
            }

            if store.isAddFormVisible {
                AddItemFormView()
            }
        }
    }
}
