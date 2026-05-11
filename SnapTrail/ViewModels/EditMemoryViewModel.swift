import SwiftUI
import Combine
import CoreLocation

@MainActor
final class EditMemoryViewModel: ObservableObject {

    // MARK: - Editable fields (pre-populated from existing memory)
    @Published var caption: String
    @Published var locationName: String
    @Published var dateTime: Date
    @Published var selectedCategory: MemoryCategory?

    // MARK: - Geo-lookup state
    @Published var isFetchingLocation = false
    @Published var errorMessage: String?
    @Published var isSaving = false
    @Published var didSave = false

    static let captionMaxLength = 1000
    static let captionWarningThreshold = 900

    var captionCharacterCount: Int { caption.count }

    var captionWarning: String? {
        caption.count >= Self.captionWarningThreshold
            ? "\(caption.count)/\(Self.captionMaxLength)"
            : nil
    }

    var isCaptionValid: Bool { caption.count <= Self.captionMaxLength }

    // MARK: - Private
    private let memory: Memory
    private let memoryDataService: MemoryDataService
    private let geocodingService = GeocodingService()

    init(memory: Memory, memoryDataService: MemoryDataService) {
        self.memory = memory
        self.memoryDataService = memoryDataService

        self.caption = memory.caption
        self.locationName = memory.locationName
        self.dateTime = memory.dateTime
        self.selectedCategory = memory.category
    }

    // MARK: - Save edits back to SwiftData

    func saveEdits() {
        guard isCaptionValid else {
            errorMessage = AppError.captionTooLong.localizedDescription
            return
        }

        isSaving = true
        defer { isSaving = false }

        memory.caption = caption
        memory.locationName = locationName
        memory.dateTime = dateTime
        memory.category = selectedCategory

        do {
            try memoryDataService.update(memory)
            didSave = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save changes."
        }
    }

    // MARK: - Re-fetch location by name (manual override via geocode)

    func refreshLocationFromDevice() {
        isFetchingLocation = true
        let locationService = LocationService()
        Task {
            do {
                let location = try await locationService.getCurrentLocation()
                let name = await geocodingService.reverseGeocode(location: location)
                locationName = name
            } catch {
                errorMessage = "Could not fetch current location."
            }
            isFetchingLocation = false
        }
    }
}
