import SwiftUI
import Combine
import CoreLocation

@MainActor
final class SaveMemoryViewModel: ObservableObject {
    @Published var caption = ""
    @Published var selectedCategory: MemoryCategory?
    @Published var locationName: String?
    @Published var isSaving = false
    @Published var errorMessage: String?

    var captionMaxLength: Int { AppConstants.captionMaxLength }

    var captionCharacterCount: Int { caption.count }

    var captionWarning: String? {
        caption.count >= AppConstants.captionWarningThreshold
            ? "\(caption.count)/\(AppConstants.captionMaxLength)"
            : nil
    }

    var isCaptionValid: Bool { caption.count <= AppConstants.captionMaxLength }

    var displayLocationName: String { locationName ?? "Unknown location" }

    private let memoryDataService: MemoryDataServiceProtocol
    private let imageStorage: ImageStorageServiceProtocol

    init(
        memoryDataService: MemoryDataServiceProtocol,
        imageStorage: ImageStorageServiceProtocol = ImageStorageService.live
    ) {
        self.memoryDataService = memoryDataService
        self.imageStorage = imageStorage
    }

    func saveMemory(
        image: UIImage,
        location: CLLocation?,
        capturedDate: Date = Date()
    ) -> Bool {
        guard isCaptionValid else {
            errorMessage = AppError.captionTooLong.localizedDescription
            return false
        }

        let geo = GeoLocation(
            coordinate: location?.coordinate,
            name: locationName ?? ""
        )

        if location != nil && geo == nil {
            errorMessage = AppError.invalidCoordinates.localizedDescription
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let fileName = try imageStorage.saveImage(image)

            let memory = Memory(
                imageFileName: fileName,
                location: geo,
                dateTime: capturedDate,
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
