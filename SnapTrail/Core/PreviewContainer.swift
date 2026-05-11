#if DEBUG
import SwiftUI
import SwiftData

/// Shared preview infrastructure.
/// Provides an in-memory `ModelContainer` and sample data
/// so that previews never touch real storage.
enum PreviewContainer {
    @MainActor
    static let shared: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Memory.self, MemoryCategory.self,
            configurations: configuration
        )
        let ctx = container.mainContext

        let study = MemoryCategory(name: "Study", iconName: "book.fill", colorName: "#4DA8FF")
        let food = MemoryCategory(name: "Food", iconName: "fork.knife", colorName: "#FF9433")
        let travel = MemoryCategory(name: "Travel", iconName: "airplane", colorName: "#2ECC70")
        let daily = MemoryCategory(name: "Daily Life", iconName: "sun.max.fill", colorName: "#FFD700")

        ctx.insert(study)
        ctx.insert(food)
        ctx.insert(travel)
        ctx.insert(daily)

        let m1 = Memory(
            imageFileName: "preview-1.jpg",
            location: GeoLocation(latitude: -33.8836, longitude: 151.2006, name: "UTS Building 11"),
            dateTime: Date(),
            caption: "Studying hard for finals",
            isFavourite: true,
            category: study
        )
        let m2 = Memory(
            imageFileName: "preview-2.jpg",
            location: GeoLocation(latitude: -33.8833, longitude: 151.2054, name: "Central Station"),
            dateTime: Date().addingTimeInterval(-86400),
            caption: "Morning commute",
            isFavourite: false,
            category: travel
        )
        let m3 = Memory(
            imageFileName: "preview-3.jpg",
            location: GeoLocation(latitude: -33.8752, longitude: 151.2010, name: "Darling Harbour"),
            dateTime: Date().addingTimeInterval(-172800),
            caption: "Midnight ramen run",
            isFavourite: true,
            category: food
        )
        ctx.insert(m1)
        ctx.insert(m2)
        ctx.insert(m3)

        return container
    }()

    @MainActor
    static var context: ModelContext {
        shared.mainContext
    }

    @MainActor
    static var sampleMemory: Memory {
        Memory(
            imageFileName: "preview-sample.jpg",
            location: GeoLocation(latitude: -33.8836, longitude: 151.2006, name: "Cascades North"),
            dateTime: Date(),
            caption: "Scaling the edges of the world today. The view is absolutely breathtaking.",
            isFavourite: true
        )
    }

    @MainActor
    static var sampleCategory: MemoryCategory {
        MemoryCategory(name: "Travel", iconName: "airplane", colorName: "#2ECC70")
    }
}
#endif
