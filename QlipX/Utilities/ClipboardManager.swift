//
//  ClipboardManager.swift
//  QlipX
//
//  Created by Codex on 29/05/2026.
//

import AppKit

struct ClipboardManager {
    static func copy(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
