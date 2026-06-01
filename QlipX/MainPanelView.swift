//
//  ContentView.swift
//  QlipX
//
//  Created by Seyed Emad Armoun on 15/05/2026.
//

import AppKit
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
            Text(title)
                .font(.system(size: 22, weight: .semibold))

            PanelControlsView()

            CategoryTabsView()

            ItemListView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            FooterView(itemCount: store.filteredItems.count, itemCountLabel: itemCountLabel)
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

private struct PanelControlsView: View {
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

private struct FooterView: View {
    let itemCount: Int
    let itemCountLabel: String

    private var shortcutHint: String {
        String(localized: "mainPanel.shortcutHint", defaultValue: "⌘⇧Space")
    }

    private var aboutLabel: String {
        String(localized: "menu.about", defaultValue: "About QlipX")
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: showAbout) {
                Image(systemName: "person.circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(aboutLabel)

            HStack(spacing: 4) {
                Text("\(itemCount)")
                Text(itemCountLabel)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Label {
                Text(shortcutHint)
            } icon: {
                Image(systemName: "keyboard")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
        }
    }

    private func showAbout() {
        let existingWindowIdentifiers = Set(NSApp.windows.map { ObjectIdentifier($0) })

        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)

        let aboutWindow = NSApp.windows.first {
            !existingWindowIdentifiers.contains(ObjectIdentifier($0))
        } ?? NSApp.windows.first {
            $0 !== NSApp.keyWindow && $0 !== NSApp.mainWindow && $0.isVisible
        }

        aboutWindow?.level = .floating
        aboutWindow?.makeKeyAndOrderFront(nil)
    }
}

private struct AddItemFormView: View {
    @EnvironmentObject private var store: QlipXStore
    @FocusState private var focusedField: Field?

    @State private var categoryName = ""
    @State private var content = ""
    @State private var label = ""

    private enum Field: Hashable {
        case content
        case label
    }

    private var categoryLabel: String {
        String(localized: "label.category", defaultValue: "Category")
    }

    private var contentLabel: String {
        String(localized: "label.content", defaultValue: "Content")
    }

    private var itemLabelLabel: String {
        String(localized: "label.label", defaultValue: "Label")
    }

    private var categoryPlaceholder: String {
        String(localized: "placeholder.newCategory", defaultValue: "New category")
    }

    private var contentPlaceholder: String {
        String(localized: "placeholder.content", defaultValue: "Snippet content")
    }

    private var labelPlaceholder: String {
        String(localized: "placeholder.label", defaultValue: "Optional label")
    }

    private var saveLabel: String {
        String(localized: "button.save", defaultValue: "Save")
    }

    private var cancelLabel: String {
        String(localized: "button.cancel", defaultValue: "Cancel")
    }

    private var canSubmit: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var categoryOptions: [String] {
        store.categories.map(\.name).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LabeledField(label: categoryLabel) {
                CategoryComboBox(
                    text: $categoryName,
                    options: categoryOptions,
                    placeholder: categoryPlaceholder,
                    onSubmit: submit,
                    onCancel: cancel
                )
                .frame(height: 24)
            }

            LabeledField(label: contentLabel) {
                TextField(contentLabel, text: $content, prompt: Text(contentPlaceholder))
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .content)
                    .submitLabel(.done)
                    .onSubmit(submit)
            }

            LabeledField(label: itemLabelLabel) {
                TextField(itemLabelLabel, text: $label, prompt: Text(labelPlaceholder))
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .label)
                    .submitLabel(.done)
                    .onSubmit(submit)
            }

            HStack(spacing: 8) {
                Spacer()

                Button(cancelLabel, action: cancel)
                    .keyboardShortcut(.cancelAction)

                Button(saveLabel, action: submit)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!canSubmit)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
        .onAppear {
            if categoryName.isEmpty, let selectedCategory = store.selectedCategory {
                categoryName = selectedCategory.name
            }

            DispatchQueue.main.async {
                focusedField = .content
            }
        }
        .onExitCommand(perform: cancel)
    }

    private func submit() {
        guard canSubmit else {
            focusedField = .content
            return
        }

        store.addItem(content: content, label: label, categoryName: categoryName)
        categoryName = store.selectedCategory?.name ?? categoryName
        content = ""
        label = ""
    }

    private func cancel() {
        categoryName = ""
        content = ""
        label = ""
        store.hideAddForm()
    }
}

private struct LabeledField<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)

            content()
        }
    }
}

private struct CategoryComboBox: NSViewRepresentable {
    @Binding var text: String

    let options: [String]
    let placeholder: String
    let onSubmit: () -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> SubmitAwareComboBox {
        let comboBox = SubmitAwareComboBox()
        comboBox.usesDataSource = false
        comboBox.isEditable = true
        comboBox.completes = true
        comboBox.delegate = context.coordinator
        comboBox.target = context.coordinator
        comboBox.action = #selector(Coordinator.selectionDidChange(_:))
        comboBox.placeholderString = placeholder
        comboBox.font = .systemFont(ofSize: NSFont.systemFontSize)
        comboBox.submitHandler = onSubmit
        comboBox.cancelHandler = onCancel
        return comboBox
    }

    func updateNSView(_ comboBox: SubmitAwareComboBox, context: Context) {
        comboBox.submitHandler = onSubmit
        comboBox.cancelHandler = onCancel
        comboBox.removeAllItems()
        comboBox.addItems(withObjectValues: options)

        if comboBox.stringValue != text {
            comboBox.stringValue = text
        }
    }

    final class Coordinator: NSObject, NSComboBoxDelegate {
        private let parent: CategoryComboBox

        init(_ parent: CategoryComboBox) {
            self.parent = parent
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let comboBox = notification.object as? NSComboBox else {
                return
            }

            parent.text = comboBox.stringValue
        }

        @objc
        func selectionDidChange(_ sender: NSComboBox) {
            parent.text = sender.stringValue
        }
    }
}

private final class SubmitAwareComboBox: NSComboBox {
    var submitHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)

        guard
            let movementValue = notification.userInfo?["NSTextMovement"] as? Int,
            let movement = NSTextMovement(rawValue: movementValue)
        else {
            return
        }

        switch movement {
        case .return:
            submitHandler?()
        case .cancel:
            cancelHandler?()
        default:
            break
        }
    }

    override func cancelOperation(_ sender: Any?) {
        cancelHandler?()
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
