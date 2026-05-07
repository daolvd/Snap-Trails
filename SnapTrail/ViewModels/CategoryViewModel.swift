import SwiftUI
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [MemoryCategory] = []
    @Published var newCategoryName: String = ""
    @Published var selectedIcon: CategoryIcon = .tag
    @Published var selectedColor: CategoryColor = .green
    @Published var errorMessage: String?

    private let categoryDataService: CategoryDataService

    init(categoryDataService: CategoryDataService) {
        self.categoryDataService = categoryDataService
    }

    func fetchCategories() {
        do {
            categories = try categoryDataService.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createCategory() {
        do {
            try categoryDataService.create(
                name: newCategoryName,
                iconName: selectedIcon.rawValue,
                colorName: selectedColor.rawValue
            )
            newCategoryName = ""
            selectedIcon = .tag
            selectedColor = .green
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCategory(_ category: MemoryCategory) {
        do {
            try categoryDataService.delete(category)
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
