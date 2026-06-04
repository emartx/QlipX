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

    private var store: QlipXStore!
    private(set) var panel: NSPanel?
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        store = MainActor.assumeIsolated {
            PersistenceManager.shared.load()
        }

        panel = makePanel()
        statusItem = makeStatusItem()
        registerGlobalShortcut()
        showPanelOnLaunch()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let panel {
            persistPanelFrame(panel)
        }

        MainActor.assumeIsolated {
            PersistenceManager.shared.saveImmediately(store)
        }
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
        panel.minSize = NSSize(width: 280, height: 360)
        panel.maxSize = NSSize(width: 480, height: 800)
        panel.title = String(localized: "app.title", defaultValue: "QlipX")
        panel.titleVisibility = .visible
        panel.titlebarAppearsTransparent = false
        panel.delegate = self
        panel.contentView = NSHostingView(rootView: MainPanelView().environmentObject(store))
        panel.addTitlebarAccessoryViewController(makeExportAccessory())
        restorePanelFrame(panel)

        return panel
    }

    private func makeExportAccessory() -> NSTitlebarAccessoryViewController {
        let accessory = NSTitlebarAccessoryViewController()
        accessory.layoutAttribute = .right

        let hostingView = NSHostingView(rootView: TitleBarExportButton(action: showExportSheet))
        hostingView.frame = NSRect(x: 0, y: 0, width: 32, height: 28)
        accessory.view = hostingView

        return accessory
    }

    private func makeStatusItem() -> NSStatusItem {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusMenu = makeStatusMenu()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "QlipX")
            button.image?.isTemplate = true
            button.imagePosition = .imageOnly
            button.action = #selector(handleStatusItemClick(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        return statusItem
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(
            withTitle: String(localized: "menu.export", defaultValue: "Export"),
            action: #selector(handleExportMenuItem(_:)),
            keyEquivalent: ""
        )
        menu.items.last?.target = self
        return menu
    }

    @objc
    private func handleStatusItemClick(_ sender: Any?) {
        if NSApp.currentEvent?.type == .rightMouseUp, let statusItem, let statusMenu {
            statusItem.menu = statusMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
            return
        }

        togglePanel(sender)
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

    @objc
    private func handleExportMenuItem(_ sender: Any?) {
        showExportSheet()
    }

    private func registerGlobalShortcut() {
        KeyboardShortcuts.onKeyUp(for: .toggleQlipX) { [weak self] in
            self?.togglePanel(nil)
        }
    }

    private func showPanelOnLaunch() {
        guard let panel else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    private func showExportSheet() {
        guard let panel else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        MainActor.assumeIsolated {
            store.showExportSheet()
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

private struct TitleBarExportButton: View {
    let action: () -> Void

    private var exportLabel: String {
        String(localized: "menu.export", defaultValue: "Export")
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.borderless)
        .help(exportLabel)
    }
}

private extension NSRect {
    var standardizedIfValid: NSRect? {
        let rect = standardized
        guard rect.width > 0, rect.height > 0 else { return nil }
        return rect
    }
}
