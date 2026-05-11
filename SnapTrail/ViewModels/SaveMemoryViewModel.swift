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

    static let captionMaxLength = 1000
    static let captionWarningThreshold = 900

    var captionCharacterCount: Int { caption.count }

    var captionWarning: String? {
        caption.count >= Self.captionWarningThreshold
            ? "\(caption.count)/\(Self.captionMaxLength)"
            : nil
    }

    var isCaptionValid: Bool { caption.count <= Self.captionMaxLength }

    private let memoryDataService: MemoryDataService

    init(memoryDataService: MemoryDataService) {
        self.memoryDataService = memoryDataService
    }

    func saveMemory(image: UIImage, location: CLLocation?, capturedDate: Date = Date()) -> Bool {
        guard isCaptionValid else {
            errorMessage = AppError.captionTooLong.localizedDescription
            return false
        }

        if let location {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            guard (-90...90).contains(lat) && (-180...180).contains(lon) else {
                errorMessage = AppError.invalidCoordinates.localizedDescription
                return false
            }
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let fileName = try ImageStorageService.saveImage(image)

            let memory = Memory(
                imageFileName: fileName,
                locationName: locationName,
                latitude: location?.coordinate.latitude ?? 0,
                longitude: location?.coordinate.longitude ?? 0,
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
