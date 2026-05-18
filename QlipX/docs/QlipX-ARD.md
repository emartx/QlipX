# Architecture Requirements Document (ARD)
## QlipX — macOS Floating Snippet Manager

**Version:** 1.0.0  
**Status:** Draft  
**Last Updated:** 2026-05-13  
**Related Document:** QlipX-PRD.md v1.0.0

---

## 1. Architecture Overview

QlipX follows the **MVVM (Model-View-ViewModel)** pattern with a single centralized Store as the source of truth. All data flows in one direction: from the JSON file on disk → Store → Views. No View reads from or writes to disk directly.

```
┌─────────────────────────────────────────────────┐
│                   macOS System                  │
│   Global Shortcut (KeyboardShortcuts)           │
│   Clipboard (NSPasteboard)                      │
│   File System (~/Library/Application Support/)  │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│                  App Layer                      │
│   QlipXApp.swift      ← @main entry point       │
│   AppDelegate.swift   ← NSPanel + MenuBar setup │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│                 Store Layer                     │
│   QlipXStore (ObservableObject)                 │
│     └── PersistenceManager                      │
│           └── data.json                         │
└────────────────────┬────────────────────────────┘
                     │ @EnvironmentObject
┌────────────────────▼────────────────────────────┐
│                  View Layer                     │
│   MainPanelView                                 │
│     ├── CategoryTabsView                        │
│     ├── ItemListView → ItemRowView              │
│     ├── AddItemFormView                         │
│     └── FooterView                              │
│   AboutView                                     │
│   ExportSheetView                               │
└─────────────────────────────────────────────────┘
```

---

## 2. Technology Decisions

### 2.1 Programming Language: Swift

**Decision:** Swift is the sole programming language for QlipX.

**Why Swift:**

Swift is Apple's first-party language for macOS development, introduced in 2014 and now the primary language for all Apple platforms. For a macOS-native app like QlipX, Swift is the natural and optimal choice for the following reasons:

- **Native performance:** Swift compiles to native machine code. App launch time, window response, and clipboard operations are all in the sub-100ms range that QlipX targets, with no runtime overhead.
- **Full AppKit and SwiftUI access:** QlipX requires low-level macOS APIs (NSPanel, NSStatusBar, NSPasteboard, global event monitoring). Swift provides direct, first-class access to all of these without bridges or wrappers.
- **Memory safety:** Swift's ownership model eliminates entire classes of bugs (null pointer crashes, memory leaks) that would be concerns in Objective-C, making the codebase more stable and easier to maintain.
- **Longevity:** Apple actively develops Swift and all new macOS APIs are Swift-first. Objective-C is in maintenance mode. Building in Swift means QlipX stays compatible with future macOS versions with less effort.
- **Tooling:** Xcode's Swift support is first-class — debugging, profiling with Instruments, and code signing are all seamlessly integrated.

**Alternatives considered and rejected:**

| Alternative | Reason rejected |
|---|---|
| **Electron (JavaScript)** | Produces apps 150–300MB in size for trivial functionality. High memory usage (100MB+ RAM for a simple window). No native macOS look and feel. Global shortcuts and NSPanel-level floating require complex native bridges anyway. |
| **Flutter (Dart)** | macOS support is still maturing. Cannot access all AppKit APIs natively. Requires Dart runtime. Renders its own UI widgets — does not use native macOS controls, so the app would look non-native. |
| **Python (PyObjC / Rumps)** | Possible but requires bundling a Python runtime, increasing app size. Performance and startup time are significantly worse. Tooling for code signing and distribution is fragile. Better suited for scripts, not polished desktop apps. |
| **Objective-C** | Still fully capable, but verbose and lacks modern language features (generics, structured concurrency, string interpolation). All new Apple documentation and sample code is Swift-first. No benefit over Swift for a new project. |

---

### 2.2 UI Framework: SwiftUI + AppKit

**Decision:** SwiftUI for all views, with AppKit used only at the app boundary layer (NSPanel, NSStatusBar).

**Why SwiftUI:**
- Declarative syntax drastically reduces the amount of boilerplate code needed for building and updating UI
- Built-in support for light/dark mode, dynamic type, and accessibility with zero extra effort
- `@EnvironmentObject`, `@StateObject`, and `@Published` provide a clean reactive data flow matching MVVM
- Live Preview in Xcode accelerates UI iteration

**Why AppKit at the boundary:**
SwiftUI alone cannot create a floating `NSPanel`, configure `NSStatusBarButton`, or set window collection behavior. These are AppKit-only APIs. The approach used is:
- `AppDelegate` handles all AppKit-level setup (panel creation, menu bar icon, global shortcut registration)
- SwiftUI views are hosted inside the panel via `NSHostingView`
- No AppKit code appears inside any SwiftUI View file

This gives the best of both worlds: native macOS window management with a modern, maintainable view layer.

---

### 2.3 Architecture Pattern: MVVM with Single Store

**Decision:** One central `QlipXStore` ObservableObject shared across all views via `@EnvironmentObject`.

**Why a single Store instead of multiple ViewModels:**
QlipX's data is inherently global — the category list, item list, and search state all affect multiple views simultaneously. A single store avoids the need to synchronize state between multiple ViewModels and makes persistence straightforward: observe one object, write one file.

**Data flow rules (enforced throughout the codebase):**
1. Views never read from or write to disk
2. Views never call `NSPasteboard` directly
3. All mutations go through `QlipXStore` methods
4. `PersistenceManager` is only called by `QlipXStore`

---

### 2.4 External Dependencies

**Decision:** Exactly one external dependency — `KeyboardShortcuts` by Sindre Sorhus.

QlipX's core requirement of a **system-wide global keyboard shortcut** (working even when the app is not in focus) cannot be implemented with SwiftUI or standard AppKit APIs alone. It requires monitoring global CGEvents at the system level, which involves non-trivial low-level code.

`KeyboardShortcuts` is the standard solution used by hundreds of macOS apps (including Alfred, Raycast plugins, and others). It is:
- Open source (MIT license)
- Actively maintained
- Installable via Swift Package Manager with no other transitive dependencies
- Small: adds ~50KB to the final binary

**All other functionality uses Apple frameworks only:**

| Functionality | Framework |
|---|---|
| UI rendering | SwiftUI |
| Window/panel management | AppKit (NSPanel, NSWindow) |
| Menu bar icon | AppKit (NSStatusBar, NSStatusItem) |
| Clipboard write | AppKit (NSPasteboard) |
| File read/write | Foundation (FileManager, JSONEncoder) |
| Date formatting | Foundation (DateFormatter, ISO8601) |
| Color management | SwiftUI (Color) + AppKit (NSColor) |
| SF Symbols icons | SwiftUI (Image(systemName:)) |

**Dependency installation:**
```
Xcode → File → Add Package Dependencies
URL: https://github.com/sindresorhus/KeyboardShortcuts
Version: 2.x (latest stable)
```

---

## 3. Project Structure

```
QlipX/
├── App/
│   ├── QlipXApp.swift              ← @main, injects Store, creates AppDelegate
│   └── AppDelegate.swift           ← NSPanel setup, NSStatusBar, shortcut binding
│
├── Store/
│   ├── QlipXStore.swift            ← ObservableObject, all business logic
│   └── PersistenceManager.swift    ← encode/decode JSON, file I/O
│
├── Models/
│   ├── Category.swift              ← Category struct (Codable, Identifiable)
│   └── Item.swift                  ← Item struct (Codable, Identifiable)
│
├── Views/
│   ├── MainPanel/
│   │   ├── MainPanelView.swift     ← root view hosted in NSPanel
│   │   ├── CategoryTabsView.swift  ← horizontal tab bar for filtering
│   │   ├── ItemListView.swift      ← scrollable list, grouped by category
│   │   ├── ItemRowView.swift       ← single item row with copy button
│   │   ├── AddItemFormView.swift   ← inline add/edit form
│   │   └── FooterView.swift        ← stats + shortcut hint + avatar button
│   ├── AboutView.swift             ← developer info window
│   └── ExportSheetView.swift       ← export format selector sheet
│
├── Utilities/
│   ├── ColorPalette.swift          ← automatic color assignment logic
│   ├── ClipboardManager.swift      ← NSPasteboard wrapper
│   ├── ExportManager.swift         ← JSON and Plain Text export logic
│   └── MonospaceDetector.swift     ← regex-based font auto-detection
│
└── Resources/
    ├── Localizable.xcstrings       ← all UI strings (en locale, v1.0)
    └── Assets.xcassets             ← app icon, accent color
```

---

## 4. Data Architecture

### 4.1 In-Memory Model

```swift
// Root store object — single source of truth
class QlipXStore: ObservableObject {
    @Published var categories: [Category] = []
    @Published var searchQuery: String = ""
    @Published var selectedCategoryID: UUID? = nil   // nil = "All"
    @Published var isAddFormVisible: Bool = false

    // Computed
    var filteredItems: [Item] { ... }
}

// Models
struct Category: Codable, Identifiable {
    var id: UUID
    var name: String
    var colorIndex: Int          // index into ColorPalette.colors[]
    var items: [Item]
    var isExpanded: Bool = true  // collapse state in "All" view
}

struct Item: Codable, Identifiable {
    var id: UUID
    var content: String          // the text that gets copied
    var label: String?           // optional display title
    var createdAt: Date
    var order: Int               // sort position within category
}
```

### 4.2 Persistence

- **File location:** `~/Library/Application Support/QlipX/data.json`
- **Format:** Pretty-printed JSON (human-readable)
- **Write strategy:** Debounced — changes are written 300ms after the last mutation, preventing excessive disk writes during rapid interactions (e.g. reordering items)
- **Read strategy:** Once at app launch; all subsequent reads are from memory
- **Error handling:** If the file is missing on first launch, an empty store is created. If the file is corrupt (JSON parse failure), the user is alerted and offered to reset to empty

```swift
class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileURL: URL  // ~/Library/Application Support/QlipX/data.json
    private var debounceTimer: Timer?

    func load() -> QlipXStore { ... }
    func save(_ store: QlipXStore) { ... }        // debounced internally
    func saveImmediately(_ store: QlipXStore) { ... }  // used on app quit
}
```

### 4.3 Color Assignment

Colors are assigned automatically when a new category is created, cycling through a fixed palette:

```swift
struct ColorPalette {
    static let colors: [Color] = [
        Color(hex: "#185FA5"),  // Blue
        Color(hex: "#3B6D11"),  // Green
        Color(hex: "#993C1D"),  // Coral
        Color(hex: "#534AB7"),  // Purple
        Color(hex: "#BA7517"),  // Amber
        Color(hex: "#993556"),  // Pink
    ]

    static func color(for index: Int) -> Color {
        colors[index % colors.count]
    }
}
```

---

## 5. Key Technical Implementations

### 5.1 Floating Panel Setup

```swift
// AppDelegate.swift
let panel = NSPanel(
    contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
    styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
    backing: .buffered,
    defer: false
)
panel.level = .floating
panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
panel.isMovableByWindowBackground = true
panel.contentView = NSHostingView(rootView: MainPanelView()
    .environmentObject(store))
```

The `.nonactivatingPanel` style mask is critical — it allows the panel to receive clicks without stealing keyboard focus from whatever app the user is currently in.

### 5.2 Global Keyboard Shortcut

```swift
// AppDelegate.swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleQlipX = Self("toggleQlipX",
        default: .init(.space, modifiers: [.command, .shift]))
}

// Registration
KeyboardShortcuts.onKeyUp(for: .toggleQlipX) {
    self.togglePanel()
}
```

### 5.3 Clipboard Write

```swift
// ClipboardManager.swift
struct ClipboardManager {
    static func copy(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
```

### 5.4 Monospace Font Auto-Detection

Content text is rendered in monospace automatically when it matches known patterns:

```swift
// MonospaceDetector.swift
struct MonospaceDetector {
    private static let patterns: [String] = [
        #"^\d{1,3}(\.\d{1,3}){3}(:\d+)?$"#,   // IP address / IP:port
        #"^(/[\w.\-]+){2,}$"#,                  // Unix file path
        #"^[a-zA-Z][a-zA-Z0-9+\-.]*://"#,       // URL with scheme
        #"^[0-9a-fA-F:]{17}$"#,                 // MAC address
    ]

    static func isMonospace(_ text: String) -> Bool {
        patterns.contains { pattern in
            text.range(of: pattern, options: .regularExpression) != nil
        }
    }
}
```

### 5.5 Localization Pattern

All user-facing strings use `String(localized:)` with a string key and a default English value:

```swift
// Example usage in a View
Text(String(localized: "item.copy_button", defaultValue: "Copy"))
Button(String(localized: "form.add_button", defaultValue: "Add Item")) { ... }
```

All keys are registered in `Localizable.xcstrings`. Adding Persian or any other language in a future version requires only adding translation entries to this file — zero code changes.

---

## 6. Build & Distribution

### 6.1 Xcode Project Settings

| Setting | Value |
|---|---|
| Bundle Identifier | `com.emartx.qlipx` |
| Deployment Target | macOS 13.0 |
| Architectures | Apple Silicon + Intel (Universal) |
| Swift Version | 5.9+ |
| Code Signing | Developer ID (for direct distribution) |
| App Sandbox | Disabled (required for global shortcuts and file access outside sandbox) |

### 6.2 Info.plist Keys

```xml
<!-- Hide from Dock -->
<key>LSUIElement</key>
<true/>

<!-- Launch at Login (via SMAppService in macOS 13+) -->
<!-- Handled in code, no plist key required -->
```

`LSUIElement = true` is the key that makes QlipX a pure menu bar app with no Dock icon and no app menu bar.

### 6.3 Distribution

- v1.0: Direct download as a signed `.dmg`
- No Mac App Store (App Sandbox requirement conflicts with global shortcut and unrestricted file access)
- Notarization via Apple's notary service (required for Gatekeeper on end-user machines)

---

## 7. Architecture Decision Log

| # | Decision | Rationale |
|---|---|---|
| ADR-01 | Swift + SwiftUI as primary stack | Native performance, full API access, Apple-first longevity. All alternatives have significant trade-offs for a macOS-native tool. |
| ADR-02 | NSPanel instead of NSWindow | Only NSPanel supports floating level + non-activating behavior simultaneously |
| ADR-03 | Single QlipXStore (not per-view ViewModels) | Data is globally shared; single store simplifies sync and persistence |
| ADR-04 | One external dependency (KeyboardShortcuts) | Global shortcuts require system-level event monitoring not available in standard APIs; this library is the established solution |
| ADR-05 | JSON with pretty-print for storage | Human-readable without tools; easy to inspect and manually edit if needed |
| ADR-06 | Debounced writes (300ms) | Prevents excessive disk I/O during rapid mutations while still persisting quickly |
| ADR-07 | Localization from day one (en only) | Retrofitting localization later requires touching every string in the codebase; adding languages later requires only a translation file |
| ADR-08 | No App Sandbox | Global keyboard shortcuts and `~/Library/Application Support/` access are blocked by the sandbox; direct distribution allows opting out |
