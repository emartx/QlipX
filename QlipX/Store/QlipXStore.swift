//
//  QlipXStore.swift
//  QlipX
//
//  Created by Codex on 26/05/2026.
//

import Combine
import Foundation

@MainActor
final class QlipXStore: ObservableObject {
    @Published var categories: [Category]
    @Published var searchQuery: String
    @Published var selectedCategoryID: UUID?
    @Published var isAddFormVisible: Bool

    init(
        categories: [Category] = [],
        searchQuery: String = "",
        selectedCategoryID: UUID? = nil,
        isAddFormVisible: Bool = false
    ) {
        self.categories = categories
        self.searchQuery = searchQuery
        self.selectedCategoryID = selectedCategoryID
        self.isAddFormVisible = isAddFormVisible
    }

    convenience init(snapshot: Snapshot) {
        self.init(categories: snapshot.categories)
    }

    var snapshot: Snapshot {
        Snapshot(categories: categories)
    }

    var filteredItems: [Item] {
        itemsForSelectedCategory.filter { item in
            guard !normalizedSearchQuery.isEmpty else {
                return true
            }

            return item.content.localizedCaseInsensitiveContains(normalizedSearchQuery)
                || (item.label?.localizedCaseInsensitiveContains(normalizedSearchQuery) ?? false)
        }
        .sorted(using: Item.sortComparator)
    }

    var selectedCategory: Category? {
        guard let selectedCategoryID else {
            return nil
        }

        return categories.first { $0.id == selectedCategoryID }
    }

    func updateSearchQuery(_ searchQuery: String) {
        self.searchQuery = searchQuery
    }

    func selectCategory(id: UUID?) {
        selectedCategoryID = id
    }

    func showAddForm() {
        isAddFormVisible = true
    }

    func hideAddForm() {
        isAddFormVisible = false
    }

    func toggleAddForm() {
        isAddFormVisible.toggle()
    }

    func setCategories(_ categories: [Category]) {
        self.categories = categories
        normalizeSelectedCategoryIfNeeded()
    }

    func addCategory(_ category: Category) {
        categories.append(category)
    }

    func updateCategory(_ category: Category) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else {
            return
        }

        categories[index] = category
    }

    func removeCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        normalizeSelectedCategoryIfNeeded()
    }

    func addItem(_ item: Item, toCategoryID categoryID: UUID) {
        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else {
            return
        }

        categories[index].items.append(item)
    }

    private var itemsForSelectedCategory: [Item] {
        let items: [Item]

        if let selectedCategory {
            items = selectedCategory.items
        } else {
            items = categories.flatMap(\.items)
        }

        return items.sorted(using: Item.sortComparator)
    }

    private var normalizedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizeSelectedCategoryIfNeeded() {
        guard let selectedCategoryID else {
            return
        }

        if !categories.contains(where: { $0.id == selectedCategoryID }) {
            self.selectedCategoryID = nil
        }
    }
}

extension QlipXStore {
    struct Snapshot: Codable {
        var version: String
        var categories: [Category]

        init(version: String = "1.0", categories: [Category]) {
            self.version = version
            self.categories = categories
        }
    }
}

private extension Item {
    static let sortComparator = SortComparator(\Item.order)
}
