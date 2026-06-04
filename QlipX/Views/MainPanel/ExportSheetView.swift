//
//  ExportSheetView.swift
//  QlipX
//
//  Created by Codex on 04/06/2026.
//

import SwiftUI

struct ExportSheetView: View {
    let onExportJSON: () -> Void
    let onExportPlainText: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var title: String {
        String(localized: "sheet.export.title", defaultValue: "Export")
    }

    private var subtitle: String {
        String(
            localized: "sheet.export.subtitle",
            defaultValue: "Choose a format to save your snippets to Downloads."
        )
    }

    private var cancelLabel: String {
        String(localized: "button.cancel", defaultValue: "Cancel")
    }

    private var exportJSONLabel: String {
        String(localized: "menu.exportJSON", defaultValue: "Export as JSON")
    }

    private var exportPlainTextLabel: String {
        String(localized: "menu.exportPlainText", defaultValue: "Export as Plain Text")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                exportButton(
                    title: exportJSONLabel,
                    systemImage: "curlybraces",
                    action: {
                        onExportJSON()
                        dismiss()
                    }
                )

                exportButton(
                    title: exportPlainTextLabel,
                    systemImage: "doc.plaintext",
                    action: {
                        onExportPlainText()
                        dismiss()
                    }
                )
            }

            HStack {
                Spacer()

                Button(cancelLabel) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private func exportButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 18)

                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.08))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExportSheetView(
        onExportJSON: {},
        onExportPlainText: {}
    )
}
