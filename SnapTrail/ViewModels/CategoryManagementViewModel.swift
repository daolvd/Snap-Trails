import SwiftUI
import Combine

@MainActor
final class CategoryManagementViewModel: ObservableObject {

    // MARK: - List state
    @Published var categories: [MemoryCategory] = []
    @Published var snapCounts: [UUID: Int] = [:]

    // MARK: - Create / Edit form state
    @Published var formName: String = ""
    @Published var formIcon: CategoryIcon = .tag
    @Published var formColor: Color = Color(hex: "#AEFF00")

    // MARK: - UI state
    @Published var isShowingCreateSheet = false
    @Published var editingCategory: MemoryCategory? = nil
    @Published var categoryToDelete: MemoryCategory? = nil
    @Published var errorMessage: String? = nil

    private let categoryDataService: CategoryDataServiceProtocol
    private let memoryDataService: MemoryDataServiceProtocol

    init(
        categoryDataService: CategoryDataServiceProtocol,
        memoryDataService: MemoryDataServiceProtocol
    ) {
        self.categoryDataService = categoryDataService
        self.memoryDataService = memoryDataService
    }

    // MARK: - Fetch

    func fetchCategories() {
        do {
            categories = try categoryDataService.fetchAll()
            refreshSnapCounts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshSnapCounts() {
        var counts: [UUID: Int] = [:]
        for category in categories {
            counts[category.id] = category.memories.count
        }
        snapCounts = counts
    }

    func snapCount(for category: MemoryCategory) -> Int {
        snapCounts[category.id] ?? 0
    }

    // MARK: - Create

    func openCreateSheet() {
        formName = ""
        formIcon = .tag
        formColor = Color(hex: "#AEFF00")
        isShowingCreateSheet = true
    }

    func createCategory() {
        do {
            try categoryDataService.create(
                name: formName,
                iconName: formIcon.rawValue,
                colorName: formColor.toHex
            )
            isShowingCreateSheet = false
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Edit

    func openEditSheet(for category: MemoryCategory) {
        formName = category.name
        formIcon = CategoryIcon(rawValue: category.iconName) ?? .tag
        formColor = Color(hex: category.colorName)
        editingCategory = category
    }

    func saveEdit() {
        guard let category = editingCategory else { return }
        do {
            try categoryDataService.update(
                category,
                name: formName,
                iconName: formIcon.rawValue,
                colorName: formColor.toHex
            )
            editingCategory = nil
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelEdit() {
        editingCategory = nil
    }

    // MARK: - Delete

    func confirmDelete(_ category: MemoryCategory) {
        categoryToDelete = category
    }

    func executeDelete() {
        guard let category = categoryToDelete else { return }
        do {
            try categoryDataService.delete(category)
            categoryToDelete = nil
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelDelete() {
        categoryToDelete = nil
    }

    // MARK: - Form validation

    var isFormValid: Bool {
        !formName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
