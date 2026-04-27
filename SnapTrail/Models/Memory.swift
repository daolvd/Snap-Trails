import Foundation
import SwiftData

@Model
final class Memory {
    @Attribute(.unique) var id: UUID

    var imageFileName: String
    var locationName: String
    var latitude: Double
    var longitude: Double
    var dateTime: Date
    var caption: String
    var isFavourite: Bool

    var category: MemoryCategory?

    init(
        id: UUID = UUID(),
        imageFileName: String,
        locationName: String,
        latitude: Double,
        longitude: Double,
        dateTime: Date = Date(),
        caption: String = "",
        isFavourite: Bool = false,
        category: MemoryCategory? = nil
    ) {
        self.id = id
        self.imageFileName = imageFileName
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.dateTime = dateTime
        self.caption = caption
        self.isFavourite = isFavourite
        self.category = category
    }
}
