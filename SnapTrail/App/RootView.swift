import SwiftUI
import SwiftData
import AVFoundation
import CoreLocation

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage(AppConstants.hasCompletedOnboardingKey)
    private var hasCompletedOnboarding = false

    /// Tracks whether required permissions (camera + location) are granted.
    @State private var permissionsGranted = false

    private let locationManager = CLLocationManager()

    var body: some View {
        let memoryDataService = MemoryDataService(modelContext: modelContext)
        let categoryDataService = CategoryDataService(modelContext: modelContext)
        let defaultDataService = DefaultDataService(categoryDataService: categoryDataService)

        Group {
            if hasCompletedOnboarding && permissionsGranted {
                MainTabView(
                    memoryDataService: memoryDataService,
                    categoryDataService: categoryDataService
                )
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                    checkPermissions()
                }
            }
        }
        .task {
            await defaultDataService.createDefaultCategoriesIfNeeded()
        }
        .onAppear {
            checkPermissions()
        }
        // Re-check when app comes back to foreground (user may have changed settings)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkPermissions()
        }
    }

    /// Checks if both camera and location permissions are authorized.
    private func checkPermissions() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let locationStatus = locationManager.authorizationStatus

        let cameraOK = cameraStatus == .authorized
        let locationOK = locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways

        permissionsGranted = cameraOK && locationOK
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewContainer.shared)
}
