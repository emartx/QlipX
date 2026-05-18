# Product Requirements Document (PRD)
## QlipX — macOS Floating Snippet Manager

**Version:** 1.0.0  
**Status:** Draft  
**Last Updated:** 2026-05-11

---

## 1. Overview

### 1.1 Product Summary

QlipX (Quick + Clip + X) is a lightweight macOS menu bar application that provides a floating, always-on-top window for storing and instantly copying frequently used text snippets. It targets power users who repeatedly enter the same data across forms, terminals, and applications — such as IP addresses, file paths, contact information, and credentials.

### 1.2 Problem Statement

macOS users frequently need to re-enter the same text across different applications: server IP addresses in terminal sessions, email addresses in forms, file paths in dialogs, and contact details in documents. The native clipboard holds only one item and has no persistent memory. Existing clipboard managers focus on clipboard history rather than intentional, organized storage of reusable snippets.

### 1.3 Target User

- **Primary:** The developer/creator (personal tool)
- **Secondary:** Technical and power users on macOS who manage repetitive text data daily

### 1.4 Goals

- Zero friction: copy any stored snippet in one click
- Always accessible: available on top of any application at any time
- Organized: items grouped into named categories
- Minimal: no bloat, no accounts, no cloud dependency

---

## 2. Functional Requirements

### 2.1 Menu Bar Integration

- The app lives exclusively in the macOS menu bar (no Dock icon)
- Menu bar icon: a simple clipboard or custom icon representing the app
- Clicking the menu bar icon shows a dropdown menu with the following items:
  - **Show Window** — `⌘⇧Space`
  - **New Item**
  - **Export**
  - **About QlipX**
  - *(separator)*
  - **Quit** — `⌘Q`
- The app launches at login by default (configurable)

### 2.2 Floating Window

- Implemented as `NSPanel` (not `NSWindow`) so it can float above all other windows
- `collectionBehavior` set to `.canJoinAllSpaces` and `.fullScreenAuxiliary`
- `level` set to `.floating`
- Window is resizable and remembers its last position and size between launches
- Window can be toggled show/hide with the global keyboard shortcut `⌘⇧Space` from any application
- Window does not appear in Mission Control or the app switcher (`⌘Tab`)
- Closing the window (red button) hides it; does not quit the app

### 2.3 Category Management

- Items are organized into user-defined categories
- Each category has:
  - A name (string, required, unique)
  - A color dot assigned automatically from a predefined palette (cycled in order)
- Categories are displayed as:
  - Tabs across the top of the item list (filter view)
  - Collapsible group headers within the "All" view
- Users can create a new category inline from the "Add Item" form by typing a new name in the category field
- Categories can be renamed or deleted via right-click context menu on the tab
- Deleting a category prompts the user: delete items too, or move to another category

### 2.4 Item Management

Each item has the following fields:

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | UUID | Yes | Auto-generated |
| `content` | String | Yes | The text that gets copied to clipboard |
| `category` | String | Yes | Must match an existing category name |
| `label` | String | No | Short descriptive title shown above content |
| `createdAt` | Date | Yes | Auto-generated |
| `order` | Int | Yes | For manual sort ordering within category |

**Adding an item:**
- Clicking `+` in the window header opens an inline add form (not a separate window)
- Fields: Category (combobox — select existing or type new), Content (required), Label (optional)
- Pressing `Return` in the Content field submits the form if Category is filled
- Pressing `Escape` cancels

**Copying an item:**
- Clicking the "Copy" button copies `content` to the system clipboard
- The button briefly shows "✓ Copied" for 1.4 seconds, then reverts
- No other action is taken (no window hide, no notification)

**Editing an item:**
- Right-click on any item row shows a context menu: Copy / Edit / Delete
- Edit opens the same inline form pre-filled with current values

**Deleting an item:**
- Right-click → Delete shows a confirmation alert before removing

**Reordering:**
- Items within a category can be reordered via drag-and-drop

### 2.5 Search

- A search bar is always visible below the window title bar
- Triggered also by `⌘K` (focuses the search field)
- Searches across both `content` and `label` fields
- Filtering is live (results update as user types)
- Pressing `Escape` clears the search

### 2.6 Export

- Accessible from: menu bar dropdown → Export, and the `↑` icon in the window title bar
- A small sheet appears with two export options:
  - **Export as JSON** — exports full structured data
  - **Export as Plain Text** — exports human-readable flat format
- Files are saved to `~/Downloads/` with filename `QlipX-export-YYYY-MM-DD.json` or `.txt`
- No import functionality in v1.0

**Plain Text format example:**
```
=== Network ===

192.168.1.100
Staging: 192.168.1.200

=== Personal ===

Email: name@company.com
/Users/me/Projects/myapp
```

**JSON format example:**
```json
{
  "exportedAt": "2026-05-11T10:00:00Z",
  "version": "1.0",
  "categories": [
    {
      "name": "Network",
      "items": [
        {
          "content": "192.168.1.100",
          "label": null,
          "createdAt": "2026-05-01T08:00:00Z"
        }
      ]
    }
  ]
}
```

### 2.7 About Window

- Accessible from: menu bar → About QlipX, and the developer avatar icon in the bottom-left of the main window
- Displayed as a small, non-resizable secondary window
- Contains:
  - App icon
  - App name: **QlipX**
  - Version number (pulled from `Bundle.main.infoDictionary`)
  - Developer name
  - Website link (opens in default browser)
  - GitHub link (opens in default browser)

---

## 3. Non-Functional Requirements

### 3.1 Performance

- App launch time: under 0.5 seconds to menu bar icon appearing
- Window show/hide: under 100ms response to shortcut
- All UI interactions (copy, search, add): under 50ms perceived response

### 3.2 Storage

- Data stored locally at: `~/Library/Application Support/QlipX/data.json`
- File written on every change (no manual save required)
- File is pretty-printed JSON for human readability
- No iCloud sync, no network access of any kind

### 3.3 Privacy & Security

- No analytics, no telemetry, no network requests
- Clipboard access only on explicit user action (copy button click)
- No Sandboxing restrictions that would block file access to `~/Library/Application Support/`

### 3.4 Localization

- UI language: **English (en)** for v1.0
- All user-facing strings must use `String(localized:)` or `LocalizedStringKey` — no hardcoded string literals in views
- `Localizable.xcstrings` file must be present and complete for `en`
- Additional languages (e.g. Persian/fa) can be added in future versions by adding translation entries only — no code changes required

### 3.5 Compatibility

- **Minimum macOS version:** macOS 13 Ventura
- **Architecture:** Universal Binary (Apple Silicon + Intel)
- **Distribution:** Direct download (not Mac App Store in v1.0)

---

## 4. UI/UX Specifications

### 4.1 Main Window Dimensions

- Default size: 320 × 480 pt
- Minimum size: 280 × 360 pt
- Maximum size: 480 × 800 pt

### 4.2 Color System

Category dot colors are assigned automatically in this cycle order:

| Index | Color |
|---|---|
| 0 | `#185FA5` (Blue) |
| 1 | `#3B6D11` (Green) |
| 2 | `#993C1D` (Coral) |
| 3 | `#534AB7` (Purple) |
| 4 | `#BA7517` (Amber) |
| 5 | `#993556` (Pink) |

When all 6 are used, the cycle repeats.

### 4.3 Typography

- System font (`SF Pro`) throughout
- Content text: 13pt regular, monospaced for items that look like IPs/paths (auto-detect)
- Label text: 11pt, secondary color
- Category headers: 12pt medium weight
- Minimum font size anywhere: 11pt

### 4.4 Iconography

- All icons: SF Symbols (system-native, no external icon library)
- Copy button: `doc.on.doc`
- Add: `plus`
- Export: `square.and.arrow.up`
- Search: `magnifyingglass`
- Settings/menu: `ellipsis`
- Developer avatar: `person.circle`

### 4.5 Appearance

- Follows system light/dark mode automatically (`NSAppearance`)
- Window material: `NSVisualEffectView` with `.hudWindow` or `.popover` material for a native floating feel
- No custom window chrome — standard macOS traffic lights

---

## 5. Data Model

```swift
struct QlipXStore: Codable {
    var version: String
    var categories: [Category]
}

struct Category: Codable, Identifiable {
    var id: UUID
    var name: String
    var colorIndex: Int
    var items: [Item]
}

struct Item: Codable, Identifiable {
    var id: UUID
    var content: String
    var label: String?
    var createdAt: Date
    var order: Int
}
```

---

## 6. Out of Scope (v1.0)

The following features are explicitly excluded from v1.0:

- Clipboard history (monitoring what the user copies from other apps)
- iCloud or any remote sync
- Import functionality
- Rich text or image storage
- Item search by category filter simultaneously
- Keyboard-only navigation within the item list
- Multiple windows
- iOS / iPadOS companion app
- Mac App Store distribution
- In-app language switching UI (language follows system setting)

---

## 7. Success Criteria

- App installs and launches without errors on macOS 13+
- Global shortcut `⌘⇧Space` toggles window from any app
- Items persist correctly across app restarts
- Copy action works correctly in all tested apps (terminal, browser, Xcode, Finder)
- Export produces valid, readable files in both formats
- No crashes during normal use over a 7-day period
