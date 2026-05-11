import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var selectedCategory: MemoryCategory?
    @Published var fromDate: Date?
    @Published var toDate: Date?
    @Published var favouriteOnly: Bool = false
    @Published var results: [Memory] = []
    @Published var errorMessage: String?
    @Published var categories: [MemoryCategory] = []

    let memoryDataService: MemoryDataServiceProtocol
    private let categoryDataService: CategoryDataServiceProtocol

    init(
        memoryDataService: MemoryDataServiceProtocol,
        categoryDataService: CategoryDataServiceProtocol
    ) {
        self.memoryDataService = memoryDataService
        self.categoryDataService = categoryDataService
    }

    func search() {
        do {
            results = try memoryDataService.search(
                keyword: keyword,
                category: selectedCategory,
                fromDate: fromDate,
                toDate: toDate,
                favouriteOnly: favouriteOnly
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchCategories() {
        do {
            categories = try categoryDataService.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetFilters() {
        keyword = ""
        selectedCategory = nil
        fromDate = nil
        toDate = nil
        favouriteOnly = false
        results = []
    }
}
