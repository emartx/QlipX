//
//  AboutWindowController.swift
//  QlipX
//
//  Created by Codex on 05/06/2026.
//

import AppKit
import SwiftUI

@MainActor
final class AboutWindowController {
    static let shared = AboutWindowController()

    private var window: NSWindow?

    func show() {
        let window = window ?? makeWindow()
        self.window = window

        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 620),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.level = .floating
        window.title = String(localized: "menu.about", defaultValue: "About QlipX")
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.center()
        window.contentView = NSHostingView(rootView: AboutView())
        return window
    }
}
