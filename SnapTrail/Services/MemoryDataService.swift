import Foundation
import SwiftData

@MainActor
final class MemoryDataService {
    let modelContext: ModelContext
    private let imageStorage: ImageStorageServiceProtocol

    init(modelContext: ModelContext, imageStorage: ImageStorageServiceProtocol) {
        self.modelContext = modelContext
        self.imageStorage = imageStorage
    }

    func fetchAll() throws -> [Memory] {
        let descriptor = FetchDescriptor<Memory>(
            sortBy: [SortDescriptor(\.dateTime, order: .reverse)]
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

        // Push to SwiftData only what its predicate compiler reliably supports:
        // date range + favourite flag. Keyword and category are applied in Swift
        // because #Predicate currently can't generate SQL for nil-coalescing on
        // optional Strings (TERNARY → "bad RHS") nor traverse optional relationships.
        let descriptor = FetchDescriptor<Memory>(
            predicate: #Predicate { memory in
                (!favouriteOnly || memory.isFavourite)
                && memory.dateTime >= from
                && memory.dateTime <= to
            },
            sortBy: [SortDescriptor(\.dateTime, order: .reverse)]
        )

        var results = try modelContext.fetch(descriptor)

        if !keyword.isEmpty {
            results = results.filter { memory in
                memory.caption.localizedStandardContains(keyword) ||
                (memory.locationName ?? "").localizedStandardContains(keyword)
            }
        }

        if let category {
            results = results.filter { $0.category?.id == category.id }
        }

        return results
    }

    func save(_ memory: Memory) throws {
        try validate(memory)

        // Idempotent: insert is a no-op if the same instance is already in the context.
        if memory.modelContext == nil {
            modelContext.insert(memory)
        }
        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }

    /// Idempotent: deleting an already-removed memory is a no-op rather than an error.
    func delete(_ memory: Memory) throws {
        guard memory.modelContext != nil else { return }

        imageStorage.deleteImage(fileName: memory.imageFileName)
        modelContext.delete(memory)
        do {
            try modelContext.save()
        } catch {
            throw AppError.memoryDeleteFailed
        }
    }

    /// Idempotent: setting the same value is a no-op and avoids spurious save() calls.
    func setFavourite(_ memory: Memory, to value: Bool) throws {
        guard memory.isFavourite != value else { return }
        memory.isFavourite = value
        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }

    func update(_ memory: Memory) throws {
        try validate(memory)
        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }

    private func validate(_ memory: Memory) throws {
        guard memory.caption.count <= AppConstants.captionMaxLength else {
            throw AppError.captionTooLong
        }
        if let lat = memory.latitude, let lon = memory.longitude {
            guard (-90...90).contains(lat) && (-180...180).contains(lon) else {
                throw AppError.invalidCoordinates
            }
        }
    }
}
