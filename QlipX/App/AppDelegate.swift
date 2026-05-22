//
//  AppDelegate.swift
//  QlipX
//
//  Created by Codex on 20/05/2026.
//

import AppKit
import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let toggleQlipX = Self(
        "toggleQlipX",
        default: .init(.space, modifiers: [.command, .shift])
    )
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private(set) var panel: NSPanel?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        panel = makePanel()
        statusItem = makeStatusItem()
        registerGlobalShortcut()
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.delegate = self
        panel.center()
        panel.contentView = NSHostingView(rootView: ContentView())

        return panel
    }

    private func makeStatusItem() -> NSStatusItem {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "QlipX")
            button.image?.isTemplate = true
            button.imagePosition = .imageOnly
            button.action = #selector(togglePanel(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp])
        }

        return statusItem
    }

    @objc
    private func togglePanel(_ sender: Any?) {
        guard let panel else { return }

        if panel.isVisible {
            panel.orderOut(sender)
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(sender)
    }

    private func registerGlobalShortcut() {
        KeyboardShortcuts.onKeyUp(for: .toggleQlipX) { [weak self] in
            self?.togglePanel(nil)
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
}
