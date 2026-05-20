//
//  AppDelegate.swift
//  QlipX
//
//  Created by Codex on 20/05/2026.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private(set) var panel: NSPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        panel = makePanel()
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
        panel.center()
        panel.contentView = NSHostingView(rootView: ContentView())

        return panel
    }
}
