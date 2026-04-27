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
                try categoryDataService.create(
                    name: "Study",
                    iconName: "book.fill",
                    colorName: "green"
                )

                try categoryDataService.create(
                    name: "Food",
                    iconName: "fork.knife",
                    colorName: "green"
                )

                try categoryDataService.create(
                    name: "Travel",
                    iconName: "airplane",
                    colorName: "green"
                )

                try categoryDataService.create(
                    name: "Daily Life",
                    iconName: "sun.max.fill",
                    colorName: "green"
                )
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
