import Foundation

enum AppError: LocalizedError {
    case imageSaveFailed
    case imageLoadFailed
    case locationUnavailable
    case geocodingFailed
    case memorySaveFailed
    case memoryDeleteFailed
    case invalidCategoryName
    case duplicatedCategory
    case permissionDenied
    case cameraUnavailable

    var errorDescription: String? {
        switch self {
        case .imageSaveFailed:
            return "Unable to save the photo. Please try again."
        case .imageLoadFailed:
            return "Unable to load this photo."
        case .locationUnavailable:
            return "Location is unavailable. Please check your location permission."
        case .geocodingFailed:
            return "Unable to convert this location into a place name."
        case .memorySaveFailed:
            return "Unable to save this memory."
        case .memoryDeleteFailed:
            return "Unable to delete this memory."
        case .invalidCategoryName:
            return "Category name cannot be empty."
        case .duplicatedCategory:
            return "This category already exists."
        case .permissionDenied:
            return "Permission denied. Please enable access in Settings."
        case .cameraUnavailable:
            return "Camera is unavailable on this device."
        }
    }
}
