import Foundation
import SwiftData

/// Container that owns all live service instances for one model context.
/// Built once in `RootView` and passed down through the tree — no singletons.
@MainActor
final class AppServices {
    let memoryDataService: MemoryDataServiceProtocol
    let categoryDataService: CategoryDataServiceProtocol
    let imageStorage: ImageStorageServiceProtocol
    let notificationService: NotificationServiceProtocol
    let userProfileService: UserProfileServiceProtocol
    let geocodingService: GeocodingServiceProtocol
    let defaultDataService: DefaultDataServiceProtocol

    private let locationServiceFactory: @MainActor () -> LocationServiceProtocol

    init(modelContext: ModelContext) {
        let imageStorage = ImageStorageService()
        let memoryDS = MemoryDataService(modelContext: modelContext, imageStorage: imageStorage)
        let categoryDS = CategoryDataService(modelContext: modelContext)

        self.imageStorage = imageStorage
        self.memoryDataService = memoryDS
        self.categoryDataService = categoryDS
        self.notificationService = NotificationService()
        self.userProfileService = UserProfileService()
        self.geocodingService = GeocodingService()
        self.defaultDataService = DefaultDataService(categoryDataService: categoryDS)
        self.locationServiceFactory = { LocationService() }
    }

    /// LocationService owns Combine publishers — fresh instance per consumer
    /// avoids cross-screen state leakage.
    func makeLocationService() -> LocationServiceProtocol {
        locationServiceFactory()
    }
}
