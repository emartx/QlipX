# Current State

## Read This First
- This file is the live snapshot of the project state.
- Read this file together with `AGENTS.md` before starting any implementation task.
- If code or project structure changes, update this file in the same session.

## Project Snapshot
- App: **QlipX**
- Platform: macOS 13+
- Stack: SwiftUI + AppKit, Swift 5.9+, SPM
- Distribution target: personal-use macOS menu bar app
- Current phase: post-M9, entering **M10 - Polish & Stabilize**

## Implemented Milestones
- [x] **M1 — Project Setup:** Xcode project created, `LSUIElement=true`, SPM dependency added, folder structure in place, app launches with menu bar icon visible
- [x] **M2 — Core Data Model + Persistence:** models, store, JSON persistence, and window frame persistence are implemented
- [x] **M3 — Main Window UI Shell:** implemented
- [x] **M4 — Core UI:** implemented — `CategoryTabsView`, `ItemListView`, `ItemRowView`, `ColorPalette`, and `FooterView` are in place
- [x] **M5 — Item Management:** implemented — inline add/edit form, item delete confirmation, and in-category drag-and-drop reordering are in place
- [x] **M6 — Category Management:** implemented — category tab rename/delete flows, delete safeguards, and item move-on-delete are in place
- [x] **M7 — Search:** implemented — always-visible search bar, `⌘K` focus, live filtering, escape-to-clear, and no-results empty state are in place
- [x] **M8 — Export:** implemented — export sheet, title bar + menu bar access, JSON/plain text exports, and success confirmation are in place
- [x] **M9 — About Window:** implemented — custom about window, footer + menu bar access, about content, and external links are in place

## Implemented Components And Services
- `AppDelegate`: owns app lifecycle, menu bar item, `NSPanel`, global shortcut registration, export entry point, and panel frame persistence.
- `AboutWindowController`: manages the dedicated About window.
- `QlipXStore`: single `ObservableObject` source of truth for categories, selection, search, add/edit form state, and export sheet state.
- `PersistenceManager`: loads and saves JSON data under `~/Library/Application Support/QlipX/data.json`.
- `ClipboardManager`: central clipboard write path. Views should not touch `NSPasteboard` directly.
- `ExportManager`: exports JSON and plain text snapshots.
- `ColorPalette`: resolves category colors from stored `colorIndex`.
- `MonospaceDetector`: identifies content that should render in monospace styling.

## Open TODOs
- Add the exit row to the menu bar icon
- Finish `M10 - Polish & Stabilize`.
- Verify empty-state behavior on first launch with no data.
- Verify corrupt JSON recovery is graceful and does not crash the app.
- Verify long content rows truncate cleanly while copy still uses full content.
- Verify performance remains acceptable with 50+ items.
- Verify zero-item categories behave correctly after deletes and moves.
- Verify data survives app restart, app relaunch, and reinstall/update scenarios.
- Verify light mode and dark mode readability across the full app.
- Verify layout remains stable at min and max panel sizes.
- Complete the 7-day personal-use validation checklist from `docs/QlipX-ProductionPlan.md`.

## Testing Status
- Automated testing is not part of v1.0 scope.
- Test targets exist in the Xcode project, but project guidance still treats v1.0 as manual-test only.
- Required manual verification remains the main gap before calling v1.0 done.

## Active Decisions
- Keep `QlipXStore` as the only state mutation entry point.
- Keep persistence writes owned by `PersistenceManager` and triggered by the store.
- Keep clipboard access isolated behind `ClipboardManager`.
- Keep the main window as `NSPanel`, not `NSWindow`.
- Keep all user-facing strings localized through `String(localized:)` and `Localizable.xcstrings`.
- Do not expand scope into sync, import, clipboard history, analytics, or other post-v1.0 features.

## Update Rules
- When a milestone status changes, update this file and `AGENTS.md`.
- When architecture or workflow decisions change, record the new decision here.
- When a new blocker or unresolved bug appears, add it under `Open TODOs`.

## Last Updated
2026/06/08 by Emad
