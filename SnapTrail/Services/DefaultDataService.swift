import Foundation

@MainActor
protocol DefaultDataServiceProtocol {
    func createDefaultCategoriesIfNeeded() async
}

@MainActor
final class DefaultDataService: DefaultDataServiceProtocol {
    private let categoryDataService: CategoryDataServiceProtocol
    private let defaults: UserDefaults

    init(
        categoryDataService: CategoryDataServiceProtocol,
        defaults: UserDefaults = .standard
    ) {
        self.categoryDataService = categoryDataService
        self.defaults = defaults
    }

    func createDefaultCategoriesIfNeeded() async {
        let hasCreated = defaults.bool(forKey: AppConstants.hasCreatedDefaultCategoriesKey)
        guard !hasCreated else { return }

        do {
            let existing = try categoryDataService.fetchAll()

            if existing.isEmpty {
                for config in DefaultCategoryConfig.load() {
                    do {
                        try categoryDataService.create(
                            name: config.name,
                            iconName: config.iconName,
                            colorName: config.colorName
                        )
                    } catch AppError.duplicatedCategory {
                        // Concurrent creation produced this category — safe to ignore.
                        AppLog.info(
                            "Default category '\(config.name)' already existed",
                            category: .data
                        )
                    } catch {
                        AppLog.error(
                            "Failed to create default category '\(config.name)'",
                            category: .data,
                            error: error
                        )
                    }
                }
            }

            defaults.set(true, forKey: AppConstants.hasCreatedDefaultCategoriesKey)
        } catch {
            // Don't crash, but don't pretend nothing happened either.
            AppLog.error(
                "Failed to read existing categories during seed",
                category: .data,
                error: error
            )
        }
    }
}
