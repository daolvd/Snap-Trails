import SwiftUI
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [MemoryCategory] = []
    @Published var newCategoryName: String = ""
    @Published var selectedIcon: CategoryIcon = .tag
    @Published var selectedColor: Color = Color(hex: "#AEFF00")
    @Published var errorMessage: String?

    private let categoryDataService: CategoryDataServiceProtocol

    init(categoryDataService: CategoryDataServiceProtocol) {
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
                colorName: selectedColor.toHex
            )
            newCategoryName = ""
            selectedIcon = .tag
            selectedColor = Color(hex: "#AEFF00")
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
