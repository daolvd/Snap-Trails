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
        let descriptor = FetchDescriptor<Memory>(
            predicate: #Predicate { $0.isFavourite },
            sortBy: [SortDescriptor(\.dateTime, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func search(
        keyword: String = "",
        category: MemoryCategory? = nil,
        fromDate: Date? = nil,
        toDate: Date? = nil,
        favouriteOnly: Bool = false
    ) throws -> [Memory] {
        let from = fromDate ?? Date.distantPast
        let to = toDate ?? Date.distantFuture

        let descriptor = FetchDescriptor<Memory>(
            predicate: #Predicate { memory in
                (keyword.isEmpty ||
                 memory.locationName.localizedStandardContains(keyword) ||
                 memory.caption.localizedStandardContains(keyword))
                &&
                (!favouriteOnly || memory.isFavourite)
                &&
                (memory.dateTime >= from && memory.dateTime <= to)
            },
            sortBy: [SortDescriptor(\.dateTime, order: .reverse)]
        )

        var results = try modelContext.fetch(descriptor)

        // Category filter kept in Swift because #Predicate can't traverse optional relationships
        if let category {
            results = results.filter { $0.category?.id == category.id }
        }

        return results
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

    func setFavourite(_ memory: Memory, to value: Bool) throws {
        memory.isFavourite = value

        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }

    func toggleFavourite(_ memory: Memory) throws {
        try setFavourite(memory, to: !memory.isFavourite)
    }
}
