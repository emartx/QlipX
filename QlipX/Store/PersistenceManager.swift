//
//  PersistenceManager.swift
//  QlipX
//
//  Created by Codex on 26/05/2026.
//

import Foundation

@MainActor
final class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileManager: FileManager
    private let directoryURL: URL
    private let fileURL: URL
    private var debounceTimer: Timer?

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent("Library/Application Support", isDirectory: true)

        directoryURL = appSupportURL.appendingPathComponent("QlipX", isDirectory: true)
        fileURL = directoryURL.appendingPathComponent("data.json", isDirectory: false)
    }

    func load() -> QlipXStore {
        do {
            guard fileManager.fileExists(atPath: fileURL.path) else {
                return QlipXStore()
            }

            let data = try Data(contentsOf: fileURL)
            let snapshot = try decoder.decode(QlipXStore.Snapshot.self, from: data)
            return QlipXStore(snapshot: snapshot)
        } catch {
            NSLog("PersistenceManager.load failed for %@: %@", fileURL.path, error.localizedDescription)
            return QlipXStore()
        }
    }

    func save(_ store: QlipXStore) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.saveImmediately(store)
        }
    }

    func saveImmediately(_ store: QlipXStore) {
        debounceTimer?.invalidate()
        debounceTimer = nil

        do {
            try createDirectoryIfNeeded()

            let data = try encoder.encode(store.snapshot)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            NSLog("PersistenceManager.save failed for %@: %@", fileURL.path, error.localizedDescription)
        }
    }

    var storageFileURL: URL {
        fileURL
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private func createDirectoryIfNeeded() throws {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
}
