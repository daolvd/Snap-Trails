import SwiftUI
import Combine
import CoreLocation

@MainActor
final class SaveMemoryViewModel: ObservableObject {
    @Published var caption = ""
    @Published var selectedCategory: MemoryCategory?
    @Published var locationName = "Location unavailable"
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let memoryDataService: MemoryDataService

    init(memoryDataService: MemoryDataService) {
        self.memoryDataService = memoryDataService
    }

    func saveMemory(image: UIImage, location: CLLocation?) -> Bool {
        guard let location else {
            errorMessage = AppError.locationUnavailable.localizedDescription
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let fileName = try ImageStorageService.saveImage(image)

            let memory = Memory(
                imageFileName: fileName,
                locationName: locationName,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                dateTime: Date(),
                caption: caption,
                isFavourite: false,
                category: selectedCategory
            )

            try memoryDataService.save(memory)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
