//
//  FooterView.swift
//  QlipX
//
//  Created by Codex on 01/06/2026.
//

import AppKit
import SwiftUI

struct FooterView: View {
    let itemCount: Int
    let itemCountLabel: String

    private var shortcutHint: String {
        String(localized: "mainPanel.shortcutHint", defaultValue: "⌘⇧Space")
    }

    private var aboutLabel: String {
        String(localized: "menu.about", defaultValue: "About QlipX")
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: showAbout) {
                Image(systemName: "person.circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(aboutLabel)

            HStack(spacing: 4) {
                Text("\(itemCount)")
                Text(itemCountLabel)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Label {
                Text(shortcutHint)
            } icon: {
                Image(systemName: "keyboard")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
        }
    }

    private func showAbout() {
        let existingWindowIdentifiers = Set(NSApp.windows.map { ObjectIdentifier($0) })

        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)

        let aboutWindow = NSApp.windows.first {
            !existingWindowIdentifiers.contains(ObjectIdentifier($0))
        } ?? NSApp.windows.first {
            $0 !== NSApp.keyWindow && $0 !== NSApp.mainWindow && $0.isVisible
        }

        aboutWindow?.level = .floating
        aboutWindow?.makeKeyAndOrderFront(nil)
    }
}
