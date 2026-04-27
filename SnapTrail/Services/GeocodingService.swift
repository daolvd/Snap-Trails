import CoreLocation

final class GeocodingService {
    private let geocoder = CLGeocoder()

    func reverseGeocode(location: CLLocation) async -> String {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            guard let place = placemarks.first else {
                return "Location unavailable"
            }

            let parts = [
                place.name,
                place.locality,
                place.administrativeArea
            ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

            if parts.isEmpty {
                return "Location unavailable"
            }

            return parts.joined(separator: ", ")
        } catch {
            return "Location unavailable"
        }
    }
}
