import SwiftUI
import AVFoundation
import CoreLocation
import Combine

struct OnboardingView: View {
    let onContinue: () -> Void

    @StateObject private var permissionHandler = PermissionHandler()

    var body: some View {
        ZStack {
            Color.snapBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                Text("SnapTrail")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(Color.snapAccent)
                    .padding(.top, 60)

                // Hero card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.snapCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )

                    VStack(spacing: 0) {
                        // Preview image placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.snapCardLight)

                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 64))
                                .foregroundColor(Color.snapAccent.opacity(0.4))

                            // Viewfinder overlay
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.snapAccent.opacity(0.5), lineWidth: 1)
                                .frame(width: 140, height: 140)
                        }
                        .frame(height: 260)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Feature badges
                        VStack(alignment: .leading, spacing: 10) {
                            featureBadge(icon: "location.fill", text: "LOCATION LINKED")
                            featureBadge(icon: "iphone", text: "DEVICE ONLY")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)

                        Spacer(minLength: 0)
                    }

                    // Corner icons
                    VStack {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundColor(Color.snapAccent)
                                .frame(width: 40, height: 40)
                                .background(Color.snapCardLight)
                                .clipShape(Circle())

                            Spacer()

                            Image(systemName: "mappin.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color.snapAccent)
                                .frame(width: 40, height: 40)
                                .background(Color.snapCardLight)
                                .clipShape(Circle())
                        }
                        .padding(20)

                        Spacer()
                    }
                }
                .frame(height: 400)
                .padding(.horizontal, 32)
                .padding(.top, 24)

                // Description
                VStack(spacing: 12) {
                    Text("Capture your reality.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.snapTextPrimary)

                    Text("Photos tied to coordinates. Stored completely offline in your private local storage. No cloud tracking.")
                        .font(.subheadline)
                        .foregroundColor(.snapTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 28)

                Spacer()

                // Permission status hints (shown after first attempt)
                if permissionHandler.showPermissionHint {
                    VStack(spacing: 6) {
                        if !permissionHandler.cameraGranted {
                            permissionRow(
                                icon: "camera.fill",
                                text: "Camera access required",
                                granted: false
                            )
                        }
                        if !permissionHandler.locationGranted {
                            permissionRow(
                                icon: "location.fill",
                                text: "Location access required",
                                granted: false
                            )
                        }

                        // If permissions were denied, show Settings button
                        if permissionHandler.needsSettings {
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Open Settings")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color.snapAccent)
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // Continue button
                PrimaryButton(title: "Continue", systemImage: "arrow.right") {
                    permissionHandler.requestAllPermissions {
                        onContinue()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: permissionHandler.showPermissionHint)
    }

    private func featureBadge(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color.snapAccent)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.snapTextPrimary)
                .tracking(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.snapCardLight)
        .clipShape(Capsule())
    }

    private func permissionRow(icon: String, text: String, granted: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(granted ? .green : .orange)
            Text(text)
                .font(.caption)
                .foregroundColor(granted ? .green : .orange)
            Spacer()
            Image(systemName: granted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(granted ? .green : .orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.snapCard)
        .cornerRadius(12)
    }
}

// MARK: - Permission Handler

@MainActor
final class PermissionHandler: ObservableObject {
    @Published var cameraGranted = false
    @Published var locationGranted = false
    @Published var showPermissionHint = false
    @Published var needsSettings = false

    private let locationManager = CLLocationManager()

    /// Requests camera and location permissions, then calls completion.
    func requestAllPermissions(completion: @escaping () -> Void) {
        requestCameraPermission {
            self.requestLocationPermission {
                self.updateStatus()
                if self.cameraGranted && self.locationGranted {
                    completion()
                } else {
                    // Show hints about what's missing
                    self.showPermissionHint = true
                    self.checkIfNeedsSettings()
                }
            }
        }
    }

    private func requestCameraPermission(completion: @escaping () -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in
                Task { @MainActor in
                    self.updateStatus()
                    completion()
                }
            }
        default:
            cameraGranted = status == .authorized
            completion()
        }
    }

    private func requestLocationPermission(completion: @escaping () -> Void) {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            // CLLocationManager needs a delegate for async authorization
            let delegate = LocationPermissionDelegate {
                self.updateStatus()
                completion()
            }
            locationManager.delegate = delegate
            // Store delegate reference to prevent deallocation
            _locationDelegate = delegate
            locationManager.requestWhenInUseAuthorization()
        default:
            locationGranted = status == .authorizedWhenInUse || status == .authorizedAlways
            completion()
        }
    }

    private var _locationDelegate: LocationPermissionDelegate?

    private func updateStatus() {
        cameraGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        let locStatus = locationManager.authorizationStatus
        locationGranted = locStatus == .authorizedWhenInUse || locStatus == .authorizedAlways
    }

    private func checkIfNeedsSettings() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let locationStatus = locationManager.authorizationStatus

        // If either permission has been explicitly denied/restricted, user needs to go to Settings
        let cameraDenied = cameraStatus == .denied || cameraStatus == .restricted
        let locationDenied = locationStatus == .denied || locationStatus == .restricted

        needsSettings = cameraDenied || locationDenied
    }
}

// MARK: - Location Permission Delegate

private class LocationPermissionDelegate: NSObject, CLLocationManagerDelegate {
    private let onChange: () -> Void

    init(onChange: @escaping () -> Void) {
        self.onChange = onChange
        super.init()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Only fire callback once a decision is made
        if manager.authorizationStatus != .notDetermined {
            Task { @MainActor in
                self.onChange()
            }
        }
    }
}

#Preview {
    OnboardingView {
        print("Continue tapped")
    }
}
