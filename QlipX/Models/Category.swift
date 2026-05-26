//
//  Category.swift
//  QlipX
//
//  Created by Codex on 26/05/2026.
//

import Foundation

struct Category: Codable, Identifiable {
    var id: UUID
    var name: String
    var colorIndex: Int
    var items: [Item]
    var isExpanded: Bool

    init(
        id: UUID = UUID(),
        name: String,
        colorIndex: Int,
        items: [Item] = [],
        isExpanded: Bool = true
    ) {
        self.id = id
        self.name = name
        self.colorIndex = colorIndex
        self.items = items
        self.isExpanded = isExpanded
    }
}
