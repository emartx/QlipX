//
//  AddItemFormView.swift
//  QlipX
//
//  Created by Codex on 01/06/2026.
//

import AppKit
import SwiftUI

struct AddItemFormView: View {
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

    private var formTitle: String {
        if store.editingItemContext != nil {
            return String(localized: "button.edit", defaultValue: "Edit")
        }

        return String(localized: "button.addItem", defaultValue: "Add Item")
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
            Text(formTitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

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
            applyFormState()
        }
        .onChange(of: store.editingItemContext) { _, _ in
            applyFormState()
        }
        .onExitCommand(perform: cancel)
    }

    private func submit() {
        guard canSubmit else {
            focusedField = .content
            return
        }

        store.submitItemForm(content: content, label: label, categoryName: categoryName)
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

    private func applyFormState() {
        if let editingItemContext = store.editingItemContext {
            categoryName = editingItemContext.categoryName
            content = editingItemContext.content
            label = editingItemContext.label
        } else if let selectedCategory = store.selectedCategory {
            categoryName = selectedCategory.name
            content = ""
            label = ""
        } else {
            categoryName = ""
            content = ""
            label = ""
        }

        DispatchQueue.main.async {
            focusedField = .content
        }
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
        comboBox.textChangeHandler = { newValue in
            context.coordinator.updateText(newValue)
        }
        comboBox.submitHandler = onSubmit
        comboBox.cancelHandler = onCancel
        return comboBox
    }

    func updateNSView(_ comboBox: SubmitAwareComboBox, context: Context) {
        comboBox.textChangeHandler = { newValue in
            context.coordinator.updateText(newValue)
        }
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

        func updateText(_ text: String) {
            parent.text = text
        }

        func controlTextDidChange(_ notification: Notification) {
            updateText((notification.object as? NSComboBox)?.stringValue ?? parent.text)
        }

        @objc
        func selectionDidChange(_ sender: NSComboBox) {
            updateText(sender.stringValue)
        }
    }
}

private final class SubmitAwareComboBox: NSComboBox {
    var textChangeHandler: ((String) -> Void)?
    var submitHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        textChangeHandler?(stringValue)
    }

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        textChangeHandler?(stringValue)

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
