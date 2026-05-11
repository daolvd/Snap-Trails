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

    @State private var services: AppServices?

    private let locationManager = CLLocationManager()

    var body: some View {
        Group {
            if let services {
                if hasCompletedOnboarding && permissionsGranted {
                    MainTabView(services: services)
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                        checkPermissions()
                    }
                }
            }
        }
        .onAppear {
            if services == nil {
                services = AppServices(modelContext: modelContext)
            }
            checkPermissions()
        }
        .task {
            await services?.defaultDataService.createDefaultCategoriesIfNeeded()
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
