import Foundation
import SwiftData

@MainActor
final class MemoryDataService {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Memory] {
        let descriptor = FetchDescriptor<Memory>(
            sortBy: [
                SortDescriptor(\.dateTime, order: .reverse)
            ]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchFavourites() throws -> [Memory] {
        try fetchAll().filter { $0.isFavourite }
    }

    func search(
        keyword: String = "",
        category: MemoryCategory? = nil,
        fromDate: Date? = nil,
        toDate: Date? = nil,
        favouriteOnly: Bool = false
    ) throws -> [Memory] {
        let memories = try fetchAll()

        return memories.filter { memory in
            let matchesKeyword =
                keyword.isEmpty ||
                memory.locationName.localizedCaseInsensitiveContains(keyword) ||
                memory.caption.localizedCaseInsensitiveContains(keyword)

            let matchesCategory =
                category == nil ||
                memory.category?.id == category?.id

            let matchesFromDate =
                fromDate == nil ||
                memory.dateTime >= fromDate!

            let matchesToDate =
                toDate == nil ||
                memory.dateTime <= toDate!

            let matchesFavourite =
                !favouriteOnly ||
                memory.isFavourite

            return matchesKeyword &&
                   matchesCategory &&
                   matchesFromDate &&
                   matchesToDate &&
                   matchesFavourite
        }
    }

    func save(_ memory: Memory) throws {
        modelContext.insert(memory)

        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }

    func delete(_ memory: Memory) throws {
        ImageStorageService.deleteImage(fileName: memory.imageFileName)

        modelContext.delete(memory)

        do {
            try modelContext.save()
        } catch {
            throw AppError.memoryDeleteFailed
        }
    }

    func toggleFavourite(_ memory: Memory) throws {
        memory.isFavourite.toggle()

        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }
}
