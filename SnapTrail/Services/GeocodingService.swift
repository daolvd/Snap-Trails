import CoreLocation

final class GeocodingService {
    private let geocoder = CLGeocoder()
    private var cache: [String: String] = [:]

    func reverseGeocode(location: CLLocation) async -> String {
        let key = String(format: "%.4f,%.4f",
            location.coordinate.latitude,
            location.coordinate.longitude)

        if let cached = cache[key] { return cached }

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            guard let place = placemarks.first else {
                return "Location unavailable"
            }

            let parts = [place.name, place.locality, place.administrativeArea]
                .compactMap { $0 }
                .filter { !$0.isEmpty }

            let result = parts.isEmpty ? "Location unavailable" : parts.joined(separator: ", ")
            cache[key] = result
            return result

        } catch {
            return "Location unavailable"
        }
    }
}
