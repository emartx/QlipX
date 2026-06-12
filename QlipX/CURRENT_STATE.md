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

## Raw Ideas For Next Phases
- Add an optional quick-capture flow so copied text can be sent into QlipX with a shortcut such as `Ctrl+C` followed by an app-specific trigger, or a dedicated global shortcut that imports the current clipboard content directly.
- Explore a background clipboard listener mode that detects newly copied text and offers a lightweight confirmation to save it into the currently selected category.
- Add a "copy then auto-save" onboarding option so users can choose between manual item entry and clipboard-driven capture.
- Support a one-step "capture to inbox" category so new clipboard entries land in a default holding area before being organized.
- Add a small capture toast or HUD near the menu bar so clipboard imports feel immediate and do not require opening the main panel.
- Consider duplicate detection for clipboard imports so repeated copies do not create accidental item spam.
- Add per-category or global rules for clipboard capture, such as trim whitespace, preserve line breaks, or auto-detect code blocks.
- Consider a configurable shortcut system for capture actions so users can choose a key combo that does not conflict with their normal workflow.
- Evaluate whether `Ctrl+C` itself should remain untouched and QlipX should instead react to clipboard changes after the system copy completes, since overriding standard copy behavior could be fragile across apps.
- If clipboard capture is added, define privacy expectations clearly, especially whether QlipX only reacts on explicit shortcut use or continuously observes clipboard changes.

## Update Rules
- When a milestone status changes, update this file and `AGENTS.md`.
- When architecture or workflow decisions change, record the new decision here.
- When a new blocker or unresolved bug appears, add it under `Open TODOs`.

## Last Updated
2026/06/12 by Codex
