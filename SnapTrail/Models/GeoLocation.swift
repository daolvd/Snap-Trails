import CoreLocation
import Foundation

struct GeoLocation: Equatable, Hashable {
    let latitude: Double
    let longitude: Double
    let name: String

    init(latitude: Double, longitude: Double, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }

    init?(coordinate: CLLocationCoordinate2D?, name: String) {
        guard let coordinate else { return nil }
        guard (-90...90).contains(coordinate.latitude),
              (-180...180).contains(coordinate.longitude) else { return nil }
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.name = name
    }

    var displayName: String {
        name.isEmpty ? "Unknown location" : name
    }
}
