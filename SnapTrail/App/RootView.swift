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

    @State private var memoryDataService: MemoryDataService?
    @State private var categoryDataService: CategoryDataService?
    @State private var defaultDataService: DefaultDataService?

    private let locationManager = CLLocationManager()

    var body: some View {
        Group {
            if let memoryDS = memoryDataService, let categoryDS = categoryDataService {
                if hasCompletedOnboarding && permissionsGranted {
                    MainTabView(
                        memoryDataService: memoryDS,
                        categoryDataService: categoryDS
                    )
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                        checkPermissions()
                    }
                }
            }
        }
        .onAppear {
            // Only created once — modelContext is stable after first appear
            if memoryDataService == nil {
                let memoryDS = MemoryDataService(modelContext: modelContext)
                let categoryDS = CategoryDataService(modelContext: modelContext)
                memoryDataService = memoryDS
                categoryDataService = categoryDS
                defaultDataService = DefaultDataService(categoryDataService: categoryDS)
            }
            checkPermissions()
        }
        .task {
            await defaultDataService?.createDefaultCategoriesIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.willEnterForegroundNotification)
        ) { _ in
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
