import SwiftUI
import SwiftData

@main
struct SnapTrailApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            Memory.self,
            MemoryCategory.self
        ])
    }
}
