# SnapTrail

> A location-aware photo journal that turns everyday snapshots into a meaningful timeline of memories.

SnapTrail is an iOS application built for **41889 - iOS Application Development (Spring 2026)** at the University of Technology Sydney as **Assessment Task 3 — Group Project**.

**GitHub Repository:** https://github.com/daolvd/SnapTrail
**Branch:** `dev`

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

**Solution.** SnapTrail captures a photo together with its location, time, an optional caption and a user-defined category, then presents the result as a browsable timeline, an interactive map of memories, a search experience, and a favourites collection.

---

## 3. Key Features

- **Capture flow** — take a photo with the in-app camera; location and reverse-geocoded place name are attached automatically.
- **Timeline** — memories grouped by **Year / Month / Day** with section headers.
- **Map view** — every memory pinned on a map for spatial recall.
- **Search & filter** — full-text caption search plus filters by category, date range and favourites (uses SwiftData `#Predicate`).
- **Categories** — user-managed tags (Study, Food, Travel, …) with custom names.
- **Favourites** — mark and revisit your best memories.
- **Edit & delete** — update caption, category and favourite status of any past memory.
- **Profile & export** — view stats and export photos out of the app.
- **Onboarding & permissions** — first-run flow that requests Camera and Location access.
- **Local notifications** — gentle reminders to capture today's memory.

---

## 4. iOS Frameworks Used

The project demonstrates how several first-party Apple frameworks combine to solve the problem above.

| Framework | Where it's used | What it solves |
| --- | --- | --- |
| **SwiftUI** | All `Views/` | Declarative UI, navigation, state binding |
| **SwiftData** | `Models/Memory.swift`, `Models/MemoryCategory.swift`, `Services/*DataService.swift` | On-device persistence with `@Model`, `@Attribute(.unique)`, `@Relationship`, `#Predicate` |
| **Core Location** | `Services/LocationService.swift` | Acquiring the user's coordinates at capture time |
| **MapKit** | Map view of memories | Rendering memory pins on a map |
| **AVFoundation** | `Views/Camera/`, permission checks | Camera capture and authorisation status |
| **PhotosUI / UIKit interop** | Capture & export flow | Image picking, sharing |
| **UserNotifications** | `Services/NotificationService.swift` | Local reminder notifications |
| **Combine** | ViewModels with `@Published` | Reactive state pipeline between Services → ViewModels → Views |
| **Foundation (FileManager)** | `Services/ImageStorageService.swift` | Storing JPEG images in the app's documents directory |
| **CLGeocoder** | `Services/GeocodingService.swift` | Reverse geocoding coordinates into a human-readable place name |

---

## 5. Architecture

SnapTrail follows an **MVVM + Service layer** pattern with clear, one-direction dependencies:

```
Views  ──▶  ViewModels  ──▶  Services  ──▶  SwiftData / FileManager / CoreLocation
            (@MainActor)     (protocol-based, injected)
```

```
SnapTrail/
├── App/                  # App entry, RootView, permission gating
├── Models/               # Memory, MemoryCategory, TimelineGroup
├── Services/             # Persistence, location, geocoding, image storage, notifications
│   ├── MemoryDataService(+Protocol).swift
│   ├── CategoryDataService(+Protocol).swift
│   ├── LocationService.swift
│   ├── GeocodingService.swift
│   ├── ImageStorageService.swift
│   ├── NotificationService.swift
│   ├── UserProfileService.swift
│   └── DefaultDataService.swift
├── ViewModels/           # One ViewModel per feature screen
├── Views/                # SwiftUI views, grouped by feature
│   ├── Onboarding/  Camera/  SaveMemory/  Timeline/
│   ├── MemoryDetail/  Search/  Favorites/  Profile/  Components/
├── Core/                 # Cross-cutting helpers, AppError
├── Resources/            # Assets, Info.plist values
└── Assets.xcassets/
```

Key design decisions:

- **Dependency injection** — `MemoryDataService` and `CategoryDataService` are constructed in `RootView` from the active `modelContext` and passed down, so views never touch SwiftData directly.
- **Protocol abstractions** (`MemoryDataServiceProtocol`, `CategoryDataServiceProtocol`) enable mocking and isolated testing.
- **`@MainActor`** on all ViewModels and Services ensures UI-thread safety for SwiftData and Combine publishers.
- **Centralised `AppError`** (`Core/`) with `LocalizedError` conformance for user-facing messages.

---

## 6. Product Design Cycle

We followed an iterative plan → prototype → test loop across the semester:

1. **Discover** — interviewed the persona, defined the "lost context of photos" problem.
2. **Sketch** — low-fi wireframes for capture, timeline, detail and search (see `design/`).
3. **Prototype v1** — onboarding, capture flow, basic timeline.
4. **Prototype v2** — search with `#Predicate`, favourites, categories, map view.
5. **Polish** — profile, export, edit existing memories, redesigned profile page.
6. **Hardening** — hotfixes for image sizing, padding, navigation overlap and edge cases (see PR history).

Each iteration was integrated through pull requests on GitHub (see Section 8).

---

## 7. Build & Run

### Requirements
- macOS with **Xcode 15.0+**
- **iOS 17.0+** simulator or device (SwiftData requires iOS 17)
- Apple ID for code-signing on a physical device

### Steps
1. Clone the repository or unzip the submitted archive.
   ```bash
   git clone https://github.com/daolvd/SnapTrail.git
   cd SnapTrail
   ```
2. Open `SnapTrail.xcodeproj` in Xcode.
3. Select an iOS 17+ simulator (e.g. *iPhone 15 Pro*) **or** a connected physical device.
4. Press **⌘R** to build and run.
5. On first launch, accept the **Camera** and **Location** permission prompts so capture and reverse geocoding work.

> The Camera feature requires a physical device. On the simulator you can still browse the timeline, search, manage categories and favourites with seeded sample data.

---

## 8. Collaboration on GitHub

Development used a **feature-branch + pull-request** workflow with `main` as the stable branch and `dev` as the integration branch.

Representative branches:
- `feature/onboarding`, `feature/capture-flow`, `feature/timeline-memory-detail`
- `hotfix/fix-imagesize`, `hotfix/detail-padding-issue`, `hotfix/fix-back-in-favorite`
- `refactor/app-structure-and-views`

Merged pull requests (excerpt): #2–#12 covering onboarding, capture flow, search, profile redesign and editing of previous snaps. Each PR was reviewed by another team member before being merged.

---

## 9. Repository Contents

| Path | Purpose |
| --- | --- |
| `SnapTrail/` | Source code (Swift + SwiftUI) |
| `SnapTrail.xcodeproj/` | Xcode project |
| `README.md` | This document |

---