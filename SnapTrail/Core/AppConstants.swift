import Foundation

/// Single source of truth for tunable values. Changing limits or scheduling
/// requires no edits beyond this file — useful for QA tweaks, feature flags,
/// or replacing values with remote config in the future.
enum AppConstants {

    // MARK: - Storage

    static let memoriesFolderName = "memories"
    static let profilePhotoFileName = "profile_photo.jpg"

    // MARK: - UserDefaults keys

    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let hasCreatedDefaultCategoriesKey = "hasCreatedDefaultCategories"
    static let isDailyReminderEnabledKey = "isDailyReminderEnabled"
    static let userProfileNameKey = "userProfileName"

    // MARK: - Notifications

    static let dailyReminderIdentifier = "daily_reminder"
    static let defaultReminderHour = 20
    static let defaultReminderMinute = 0

    // MARK: - Caption

    static let captionMaxLength = 1000
    static let captionWarningThreshold = 900

    // MARK: - Image storage

    static let imageMaxSizeBytes = 50 * 1024 * 1024
    static let imageCompressionQuality: CGFloat = 0.85

    // MARK: - Geocoding

    /// Precision used when caching reverse-geocoded coordinates.
    /// 4 decimal places ≈ 11 m at the equator — adequate for human-readable
    /// place names without filling the cache with near-duplicates.
    static let geocodingCacheCoordinatePrecision: Int = 4
}
