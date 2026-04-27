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

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async throws -> CLLocation {
        authorizationStatus = manager.authorizationStatus
        errorMessage = nil

        switch manager.authorizationStatus {
        case .notDetermined:
            requestPermission()
            throw AppError.permissionDenied

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
