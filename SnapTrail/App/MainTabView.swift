import SwiftUI
import SwiftData

struct MainTabView: View {
    let services: AppServices

    var body: some View {
        TabView {
            TimelineView(
                viewModel: TimelineViewModel(memoryDataService: services.memoryDataService),
                services: services
            )
            .tabItem {
                Label("Timeline", systemImage: "house.fill")
            }

            CameraView(services: services)
                .tabItem {
                    Label("Capture", systemImage: "camera.fill")
                }

            ProfileView(
                viewModel: SettingsViewModel(notificationService: services.notificationService),
                services: services
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(Color.snapAccent)
    }
}

#Preview {
    MainTabView(services: AppServices(modelContext: PreviewContainer.context))
        .modelContainer(PreviewContainer.shared)
}
