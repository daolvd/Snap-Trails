import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage(AppConstants.hasCompletedOnboardingKey)
    private var hasCompletedOnboarding = false

    var body: some View {
        let memoryDataService = MemoryDataService(modelContext: modelContext)
        let categoryDataService = CategoryDataService(modelContext: modelContext)
        let defaultDataService = DefaultDataService(categoryDataService: categoryDataService)

        Group {
            if hasCompletedOnboarding {
                MainTabView(
                    memoryDataService: memoryDataService,
                    categoryDataService: categoryDataService
                )
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .task {
            await defaultDataService.createDefaultCategoriesIfNeeded()
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewContainer.shared)
}
