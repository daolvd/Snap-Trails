import CoreLocation
import Combine
import Foundation

@MainActor
final class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoadingLocation: Bool = false
    @Published var errorMessage: String?

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private var pendingPermissionContinuation: CheckedContinuation<CLLocation, Error>?

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async throws -> CLLocation {
        authorizationStatus = manager.authorizationStatus
        errorMessage = nil

        switch manager.authorizationStatus {
        case .notDetermined:
            // Don't throw immediately — store the continuation and wait
            return try await withCheckedThrowingContinuation { continuation in
                self.pendingPermissionContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }

        case .restricted, .denied:
            throw AppError.permissionDenied

        case .authorizedAlways, .authorizedWhenInUse:
            break

        @unknown default:
            throw AppError.locationUnavailable
        }

        isLoadingLocation = true

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus

            // Resume the pending permission wait if the user just granted access
            if let pending = self.pendingPermissionContinuation {
                switch manager.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.pendingPermissionContinuation = nil
                    self.isLoadingLocation = true
                    // Now actually request the location
                    self.continuation = pending
                    manager.requestLocation()
                case .denied, .restricted:
                    self.pendingPermissionContinuation = nil
                    pending.resume(throwing: AppError.permissionDenied)
                default:
                    break
                }
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        Task { @MainActor in
            self.isLoadingLocation = false

            guard let location = locations.last else {
                self.errorMessage = AppError.locationUnavailable.localizedDescription
                self.continuation?.resume(throwing: AppError.locationUnavailable)
                self.continuation = nil
                return
            }

            self.currentLocation = location
            self.continuation?.resume(returning: location)
            self.continuation = nil
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            self.isLoadingLocation = false
            self.errorMessage = AppError.locationUnavailable.localizedDescription
            self.continuation?.resume(throwing: AppError.locationUnavailable)
            self.continuation = nil
        }
    }
}
