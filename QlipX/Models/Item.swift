//
//  Item.swift
//  QlipX
//
//  Created by Codex on 26/05/2026.
//

import Foundation

struct Item: Codable, Identifiable {
    var id: UUID
    var content: String
    var label: String?
    var createdAt: Date
    var order: Int

    init(
        id: UUID = UUID(),
        content: String,
        label: String? = nil,
        createdAt: Date = Date(),
        order: Int
    ) {
        self.id = id
        self.content = content
        self.label = label
        self.createdAt = createdAt
        self.order = order
    }
}
