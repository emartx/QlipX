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
    private enum DefaultsKey {
        static let panelFrame = "qlipx.panelFrame"
    }

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
        panel.contentView = NSHostingView(rootView: ContentView())
        restorePanelFrame(panel)

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

    private func restorePanelFrame(_ panel: NSPanel) {
        guard
            let frameString = UserDefaults.standard.string(forKey: DefaultsKey.panelFrame),
            let frame = NSRectFromString(frameString).standardizedIfValid
        else {
            panel.center()
            return
        }

        panel.setFrame(frame, display: false)
    }

    private func persistPanelFrame(_ window: NSWindow) {
        UserDefaults.standard.set(NSStringFromRect(window.frame), forKey: DefaultsKey.panelFrame)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        persistPanelFrame(sender)
        sender.orderOut(nil)
        return false
    }

    func windowDidMove(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        persistPanelFrame(window)
    }

    func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        persistPanelFrame(window)
    }
}

private extension NSRect {
    var standardizedIfValid: NSRect? {
        let rect = standardized
        guard rect.width > 0, rect.height > 0 else { return nil }
        return rect
    }
}
