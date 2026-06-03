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
    @Published private(set) var searchFocusRequestID: Int
    @Published private(set) var editingItemContext: EditingItemContext?

    private let persistenceManager: PersistenceManager
    private var cancellables = Set<AnyCancellable>()

    init(
        categories: [Category] = [],
        searchQuery: String = "",
        selectedCategoryID: UUID? = nil,
        isAddFormVisible: Bool = false,
        searchFocusRequestID: Int = 0,
        persistenceManager: PersistenceManager? = nil
    ) {
        self.categories = categories
        self.searchQuery = searchQuery
        self.selectedCategoryID = selectedCategoryID
        self.isAddFormVisible = isAddFormVisible
        self.searchFocusRequestID = searchFocusRequestID
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

    var filteredCategories: [Category] {
        categoriesForSelectedScope.compactMap { category in
            let filteredItems = category.items
                .filter { item in
                    guard !normalizedSearchQuery.isEmpty else {
                        return true
                    }

                    return item.content.localizedCaseInsensitiveContains(normalizedSearchQuery)
                        || (item.label?.localizedCaseInsensitiveContains(normalizedSearchQuery) ?? false)
                }
                .sorted(by: Item.sortPredicate)

            guard !filteredItems.isEmpty else {
                return nil
            }

            var filteredCategory = category
            filteredCategory.items = filteredItems
            return filteredCategory
        }
    }

    var displayedCategories: [Category] {
        if isSearchActive {
            return filteredCategories
        }

        return categoriesForSelectedScope.map { category in
            var category = category
            category.items.sort(by: Item.sortPredicate)
            return category
        }
    }

    var isSearchActive: Bool {
        !normalizedSearchQuery.isEmpty
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

    func requestSearchFocus() {
        searchFocusRequestID += 1
    }

    func selectCategory(id: UUID?) {
        selectedCategoryID = id
    }

    func showAddForm() {
        editingItemContext = nil
        isAddFormVisible = true
    }

    func hideAddForm() {
        editingItemContext = nil
        isAddFormVisible = false
    }

    func toggleAddForm() {
        if isAddFormVisible {
            hideAddForm()
        } else {
            showAddForm()
        }
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

    func renameCategory(id categoryID: UUID, to proposedName: String) {
        let normalizedName = proposedName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !normalizedName.isEmpty,
            let categoryIndex = categories.firstIndex(where: { $0.id == categoryID })
        else {
            return
        }

        let hasDuplicate = categories.contains {
            $0.id != categoryID
                && $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    .localizedCaseInsensitiveCompare(normalizedName) == .orderedSame
        }

        guard !hasDuplicate else {
            return
        }

        categories[categoryIndex].name = normalizedName

        if editingItemContext?.originalCategoryID == categoryID {
            editingItemContext?.categoryName = normalizedName
        }
    }

    func removeCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        normalizeSelectedCategoryIfNeeded()
    }

    func deleteCategoryAndItems(id categoryID: UUID) {
        guard categories.count > 1 else {
            return
        }

        if editingItemContext?.originalCategoryID == categoryID {
            editingItemContext = nil
            isAddFormVisible = false
        }

        removeCategory(id: categoryID)
    }

    func moveItemsAndDeleteCategory(id categoryID: UUID, destinationCategoryID: UUID) {
        guard
            categoryID != destinationCategoryID,
            let sourceCategoryIndex = categories.firstIndex(where: { $0.id == categoryID }),
            let destinationCategoryIndex = categories.firstIndex(where: { $0.id == destinationCategoryID })
        else {
            return
        }

        let movedItems = categories[sourceCategoryIndex].items.sorted(by: Item.sortPredicate)
        let baseOrder = (categories[destinationCategoryIndex].items.map(\.order).max() ?? -1) + 1

        for (offset, item) in movedItems.enumerated() {
            categories[destinationCategoryIndex].items.append(
                Item(
                    id: item.id,
                    content: item.content,
                    label: item.label,
                    createdAt: item.createdAt,
                    order: baseOrder + offset
                )
            )
        }

        categories[destinationCategoryIndex].isExpanded = true

        if editingItemContext?.originalCategoryID == categoryID {
            editingItemContext?.originalCategoryID = destinationCategoryID
            editingItemContext?.categoryName = categories[destinationCategoryIndex].name
        }

        if selectedCategoryID == categoryID {
            selectedCategoryID = destinationCategoryID
        }

        categories.remove(at: sourceCategoryIndex)
        normalizeSelectedCategoryIfNeeded()
    }

    func addItem(_ item: Item, toCategoryID categoryID: UUID) {
        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else {
            return
        }

        categories[index].items.append(item)
    }

    func removeItem(id itemID: UUID, fromCategoryID categoryID: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else {
            return
        }

        categories[categoryIndex].items.removeAll { $0.id == itemID }

        if editingItemContext?.itemID == itemID {
            editingItemContext = nil
            isAddFormVisible = false
        }
    }

    func addItem(
        content: String,
        label: String?,
        categoryName: String
    ) {
        let normalizedCategoryName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedLabel = label?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedCategoryName.isEmpty, !normalizedContent.isEmpty else {
            return
        }

        let categoryID = resolveCategoryID(for: normalizedCategoryName)

        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else {
            return
        }

        let nextOrder = (categories[index].items.map(\.order).max() ?? -1) + 1
        let item = Item(
            content: normalizedContent,
            label: normalizedLabel?.isEmpty == true ? nil : normalizedLabel,
            order: nextOrder
        )

        categories[index].items.append(item)
        categories[index].isExpanded = true
        selectedCategoryID = categories[index].id
        isAddFormVisible = false
    }

    func beginEditingItem(id itemID: UUID, categoryID: UUID) {
        guard
            let category = categories.first(where: { $0.id == categoryID }),
            let item = category.items.first(where: { $0.id == itemID })
        else {
            return
        }

        editingItemContext = EditingItemContext(
            itemID: item.id,
            originalCategoryID: category.id,
            categoryName: category.name,
            content: item.content,
            label: item.label ?? ""
        )
        isAddFormVisible = true
    }

    func submitItemForm(
        content: String,
        label: String?,
        categoryName: String
    ) {
        if let editingItemContext {
            updateItem(
                id: editingItemContext.itemID,
                fromCategoryID: editingItemContext.originalCategoryID,
                content: content,
                label: label,
                categoryName: categoryName
            )
        } else {
            addItem(content: content, label: label, categoryName: categoryName)
        }
    }

    func toggleCategoryExpansion(id: UUID) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else {
            return
        }

        categories[index].isExpanded.toggle()
    }

    func moveItems(
        inCategoryID categoryID: UUID,
        fromOffsets source: IndexSet,
        toOffset destination: Int
    ) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else {
            return
        }

        categories[categoryIndex].items.sort(by: Item.sortPredicate)
        categories[categoryIndex].items.move(fromOffsets: source, toOffset: destination)

        for index in categories[categoryIndex].items.indices {
            categories[categoryIndex].items[index].order = index
        }
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

    private var categoriesForSelectedScope: [Category] {
        if let selectedCategory {
            return [selectedCategory]
        }

        return categories
    }

    private var normalizedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateItem(
        id itemID: UUID,
        fromCategoryID originalCategoryID: UUID,
        content: String,
        label: String?,
        categoryName: String
    ) {
        let normalizedCategoryName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedLabel = label?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !normalizedCategoryName.isEmpty,
            !normalizedContent.isEmpty,
            let sourceCategoryIndex = categories.firstIndex(where: { $0.id == originalCategoryID }),
            let sourceItemIndex = categories[sourceCategoryIndex].items.firstIndex(where: { $0.id == itemID })
        else {
            return
        }

        let existingItem = categories[sourceCategoryIndex].items[sourceItemIndex]
        let destinationCategoryID = resolveCategoryID(for: normalizedCategoryName)

        if destinationCategoryID == originalCategoryID {
            categories[sourceCategoryIndex].items[sourceItemIndex].content = normalizedContent
            categories[sourceCategoryIndex].items[sourceItemIndex].label =
                normalizedLabel?.isEmpty == true ? nil : normalizedLabel
            categories[sourceCategoryIndex].isExpanded = true
        } else {
            categories[sourceCategoryIndex].items.remove(at: sourceItemIndex)

            guard let destinationCategoryIndex = categories.firstIndex(where: { $0.id == destinationCategoryID }) else {
                return
            }

            let nextOrder = (categories[destinationCategoryIndex].items.map(\.order).max() ?? -1) + 1
            let movedItem = Item(
                id: existingItem.id,
                content: normalizedContent,
                label: normalizedLabel?.isEmpty == true ? nil : normalizedLabel,
                createdAt: existingItem.createdAt,
                order: nextOrder
            )

            categories[destinationCategoryIndex].items.append(movedItem)
            categories[destinationCategoryIndex].isExpanded = true
        }

        selectedCategoryID = destinationCategoryID
        editingItemContext = nil
        isAddFormVisible = false
    }

    private func resolveCategoryID(for categoryName: String) -> UUID {
        if let category = categories.first(
            where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(categoryName) == .orderedSame }
        ) {
            return category.id
        }

        let category = Category(
            name: categoryName,
            colorIndex: categories.count % ColorPalette.colors.count
        )

        categories.append(category)
        return category.id
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
    struct EditingItemContext: Equatable {
        let itemID: UUID
        var originalCategoryID: UUID
        var categoryName: String
        let content: String
        let label: String
    }

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
