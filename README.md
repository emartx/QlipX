# QlipX

<img alt="QlipX Logo" align="right" src="https://raw.githubusercontent.com/emartx/QlipX/refs/heads/main/QlipX/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" width="13%" />

QlipX is a lightweight macOS menu bar app for storing, organizing, and reusing text snippets. It is designed for people who repeatedly copy the same links, notes, commands, replies, templates, or code fragments and want them available in a fast floating panel.

QlipX is built as a personal-use utility with a native macOS feel: simple categories, fast copy access, local persistence, and no unnecessary setup.

Designed and developed by Emad (EmArTx) in Berlin, Germany.

## Demo

![QlipX demo](QlipX/docs/media/qlipx-demo.gif)

## How to Run

- The latest build (`.dmg` file) can be downloaded from the GitHub [Releases](https://github.com/emartx/QlipX/releases) section.
- Open the `.dmg` file and drag QlipX to the `Applications` folder.
- After that, open the app and allow it in macOS if Gatekeeper shows a security prompt for an unsigned build.
- QlipX runs as a menu bar app, so once launched it appears in the macOS menu bar instead of the Dock.
- Click the menu bar icon to open the panel, or use the global shortcut `Cmd + Shift + Space`.

## Using QlipX

- Open the floating panel from the menu bar icon or with the global shortcut `Cmd + Shift + Space`.
- Add a snippet with the `+` button in the top controls area.
- Choose an existing category or type a new category name when saving an item.
- Enter the snippet content and an optional label to make items easier to scan.
- Search instantly from the top search field, or press `Cmd + K` to focus it quickly.
- Press `Esc` in search to clear the query and return focus to the list.
- Copy any saved snippet with the `Copy` button on the item row.
- Edit or delete an item from its context menu.
- Collapse or expand categories to keep the list compact.
- Reorder items inside a category with drag and drop when search is not active.
- Export your data as JSON or plain text from the title bar action or the menu bar menu.

## Agentic Development

QlipX has been developed in an agentic workflow. The product idea and planning documents were developed with Claude, while the implementation work was carried out with Codex.

This repo also keeps agent-facing project context in version control:

- [QlipX/AGENTS.md](QlipX/AGENTS.md) defines project guidance, conventions, and working rules for implementation sessions.
- [QlipX/CURRENT_STATE.md](QlipX/CURRENT_STATE.md) is the live status snapshot for milestones, architecture decisions, and open validation work.
- The documents under `QlipX/docs` capture the broader planning and product context used during development.

Keeping these files updated makes it easier to continue development consistently across agent sessions and future iterations.

## Project Status

QlipX has completed the core v1 milestones through the About window.

Live status is tracked here:

- [QlipX/CURRENT_STATE.md](QlipX/CURRENT_STATE.md)

## Tech Stack

- macOS 13+
- Swift 5.9+
- SwiftUI + AppKit
- Swift Package Manager
- `KeyboardShortcuts` for the global shortcut flow

## Local Data

QlipX stores its data locally on the Mac as a JSON file at `~/Library/Application Support/QlipX/data.json`.

The current architecture is intentionally local-first and does not include sync or analytics.

## Support

QlipX is a free macOS utility built and maintained in spare time. If it saves you time and makes your workflow easier, you can support the project here:

- Author Website: https://emartx.net
- GitHub: https://github.com/emartx/QlipX
- Buy Me a Coffee: https://www.buymeacoffee.com/emartx
- Ko-fi: https://ko-fi.com/emartx
- Report bugs and Suggest features: https://github.com/emartx/QlipX/issues

## License

QlipX is open source software licensed under the MIT License.

See [LICENSE](LICENSE) for details.
