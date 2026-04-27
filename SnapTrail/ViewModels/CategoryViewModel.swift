import SwiftUI
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [MemoryCategory] = []
    @Published var newCategoryName: String = ""
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
                iconName: "tag.fill",
                colorName: "green"
            )
            newCategoryName = ""
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
