# SnapTrail

> A location-aware photo journal that turns everyday snapshots into a meaningful timeline of memories.

SnapTrail is an iOS application built for **41889 – iOS Application Development (Spring 2026)** at the University of Technology Sydney as **Assessment Task 3 — Group Project**.

**GitHub Repository:** https://github.com/daolvd/SnapTrail
**Default branch:** `main` &nbsp;·&nbsp; **Integration branch:** `dev`

---

## 1. Team Members

| Name | GitHub |
| --- | --- |
| Le Dao Van | [@daolvd](https://github.com/daolvd) / [@vandaole](https://github.com/vandaole) |
| Vu Quang Huy | [@vuquanghuy1998](https://github.com/vuquanghuy1998) |
| Niramon | [@niramongit](https://github.com/niramongit) |
| Sammi Lyu | [@Sammi-Lyu](https://github.com/Sammi-Lyu) |

---

## 2. Problem & User Persona

**Persona — "Maya, 24, design student & solo traveller."**
Maya takes hundreds of photos every month from cafés, hikes, classes and short trips. Her camera roll quickly turns into an unstructured pile where she can no longer remember *where* a photo was taken or *why* it mattered. Existing photo apps are organised around files and dates, not stories.

**Problem.** Casual photo-takers lose the *context* of their photos — the place, the moment, and the personal note that made the photo worth keeping.

**Solution.** SnapTrail captures a photo together with its location, time, an optional caption and a user-defined category, then presents the result as a browsable Year / Month / Day timeline, a search experience, and a favourites collection.

---

## 3. Key Features

- **Capture flow** — take a photo with the in-app camera; the user's coordinates are acquired live and reverse-geocoded into a human-readable place name.
- **Timeline with display modes** — toggle between **Years**, **Months** and **Days** views. Grouping logic lives in a pure helper (`TimelineGrouper`) so it can be unit-tested independently of any ViewModel.
- **Search & filter** — full-text caption search plus filters by category, date range, and favourites — implemented with SwiftData `#Predicate`.
- **Categories** — user-managed tags with **custom names and custom hex colours**, seeded from `Resources/DefaultCategories.json` on first launch.
- **Favourites** — one-tap mark / unmark, with a dedicated tab.
- **Edit & delete** — update caption, category, date, location and favourite status of any past memory.
- **Profile & export** — view stats and export photos out of the app.
- **Onboarding & permissions** — first-run flow that requests Camera and Location access, with automatic re-check when returning from Settings.
- **Local notifications** — opt-in daily reminder to capture today's memory (configurable in Settings).

Screens (in [screenshots/](screenshots/)): onboarding, capture, upload, memory detail, edit memory, timeline (days / months / years), search, favourites, manage categories, profile.

---

## 4. iOS Frameworks Used

| Framework | Where it's used | What it solves |
| --- | --- | --- |
| **SwiftUI** | All `Views/` | Declarative UI, navigation, state binding |
| **SwiftData** | [Models/](SnapTrail/Models/), [Services/MemoryDataService.swift](SnapTrail/Services/MemoryDataService.swift), [Services/CategoryDataService.swift](SnapTrail/Services/CategoryDataService.swift) | On-device persistence with `@Model`, `@Attribute(.unique)`, `@Relationship`, `#Predicate` |
| **Core Location** | [Services/LocationService.swift](SnapTrail/Services/LocationService.swift) | Acquiring user coordinates at capture time |
| **CLGeocoder** | [Services/GeocodingService.swift](SnapTrail/Services/GeocodingService.swift) | Reverse geocoding coordinates → place name, with an in-memory cache keyed by truncated coordinates |
| **AVFoundation** | [Views/Camera/](SnapTrail/Views/Camera/), permission checks in [App/RootView.swift](SnapTrail/App/RootView.swift) | Camera capture and authorisation status |
| **PhotosUI / UIKit interop** | Capture & export flow | `UIImagePickerController` bridge, share sheet |
| **UserNotifications** | [Services/NotificationService.swift](SnapTrail/Services/NotificationService.swift) | Daily reminder notifications |
| **Combine** | ViewModels with `@Published`, `LocationService` publishers | Reactive Services → ViewModels → Views pipeline |
| **Foundation (FileManager)** | [Services/ImageStorageService.swift](SnapTrail/Services/ImageStorageService.swift) | Storing JPEG images in the app's documents directory |
| **OSLog** | [Core/AppLog.swift](SnapTrail/Core/AppLog.swift) | Structured diagnostic logging — no silent `catch {}` blocks |

---

## 5. Architecture

SnapTrail follows an **MVVM + Service layer** pattern with strict one-direction dependencies:

```
Views  ──▶  ViewModels  ──▶  Services (protocols)  ──▶  SwiftData / FileManager / Core Location
            (@MainActor)        ▲
                                │
                          AppServices (DI container, built once in RootView)
```

```
SnapTrail/
├── App/
│   ├── SnapTrailApp.swift         # @main, ModelContainer
│   ├── RootView.swift             # Onboarding gate, permission re-check
│   ├── AppServices.swift          # DI container — owns service instances
│   └── MainTabView.swift          # Tab scaffolding
├── Models/                        # @Model entities + value types
│   ├── Memory.swift
│   ├── MemoryCategory.swift
│   ├── GeoLocation.swift          # value type extracted from Memory
│   └── TimelineGroup.swift        # Year / Month / Day grouping structs
├── Services/                      # Protocol-driven side-effect layer
│   ├── MemoryDataService(+Protocol).swift
│   ├── CategoryDataService(+Protocol).swift
│   ├── ImageStorageService.swift
│   ├── LocationService.swift
│   ├── GeocodingService.swift
│   ├── NotificationService.swift
│   ├── UserProfileService.swift
│   └── DefaultDataService.swift   # seeds DefaultCategories.json on first launch
├── ViewModels/                    # One @MainActor ViewModel per feature
├── Views/                         # SwiftUI views grouped by feature
│   ├── Onboarding/  Camera/  SaveMemory/  Timeline/  MemoryDetail/
│   ├── Search/  Favorites/  Profile/  Categories/  Components/
│   └── Timeline/Components/       # YearCard, MonthCard, DaySection, etc.
├── Core/                          # Cross-cutting helpers
│   ├── AppConstants.swift         # tunable values (limits, keys, identifiers)
│   ├── AppError.swift             # LocalizedError, localization-ready
│   ├── AppLog.swift               # OSLog façade
│   ├── TimelineGrouper.swift      # pure grouping logic
│   ├── DateFormatterHelper.swift
│   ├── CategoryPalette.swift      # hex helpers
│   ├── DefaultCategoryConfig.swift
│   ├── Color+App.swift
│   ├── PreviewContainer.swift     # in-memory ModelContainer for #Preview
│   └── TimelinePreviewData.swift  # seeded samples for previews
├── Resources/
│   └── DefaultCategories.json     # seeded on first launch
└── Assets.xcassets/
```

### Key design decisions

- **Single DI container (`AppServices`)** — services are built once in `RootView` from the live `ModelContext` and passed down. No singletons, and no per-render re-allocation (a previous bug where `LocationService` was recreated on every body evaluation, dropping its Combine subscriptions).
- **Protocol-driven services** — every service has a matching `…Protocol`, so ViewModels can be unit-tested against fakes without touching SwiftData.
- **`@MainActor` on ViewModels and Services** that touch `ModelContext` or `@Published` state — data-race classes of bug ruled out at compile time.
- **Validating value types** — `GeoLocation.init?(coordinate:name:)` rejects out-of-range coordinates so invalid data never reaches SwiftData.
- **Pure helpers for testable logic** — Year / Month / Day grouping lives in `TimelineGrouper` (a side-effect-free `enum`), independent of any ViewModel.
- **Centralised configuration (`AppConstants`)** — caption limits, image size cap, JPEG quality, reminder schedule and `UserDefaults` keys live in one place instead of being scattered as magic numbers.
- **No silent `catch {}`** — every swallowed error path goes through `AppLog.error(_:category:error:)` (OSLog), filterable in Console.app.
- **Localization-ready errors** — `AppError` messages flow through `String(localized:defaultValue:)`, so adding a language is an `.xcstrings` change, not a code change.

---

## 6. Product Design Cycle

We followed an iterative plan → prototype → test loop across the semester:

1. **Discover** — interviewed the persona, defined the "lost context of photos" problem.
2. **Sketch** — low-fi wireframes for capture, timeline, detail and search.
3. **Prototype v1** — onboarding, capture flow, basic timeline (PRs #2–#7).
4. **Prototype v2** — search with `#Predicate`, favourites, categories (PRs #8–#12).
5. **Polish** — profile redesign, photo export, editing previous snaps, custom category colours, dual-pane Year/Month/Day timeline (PRs #13–#15).
6. **Hardening & refactor** — extract `AppServices`, protocol abstractions, `AppLog`, `AppConstants`, `TimelineGrouper`; tighten validation, localization-ready errors (PRs #16–#17).


---

## 7. Build & Run

### Requirements
- macOS with **Xcode 15.0+**
- **iOS 17.0+** simulator or device (SwiftData requires iOS 17)
- Apple ID for code-signing on a physical device

### Steps
1. Clone the repository (or unzip the submitted archive).
   ```bash
   git clone https://github.com/daolvd/SnapTrail.git
   cd SnapTrail
   ```
2. Open `SnapTrail.xcodeproj` in Xcode.
3. Select an iOS 17+ simulator (e.g. *iPhone 15 Pro*) **or** a connected physical device.
4. Press **⌘R** to build and run.
5. On first launch, accept the **Camera** and **Location** permission prompts so capture and reverse geocoding work. If you decline either, `RootView` will keep you on the onboarding gate and re-check permissions whenever the app returns to the foreground.

> The Camera feature requires a physical device. On the simulator you can still browse the timeline, search, manage categories and favourites — sample data is seeded into a `PreviewContainer` for SwiftUI previews.

---

## 8. Collaboration on GitHub

Development used a **feature-branch + pull-request** workflow with `main` as the stable branch and `dev` as the integration branch.

Representative branches:
- `feature/onboarding`, `feature/capture-flow`, `feature/timeline-memory-detail`
- `hotfix/fix-imagesize`, `hotfix/detail-padding-issue`, `hotfix/fix-back-in-favorite`, `hotfix/fix-backbutton`
- `refactor/app-structure-and-views`, `refactor/polish-before-submit`

Merged pull requests #2–#17 cover onboarding, capture flow, search, profile redesign, editing previous snaps, custom-colour category management and the final pre-submission refactor. Each PR was reviewed by another team member before being merged.

---

## 9. Repository Contents

| Path | Purpose |
| --- | --- |
| [SnapTrail/](SnapTrail/) | Source code (Swift + SwiftUI) |
| [SnapTrail.xcodeproj/](SnapTrail.xcodeproj/) | Xcode project |
| [screenshots/](screenshots/) | App screenshots referenced from this README |
| [README.md](README.md) | This document |

---
