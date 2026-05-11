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

    var captionMaxLength: Int { AppConstants.captionMaxLength }

    var captionCharacterCount: Int { caption.count }

    var captionWarning: String? {
        caption.count >= AppConstants.captionWarningThreshold
            ? "\(caption.count)/\(AppConstants.captionMaxLength)"
            : nil
    }

    var isCaptionValid: Bool { caption.count <= AppConstants.captionMaxLength }

    // MARK: - Private
    private let memory: Memory
    private let memoryDataService: MemoryDataServiceProtocol
    private let locationService: LocationServiceProtocol
    private let geocodingService: GeocodingServiceProtocol

    init(
        memory: Memory,
        memoryDataService: MemoryDataServiceProtocol,
        locationService: LocationServiceProtocol,
        geocodingService: GeocodingServiceProtocol
    ) {
        self.memory = memory
        self.memoryDataService = memoryDataService
        self.locationService = locationService
        self.geocodingService = geocodingService

        self.caption = memory.caption
        self.locationName = memory.locationName ?? ""
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
        memory.dateTime = dateTime
        memory.category = selectedCategory

        let trimmedName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing = memory.location {
            memory.location = GeoLocation(
                latitude: existing.latitude,
                longitude: existing.longitude,
                name: trimmedName
            )
        } else {
            memory.locationName = trimmedName.isEmpty ? nil : trimmedName
        }

        do {
            try memoryDataService.update(memory)
            didSave = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Re-fetch location via injected services

    func refreshLocationFromDevice() {
        isFetchingLocation = true
        Task {
            do {
                let clLocation = try await locationService.getCurrentLocation()
                let name = await geocodingService.reverseGeocode(location: clLocation) ?? ""

                memory.location = GeoLocation(
                    latitude: clLocation.coordinate.latitude,
                    longitude: clLocation.coordinate.longitude,
                    name: name
                )
                locationName = name
            } catch {
                errorMessage = AppError.locationUnavailable.localizedDescription
            }
            isFetchingLocation = false
        }
    }
}
