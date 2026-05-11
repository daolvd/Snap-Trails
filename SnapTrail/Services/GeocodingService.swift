import CoreLocation

protocol GeocodingServiceProtocol {
    func reverseGeocode(location: CLLocation) async -> String?
}

final class GeocodingService: GeocodingServiceProtocol {
    private let geocoder = CLGeocoder()
    private var cache: [String: String] = [:]

    func reverseGeocode(location: CLLocation) async -> String? {
        let precision = AppConstants.geocodingCacheCoordinatePrecision
        let key = String(format: "%.\(precision)f,%.\(precision)f",
            location.coordinate.latitude,
            location.coordinate.longitude)

        if let cached = cache[key] { return cached }

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            guard let place = placemarks.first else { return nil }

            let parts = [place.name, place.locality, place.administrativeArea]
                .compactMap { $0 }
                .filter { !$0.isEmpty }

            guard !parts.isEmpty else { return nil }

            let result = parts.joined(separator: ", ")
            cache[key] = result
            return result
        } catch {
            AppLog.warning(
                "Reverse-geocode failed: \(error.localizedDescription)",
                category: .location
            )
            return nil
        }
    }
}
