//
//  AboutView.swift
//  QlipX
//
//  Created by Codex on 05/06/2026.
//

import AppKit
import SwiftUI

struct AboutView: View {
    private let websiteURL = URL(string: "https://emartx.net")
    private let githubURL = URL(string: "https://github.com/emartx/QlipX")
    private let buyMeACoffeeURL = URL(string: "https://www.buymeacoffee.com/emartx")
    private let koFiURL = URL(string: "https://ko-fi.com/emartx")
    private let bugsURL = URL(string: "https://github.com/emartx/QlipX/issues")
    private let featuresURL = URL(string: "https://github.com/emartx/QlipX/issues")

    private var appTitleLine: String {
        "\(String(localized: "app.title", defaultValue: "QlipX")) v\(versionValue)"
    }

    private var introText: String {
        String(
            localized: "about.intro",
            defaultValue: "QlipX is a free macOS utility built and maintained in spare time."
        )
    }

    private var creditsText: String {
        String(
            localized: "about.credits",
            defaultValue: "Designed and developed with ❤️ by Emad (EmArTx) in Berlin, Germany."
        )
    }

    private var websiteLabel: String {
        String(localized: "about.website", defaultValue: "Website")
    }

    private var githubLabel: String {
        String(localized: "about.github", defaultValue: "GitHub")
    }

    private var supportTitle: String {
        String(localized: "about.supportTitle", defaultValue: "Support QlipX")
    }

    private var supportText: String {
        String(
            localized: "about.supportText",
            defaultValue: "If QlipX saves you time and makes your workflow easier, consider supporting its development."
        )
    }

    private var buyMeACoffeeLabel: String {
        String(localized: "about.buyMeACoffee", defaultValue: "☕ Buy Me a Coffee")
    }

    private var koFiLabel: String {
        String(localized: "about.koFi", defaultValue: "💜 Ko-fi")
    }

    private var otherSupportTitle: String {
        String(localized: "about.otherSupportTitle", defaultValue: "Other Ways to Support")
    }

    private var starLabel: String {
        String(localized: "about.starGitHub", defaultValue: "⭐ Star QlipX on GitHub")
    }

    private var bugsLabel: String {
        String(localized: "about.reportBugs", defaultValue: "🐞 Report Bugs")
    }

    private var featuresLabel: String {
        String(localized: "about.suggestFeatures", defaultValue: "💡 Suggest Features")
    }

    private var shareLabel: String {
        String(localized: "about.share", defaultValue: "📢 Share QlipX with Others")
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
            return "1.0.0"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(spacing: 12) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 76, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Text(appTitleLine)
                        .font(.system(size: 24, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 12) {
                    Text(introText)
                    Text(creditsText)
                }
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    linkButton(title: websiteLabel, systemImage: "globe", url: websiteURL)
                    linkButton(title: githubLabel, systemImage: "chevron.left.forwardslash.chevron.right", url: githubURL)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(supportTitle)
                        .font(.system(size: 16, weight: .semibold))

                    Text(supportText)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    supportButton(title: buyMeACoffeeLabel, color: Color(red: 0.86, green: 0.54, blue: 0.14), url: buyMeACoffeeURL)
                    supportButton(title: koFiLabel, color: Color(red: 0.53, green: 0.32, blue: 0.87), url: koFiURL)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(otherSupportTitle)
                        .font(.system(size: 16, weight: .semibold))

                    VStack(alignment: .leading, spacing: 8) {
                        supportLinkRow(title: starLabel, url: githubURL)
                        supportLinkRow(title: bugsLabel, url: bugsURL)
                        supportLinkRow(title: featuresLabel, url: featuresURL)
                        Text(shareLabel)
                            .font(.system(size: 13, weight: .medium))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(.ultraThinMaterial)
    }

    private func linkButton(title: String, systemImage: String, url: URL?) -> some View {
        Button {
            open(url)
        } label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .disabled(url == nil)
    }

    private func supportButton(title: String, color: Color, url: URL?) -> some View {
        Button {
            open(url)
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .foregroundStyle(color)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.12))
                }
        }
        .buttonStyle(.plain)
        .disabled(url == nil)
    }

    private func supportLinkRow(title: String, url: URL?) -> some View {
        Button {
            open(url)
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .disabled(url == nil)
    }

    private func open(_ url: URL?) {
        guard let url else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}

#Preview {
    AboutView()
}
