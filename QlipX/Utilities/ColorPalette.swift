//
//  ColorPalette.swift
//  QlipX
//
//  Created by Codex on 29/05/2026.
//

import SwiftUI

struct ColorPalette {
    static let colors: [Color] = [
        Color(hex: "#185FA5"),
        Color(hex: "#993C1D"),
        Color(hex: "#3B6D11"),
        Color(hex: "#BA7517"),
        Color(hex: "#534AB7"),
        Color(hex: "#993556")
    ]

    static func color(for index: Int) -> Color {
        guard !colors.isEmpty else {
            return .secondary
        }

        let normalizedIndex = ((index % colors.count) + colors.count) % colors.count
        return colors[normalizedIndex]
    }
}

private extension Color {
    init(hex: String) {
        let sanitizedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = UInt64(sanitizedHex, radix: 16) ?? 0

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
