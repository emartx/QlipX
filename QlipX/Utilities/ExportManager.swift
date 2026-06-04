//
//  ExportManager.swift
//  QlipX
//
//  Created by Codex on 04/06/2026.
//

import Foundation

@MainActor
final class ExportManager {
    static let shared = ExportManager()

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    static func exportJSON(store: QlipXStore) throws -> URL {
        try shared.exportJSON(store: store)
    }

    static func exportPlainText(store: QlipXStore) throws -> URL {
        try shared.exportPlainText(store: store)
    }

    func exportJSON(store: QlipXStore) throws -> URL {
        let payload = JSONExportPayload(
            exportedAt: Date(),
            version: store.snapshot.version,
            categories: store.categories
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                .map { category in
                    JSONExportPayload.CategoryPayload(
                        name: category.name,
                        items: category.items
                            .sorted(by: { $0.order < $1.order })
                            .map { item in
                                JSONExportPayload.ItemPayload(
                                    content: item.content,
                                    label: item.label,
                                    createdAt: item.createdAt
                                )
                            }
                    )
                }
        )

        let data = try encoder.encode(payload)
        let destinationURL = downloadsDirectoryURL.appendingPathComponent(jsonFileName, isDirectory: false)
        try data.write(to: destinationURL, options: .atomic)
        return destinationURL
    }

    func exportPlainText(store: QlipXStore) throws -> URL {
        let sortedCategories = store.categories
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        let sections = sortedCategories.map { category in
            let lines = category.items
                .sorted(by: { $0.order < $1.order })
                .map { item in
                    if let label = item.label, !label.isEmpty {
                        return """
                        \(label):
                        \(item.content)
                        """
                    }

                    return item.content
                }
                .joined(separator: "\n\n")

            return """
            === \(category.name) ===

            \(lines)
            """
        }

        let content = sections.joined(separator: "\n\n")
        let destinationURL = downloadsDirectoryURL.appendingPathComponent(plainTextFileName, isDirectory: false)
        try content.write(to: destinationURL, atomically: true, encoding: .utf8)
        return destinationURL
    }

    private var downloadsDirectoryURL: URL {
        fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Downloads", isDirectory: true)
    }

    private var jsonFileName: String {
        "QlipX-export-\(fileDateFormatter.string(from: Date())).json"
    }

    private var plainTextFileName: String {
        "QlipX-export-\(fileDateFormatter.string(from: Date())).txt"
    }

    private var fileDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private struct JSONExportPayload: Codable {
    let exportedAt: Date
    let version: String
    let categories: [CategoryPayload]

    struct CategoryPayload: Codable {
        let name: String
        let items: [ItemPayload]
    }

    struct ItemPayload: Codable {
        let content: String
        let label: String?
        let createdAt: Date
    }
}
