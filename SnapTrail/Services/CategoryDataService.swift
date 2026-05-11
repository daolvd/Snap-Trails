import Foundation
import SwiftData

@MainActor
final class CategoryDataService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [MemoryCategory] {
        let descriptor = FetchDescriptor<MemoryCategory>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .forward)
            ]
        )

        return try modelContext.fetch(descriptor)
    }

    func create(
        name: String,
        iconName: String = "tag.fill",
        colorName: String = "green"
    ) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw AppError.invalidCategoryName
        }

        let existing = try fetchAll()

        let duplicated = existing.contains {
            $0.name.lowercased() == trimmedName.lowercased()
        }

        guard !duplicated else {
            throw AppError.duplicatedCategory
        }

        let category = MemoryCategory(
            name: trimmedName,
            iconName: iconName,
            colorName: colorName
        )

        modelContext.insert(category)

        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }

    /// Updates the name, icon, and colour of an existing category.
    func update(
        _ category: MemoryCategory,
        name: String,
        iconName: String,
        colorName: String
    ) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw AppError.invalidCategoryName
        }

        // Duplicate check — exclude the category being edited itself
        let existing = try fetchAll()
        let duplicated = existing.contains {
            $0.id != category.id &&
            $0.name.lowercased() == trimmedName.lowercased()
        }

        guard !duplicated else {
            throw AppError.duplicatedCategory
        }

        category.name = trimmedName
        category.iconName = iconName
        category.colorName = colorName

        do {
            try modelContext.save()
        } catch {
            throw AppError.memorySaveFailed
        }
    }

    /// Idempotent: deleting an already-removed category is a no-op.
    func delete(_ category: MemoryCategory) throws {
        guard category.modelContext != nil else { return }

        modelContext.delete(category)

        do {
            try modelContext.save()
        } catch {
            throw AppError.memoryDeleteFailed
        }
    }
}
