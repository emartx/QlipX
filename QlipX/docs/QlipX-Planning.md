# Production Planning Document
## QlipX — macOS Floating Snippet Manager

**Version:** 1.0.0  
**Status:** Draft  
**Last Updated:** 2026-05-13  
**Related Documents:** QlipX-PRD.md · QlipX-ARD.md

---

## 1. Assumptions & Constraints

| Item | Value |
|---|---|
| Available time per week | 1–3 hours (average assumed: 2 hours) |
| Development approach | Solo developer + AI assistance (Claude Code) |
| Target for v1.0 | Personal use only (no public release) |
| Distribution | Direct install on developer's own Mac |
| Code signing | Self-signed or Developer ID (no notarization needed for personal use) |
| Testing | Manual testing only (no automated test suite in v1.0) |

**Total estimated hours to v1.0:** ~20–28 hours  
**Total estimated calendar time:** 10–14 weeks (2.5–3.5 months at 2 hrs/week average)

---

## 2. Milestones

| # | Milestone | Deliverable | Est. Hours | Est. Week |
|---|---|---|---|---|
| M1 | Project Setup | Xcode project running, menu bar icon visible | 2h | Week 1 |
| M2 | Floating Panel | Window opens/closes, always on top, shortcut works | 3h | Week 2–3 |
| M3 | Data Layer | Store + persistence, data survives restart | 3h | Week 3–4 |
| M4 | Core UI | Items display, copy works, categories show | 4h | Week 5–6 |
| M5 | Item Management | Add, edit, delete, reorder items | 4h | Week 7–8 |
| M6 | Category Management | Create, rename, delete categories | 3h | Week 9–10 |
| M7 | Search | Live search across items | 2h | Week 10–11 |
| M8 | Export | JSON and Plain Text export to Downloads | 2h | Week 11–12 |
| M9 | About Window | About panel with developer info | 1h | Week 12–13 |
| M10 | Polish & Stabilize | Bug fixes, edge cases, 7-day personal use test | 3h | Week 13–14 |

---

## 3. Phase Breakdown

### Phase 1 — Foundation (Weeks 1–4)
*Goal: A working skeleton. Nothing useful yet, but the architecture is solid.*

**M1 — Project Setup (2h)**
- Create new macOS App project in Xcode (SwiftUI, minimum macOS 13)
- Set `LSUIElement = true` in Info.plist (hide from Dock)
- Add `KeyboardShortcuts` via Swift Package Manager
- Create folder structure matching ARD (App, Store, Models, Views, Utilities, Resources)
- Add `Localizable.xcstrings` with placeholder English strings
- Verify app launches and menu bar icon appears

**M2 — Floating Panel (3h)**
- Implement `AppDelegate` with `NSPanel` setup (floating level, non-activating)
- Connect panel show/hide to menu bar click
- Register global shortcut `⌘⇧Space` via `KeyboardShortcuts`
- Implement window position/size persistence via `UserDefaults`
- Verify: panel floats above all apps, shortcut works from Terminal and browser

**M3 — Data Layer (3h)**
- Implement `Category` and `Item` models (Codable, Identifiable)
- Implement `QlipXStore` as `ObservableObject` with `@Published` properties
- Implement `PersistenceManager`: read/write `data.json` to `~/Library/Application Support/QlipX/`
- Add debounced save (300ms) triggered by any store mutation
- Add immediate save on app quit (`applicationWillTerminate`)
- Inject store into SwiftUI hierarchy via `@EnvironmentObject`
- Verify: add test data in code, restart app, data persists

---

### Phase 2 — Core UI (Weeks 5–8)
*Goal: A usable app. Can store and copy items.*

**M4 — Core UI (4h)**
- Implement `MainPanelView` with window chrome (traffic lights, title)
- Implement `CategoryTabsView` (horizontal tabs, "All" tab selected by default)
- Implement `ItemListView` with collapsible group headers per category
- Implement `ItemRowView`:
  - Show `content` (with monospace auto-detection via `MonospaceDetector`)
  - Show optional `label` above content in secondary color
  - Copy button with "✓ Copied" feedback (1.4s timeout)
- Implement `ColorPalette` and render colored dot per category header
- Implement `FooterView` (item count + shortcut hint + developer avatar button)
- Verify: hardcoded test data displays correctly, copy button writes to clipboard

**M5 — Item Management (4h)**
- Implement `AddItemFormView` (inline, appears below search bar):
  - Category field: combobox — select existing or type new name to create
  - Content field (required)
  - Label field (optional)
  - Submit on Return, cancel on Escape
- Wire `+` button in title bar to show/hide form
- Implement edit flow: right-click → Edit → pre-fill form with existing values
- Implement delete flow: right-click → Delete → confirmation alert
- Implement drag-and-drop reordering within a category (using `.onMove`)
- Verify: full CRUD cycle works, order persists after restart

---

### Phase 3 — Remaining Features (Weeks 9–12)
*Goal: Feature-complete per PRD.*

**M6 — Category Management (3h)**
- Right-click on category tab → context menu: Rename / Delete
- Rename: inline text field replaces tab label
- Delete: alert with two options — "Delete all items" or "Move items to…" (category picker)
- Prevent deletion of last remaining category
- Verify: category operations persist correctly

**M7 — Search (2h)**
- Implement search bar (always visible, below title bar)
- `⌘K` focuses the search field from anywhere in the window
- Live filtering: match against `content` and `label` (case-insensitive)
- Escape clears search and returns focus to list
- Show "No results" empty state when search has no matches
- Verify: search works across all categories simultaneously

**M8 — Export (2h)**
- Implement `ExportSheetView` (sheet, not a separate window)
- Accessible from: `↑` icon in title bar + menu bar → Export
- "Export as JSON" button → `ExportManager.exportJSON()` → saves to `~/Downloads/QlipX-export-YYYY-MM-DD.json`
- "Export as Plain Text" button → `ExportManager.exportPlainText()` → saves to `~/Downloads/QlipX-export-YYYY-MM-DD.txt`
- Show success confirmation after export ("Saved to Downloads")
- Verify: both files open correctly, content is accurate

**M9 — About Window (1h)**
- Implement `AboutView` as a small, non-resizable secondary window
- Accessible from: menu bar → About QlipX + developer avatar button in footer
- Content: app icon, name (QlipX), version from `Bundle.main`, developer name, website link, GitHub link
- Links open in default browser via `NSWorkspace.shared.open(url)`
- Verify: window opens from both entry points, links work

---

### Phase 4 — Stabilization (Weeks 13–14)
*Goal: Reliable enough for daily personal use.*

**M10 — Polish & Stabilize (3h)**

Bug fixes and edge cases to verify:
- [ ] Empty state: first launch with no data shows helpful placeholder
- [ ] Corrupt JSON: graceful recovery with alert, not a crash
- [ ] Very long content strings: truncate with ellipsis in row, full text still copied
- [ ] Many items (50+): scrolling is smooth, search remains fast
- [ ] Category with zero items after deletion: handled correctly
- [ ] App update / reinstall: data in `~/Library/Application Support/QlipX/` survives
- [ ] Dark mode and light mode: all UI elements readable in both
- [ ] Resize window to minimum/maximum bounds: layout doesn't break

7-day personal use checklist:
- [ ] Use QlipX daily as the primary way to copy repetitive text
- [ ] Add at least 10 real items across 3+ categories
- [ ] Trigger the global shortcut 20+ times from different apps
- [ ] Export data once in each format and verify output
- [ ] Restart Mac and confirm data persists

---

## 4. Working Method with AI

Since development is AI-assisted (Claude Code), each session should follow this pattern for maximum efficiency:

**Start of each session:**
> "I'm building QlipX, a macOS menu bar app in Swift/SwiftUI. Here are the relevant docs: [paste PRD section + ARD section]. Today I'm working on [milestone name]. The current state is: [brief description]. Help me implement [specific task]."

**Recommended session structure (2-hour block):**
- 0:00–0:10 — Review what was done last session, pick today's task
- 0:10–1:30 — Active development with AI assistance
- 1:30–1:50 — Test what was built, note any bugs
- 1:50–2:00 — Write a 3-line note: what's done, what broke, what's next

**What to always provide to AI:**
- The relevant PRD section for the feature being built
- The relevant ARD section (data model, architecture rules)
- Current code files being modified
- Exact error messages (never paraphrase Xcode errors)

**What AI handles well:**
- Boilerplate SwiftUI view code
- AppKit/SwiftUI bridging patterns
- Codable implementations
- Regex patterns (MonospaceDetector)
- Export formatting logic

**What needs human judgment:**
- Does the UI feel right on the actual Mac?
- Is the copy interaction fast enough?
- Does the window position feel natural?

---

## 5. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| NSPanel + SwiftUI bridging issues | Medium | High | Tackle in M2 (earliest possible); known patterns exist in ARD |
| Global shortcut conflicts with other apps | Low | Medium | `⌘⇧Space` is rarely used; user can reassign via Settings in v2 |
| Motivation loss on a personal project | High | High | Keep M1 very small — first win in Week 1 matters most |
| Sessions too short to make progress | Medium | Medium | Pre-plan each session's single task; never start without a clear goal |
| Data loss from write bug | Low | High | Implement M3 carefully; test persistence before building any UI |

---

## 6. Definition of Done (v1.0)

v1.0 is complete when all of the following are true:

- [ ] All 10 milestones delivered
- [ ] App runs without crashes for 7 consecutive days of personal use
- [ ] Global shortcut works from Terminal, Safari, Xcode, and Finder
- [ ] All data persists across restarts
- [ ] Copy action works correctly in all apps tested
- [ ] Both export formats produce correct output
- [ ] UI is readable in both light and dark mode
- [ ] Window remembers position and size between launches

---

## 7. Future Versions (Post v1.0 Backlog)

Not in scope for v1.0, but documented here to avoid scope creep during development:

| Feature | Target Version |
|---|---|
| Persian (fa) localization | v1.1 |
| Import from JSON | v1.1 |
| Keyboard-only navigation in item list | v1.1 |
| Custom shortcut configuration in Settings | v1.2 |
| iCloud sync | v2.0 |
| iOS companion app | v2.0 |
| Mac App Store distribution | v2.0 |
