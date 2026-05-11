import Foundation
import SwiftData

@Model
final class Memory {
    @Attribute(.unique) var id: UUID

    var imageFileName: String
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var dateTime: Date
    var caption: String
    var isFavourite: Bool

    var category: MemoryCategory?

    init(
        id: UUID = UUID(),
        imageFileName: String,
        location: GeoLocation? = nil,
        dateTime: Date = Date(),
        caption: String = "",
        isFavourite: Bool = false,
        category: MemoryCategory? = nil
    ) {
        self.id = id
        self.imageFileName = imageFileName
        self.locationName = location?.name
        self.latitude = location?.latitude
        self.longitude = location?.longitude
        self.dateTime = dateTime
        self.caption = caption
        self.isFavourite = isFavourite
        self.category = category
    }

    var location: GeoLocation? {
        get {
            guard let latitude, let longitude else { return nil }
            return GeoLocation(
                latitude: latitude,
                longitude: longitude,
                name: locationName ?? ""
            )
        }
        set {
            latitude = newValue?.latitude
            longitude = newValue?.longitude
            locationName = newValue?.name
        }
    }

    var displayLocationName: String {
        location?.displayName ?? "Unknown location"
    }
}
