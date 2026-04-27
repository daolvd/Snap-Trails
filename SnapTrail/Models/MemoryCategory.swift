import Foundation
import SwiftData

@Model
final class MemoryCategory {
    @Attribute(.unique) var id: UUID

    var name: String
    var iconName: String
    var colorName: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Memory.category)
    var memories: [Memory] = []

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "tag.fill",
        colorName: String = "green",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorName = colorName
        self.createdAt = createdAt
    }
}
