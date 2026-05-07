import Foundation

@MainActor
final class DefaultDataService {
    private let categoryDataService: CategoryDataService

    init(categoryDataService: CategoryDataService) {
        self.categoryDataService = categoryDataService
    }

    func createDefaultCategoriesIfNeeded() async {
        let hasCreated = UserDefaults.standard.bool(
            forKey: AppConstants.hasCreatedDefaultCategoriesKey
        )

        guard !hasCreated else {
            return
        }

        do {
            let existing = try categoryDataService.fetchAll()

            if existing.isEmpty {
                for config in DefaultCategoryConfig.load() {
                    try categoryDataService.create(
                        name: config.name,
                        iconName: config.iconName,
                        colorName: config.colorName
                    )
                }
            }

            UserDefaults.standard.set(
                true,
                forKey: AppConstants.hasCreatedDefaultCategoriesKey
            )
        } catch {
            // Do not crash the app if default category creation fails.
            // User can still create categories manually.
        }
    }
}
