//
//  AboutView.swift
//  QlipX
//
//  Created by Codex on 05/06/2026.
//

import AppKit
import SwiftUI

struct AboutView: View {
    private var appTitle: String {
        String(localized: "app.title", defaultValue: "QlipX")
    }

    private var versionLabel: String {
        String(localized: "about.version", defaultValue: "Version")
    }

    private var developerName: String {
        String(localized: "about.developerName", defaultValue: "Seyed Emad Armoun")
    }

    private var versionValue: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (shortVersion, buildNumber) {
        case let (shortVersion?, buildNumber?) where shortVersion != buildNumber:
            return "\(shortVersion) (\(buildNumber))"
        case let (shortVersion?, _):
            return shortVersion
        case let (_, buildNumber?):
            return buildNumber
        default:
            return "1.0"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(spacing: 6) {
                Text(appTitle)
                    .font(.system(size: 24, weight: .semibold))

                Text("\(versionLabel) \(versionValue)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(developerName)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    AboutView()
}
