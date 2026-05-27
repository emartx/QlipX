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

    private let persistenceManager: PersistenceManager
    private var cancellables = Set<AnyCancellable>()

    init(
        categories: [Category] = [],
        searchQuery: String = "",
        selectedCategoryID: UUID? = nil,
        isAddFormVisible: Bool = false,
        persistenceManager: PersistenceManager? = nil
    ) {
        self.categories = categories
        self.searchQuery = searchQuery
        self.selectedCategoryID = selectedCategoryID
        self.isAddFormVisible = isAddFormVisible
        self.persistenceManager = persistenceManager ?? PersistenceManager.shared

        bindPersistence()
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
        .sorted(by: Item.sortPredicate)
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

        return items.sorted(by: Item.sortPredicate)
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

    private func bindPersistence() {
        Publishers.Merge4(
            $categories.dropFirst().map { _ in },
            $searchQuery.dropFirst().map { _ in },
            $selectedCategoryID.dropFirst().map { _ in },
            $isAddFormVisible.dropFirst().map { _ in }
        )
        .sink { [weak self] in
            guard let self else {
                return
            }

            persistenceManager.save(self)
        }
        .store(in: &cancellables)
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
    static let sortPredicate: (Item, Item) -> Bool = { lhs, rhs in
        lhs.order < rhs.order
    }
}
