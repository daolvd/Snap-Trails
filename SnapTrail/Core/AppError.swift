import Foundation

/// User-facing errors. Messages are routed through `String(localized:defaultValue:)`
/// so they can be translated by adding entries to a Localizable.xcstrings catalog
/// without touching this file — i.e. new languages are *data*, not code.
enum AppError: LocalizedError {
    case imageSaveFailed
    case imageLoadFailed
    case imageTooLarge
    case locationUnavailable
    case invalidCoordinates
    case geocodingFailed
    case memorySaveFailed
    case memoryDeleteFailed
    case captionTooLong
    case invalidCategoryName
    case duplicatedCategory
    case permissionDenied
    case cameraUnavailable

    var errorDescription: String? {
        switch self {
        case .imageSaveFailed:
            return String(
                localized: "error.image.save",
                defaultValue: "Unable to save the photo. Please try again."
            )
        case .imageLoadFailed:
            return String(
                localized: "error.image.load",
                defaultValue: "Unable to load this photo."
            )
        case .imageTooLarge:
            let mb = AppConstants.imageMaxSizeBytes / (1024 * 1024)
            return String(
                localized: "error.image.tooLarge",
                defaultValue: "Photo is too large (max \(mb) MB). Please choose a smaller image."
            )
        case .locationUnavailable:
            return String(
                localized: "error.location.unavailable",
                defaultValue: "Location is unavailable. Please check your location permission."
            )
        case .invalidCoordinates:
            return String(
                localized: "error.location.invalidCoordinates",
                defaultValue: "Location coordinates are invalid. Please try again."
            )
        case .geocodingFailed:
            return String(
                localized: "error.location.geocodingFailed",
                defaultValue: "Unable to convert this location into a place name."
            )
        case .memorySaveFailed:
            return String(
                localized: "error.memory.save",
                defaultValue: "Unable to save this memory."
            )
        case .memoryDeleteFailed:
            return String(
                localized: "error.memory.delete",
                defaultValue: "Unable to delete this memory."
            )
        case .captionTooLong:
            return String(
                localized: "error.caption.tooLong",
                defaultValue: "Caption is too long. Please keep it under \(AppConstants.captionMaxLength) characters."
            )
        case .invalidCategoryName:
            return String(
                localized: "error.category.invalidName",
                defaultValue: "Category name cannot be empty."
            )
        case .duplicatedCategory:
            return String(
                localized: "error.category.duplicated",
                defaultValue: "This category already exists."
            )
        case .permissionDenied:
            return String(
                localized: "error.permission.denied",
                defaultValue: "Permission denied. Please enable access in Settings."
            )
        case .cameraUnavailable:
            return String(
                localized: "error.camera.unavailable",
                defaultValue: "Camera is unavailable on this device."
            )
        }
    }
}
