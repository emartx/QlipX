# Project Overview
- App name: **QlipX** (Quick + Clip + X)
- macOS menu bar app for storing and instantly copying frequently used text snippets
- Personal tool — no accounts, no cloud, no analytics
- Target: macOS 13 Ventura+, Universal Binary (Apple Silicon + Intel)
- Distribution: direct install, personal use only (v1.0)

# Tech Stack
- Language: **Swift 5.9+**
- UI: **SwiftUI** (views) + **AppKit** (window/panel management only)
- Minimum deployment: **macOS 13.0**
- One external dependency: **KeyboardShortcuts** (Sindre Sorhus) via SPM
- Storage: local JSON file at `~/Library/Application Support/QlipX/data.json`

# Architecture Rules
- Pattern: **MVVM** with a single `QlipXStore: ObservableObject` as source of truth
- Store is injected via `@EnvironmentObject` — never instantiated inside a View
- Views never read from or write to disk directly
- Views never call `NSPasteboard` directly — always via `ClipboardManager`
- `PersistenceManager` is only called by `QlipXStore`, never by Views or Utilities
- Window is `NSPanel` (not `NSWindow`) with `.floating` level and `.nonactivatingPanel` style
- SwiftUI views are hosted in the panel via `NSHostingView`

# Coding Conventions
- All user-facing strings use `String(localized: "key", defaultValue: "English text")` — no hardcoded string literals in Views
- All keys must be registered in `Localizable.xcstrings`
- Use `UUID()` for all model IDs
- Date fields use ISO8601 encoding (`JSONEncoder.DateEncodingStrategy.iso8601`)
- Prefer `struct` over `class` for models; `class` only for `ObservableObject`
- File names match the type they contain exactly (e.g. `ItemRowView.swift` contains `ItemRowView`)

# Folder Structure
```
QlipX/
├── App/            ← QlipXApp.swift, AppDelegate.swift
├── Store/          ← QlipXStore.swift, PersistenceManager.swift
├── Models/         ← Category.swift, Item.swift
├── Views/
│   ├── MainPanel/  ← MainPanelView, CategoryTabsView, ItemListView,
│   │                  ItemRowView, AddItemFormView, FooterView
│   ├── AboutView.swift
│   └── ExportSheetView.swift
├── Utilities/      ← ColorPalette, ClipboardManager, ExportManager, MonospaceDetector
└── Resources/      ← Localizable.xcstrings, Assets.xcassets
```

# State Management Rules
- `QlipXStore` holds: `categories`, `searchQuery`, `selectedCategoryID`, `isAddFormVisible`
- All mutations are methods on `QlipXStore` — Views call store methods, not mutate state directly
- Persistence is debounced 300ms after any mutation; immediate save on `applicationWillTerminate`
- Window position and size persist via `UserDefaults` (not in `data.json`)
- Category color is stored as `colorIndex: Int` — resolved to `Color` via `ColorPalette.color(for:)`

# Styling Rules
- Follow system light/dark mode automatically via `NSAppearance` — never hardcode colors
- Window material: `NSVisualEffectView` with `.hudWindow` or `.popover`
- All icons: **SF Symbols only** — no external icon libraries
- Font: SF Pro system font throughout; monospace via `MonospaceDetector` for IPs, paths, URLs
- Minimum font size: 11pt anywhere in the UI
- Category dot colors cycle through 6 preset hex values (see `ColorPalette.swift`)
- Main window default size: 320×480pt · min: 280×360pt · max: 480×800pt

# Testing Rules
- v1.0: manual testing only, no automated test suite
- After each milestone, verify the specific checklist in `QlipX-ProductionPlan.md`
- Always test persistence: add data → quit app → relaunch → confirm data is intact
- Always test in both light mode and dark mode before closing a milestone
- Test copy action in: Terminal, Safari, Xcode, Finder

# Development Workflow
- Work milestone by milestone as defined in `QlipX-ProductionPlan.md`
- Current milestone always listed in `# Current Priorities` below
- Each session: one focused task only — avoid working on multiple milestones simultaneously
- Provide AI with: relevant PRD section + ARD section + current file + exact Xcode error text
- Commit after each milestone is verified working

# Things To Avoid
- Do NOT add clipboard history (monitoring what user copies from other apps) — out of scope
- Do NOT add iCloud sync or any network requests — app must be fully offline
- Do NOT add import functionality in v1.0
- Do NOT use `NSWindow` for the main panel — must be `NSPanel`
- Do NOT instantiate `QlipXStore` inside a View — inject via `@EnvironmentObject` only
- Do NOT write hardcoded UI strings — always use `String(localized:)`
- Do NOT call `NSPasteboard` directly from a View
- Do NOT enable App Sandbox (breaks global shortcuts and file access)
- Do NOT add automated tests in v1.0 — manual testing only
- Do NOT work on post-v1.0 features (Persian localization, import, custom shortcuts, iCloud)

# Current Priorities
- [x] **M1 — Project Setup:** Xcode project created, `LSUIElement=true`, SPM dependency added, folder structure in place, app launches with menu bar icon visible
- [x] **M2 — Core Data Model + Persistence:** models, store, JSON persistence, and window frame persistence are implemented
- [x] **M3 — Main Window UI Shell:** implemented
- [x] **M4 — Core UI:** implemented — `CategoryTabsView`, `ItemListView`, `ItemRowView`, `ColorPalette`, and `FooterView` are in place
- [x] **M5 — Item Management:** implemented — inline add/edit form, item delete confirmation, and in-category drag-and-drop reordering are in place
- [x] **M6 — Category Management:** implemented — category tab rename/delete flows, delete safeguards, and item move-on-delete are in place
- [x] **M7 — Search:** implemented — always-visible search bar, `⌘K` focus, live filtering, escape-to-clear, and no-results empty state are in place
- [x] **M8 — Export:** implemented — export sheet, title bar + menu bar access, JSON/plain text exports, and success confirmation are in place
- [ ] **M9 — About Window:**
```
