import SwiftUI
import SwiftData

struct MainTabView: View {
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    var body: some View {
        TabView {
            TimelineView(
                viewModel: TimelineViewModel(memoryDataService: memoryDataService)
            )
            .tabItem {
                Label("Timeline", systemImage: "house.fill")
            }

            CameraView(
                memoryDataService: memoryDataService,
                categoryDataService: categoryDataService
            )
            .tabItem {
                Label("Capture", systemImage: "camera.fill")
            }

            ProfileView(
                viewModel: SettingsViewModel(),
                memoryDataService: memoryDataService
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(Color.snapAccent)
    }
}

#Preview {
    MainTabView(
        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}
