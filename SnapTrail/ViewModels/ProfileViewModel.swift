import SwiftUI
import Combine

/// Statistics snapshot computed from all stored memories.
struct ProfileStats {
    var totalCount: Int = 0
    var thisYearCount: Int = 0
    var thisMonthCount: Int = 0
    var thisWeekCount: Int = 0
    var favouriteCount: Int = 0
    /// Current consecutive-day streak (days with at least one memory, counting back from today).
    var streakCount: Int = 0
}

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Profile fields

    @Published var displayName: String {
        didSet { UserProfileService.shared.displayName = displayName }
    }
    @Published var profileImage: UIImage?

    // MARK: - Stats

    @Published var stats = ProfileStats()

    // MARK: - UI state

    @Published var isEditingName = false
    @Published var draftName: String = ""
    @Published var showImagePicker = false
    @Published var errorMessage: String?

    // MARK: - Private

    private let memoryDataService: MemoryDataService

    init(memoryDataService: MemoryDataService) {
        self.memoryDataService = memoryDataService
        self.displayName = UserProfileService.shared.displayName
        self.profileImage = UserProfileService.shared.loadPhoto()
    }

    // MARK: - Name editing

    func beginEditingName() {
        draftName = displayName
        isEditingName = true
    }

    func commitNameEdit() {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            displayName = trimmed
        }
        isEditingName = false
    }

    func cancelNameEdit() {
        isEditingName = false
    }

    // MARK: - Photo

    func applyPickedImage(_ image: UIImage) {
        profileImage = image
        UserProfileService.shared.savePhoto(image)
    }

    func removePhoto() {
        profileImage = nil
        UserProfileService.shared.deletePhoto()
    }

    // MARK: - Stats

    func refreshStats() {
        guard let memories = try? memoryDataService.fetchAll() else { return }

        let calendar = Calendar.current
        let now = Date()

        // Start of current year / month / week
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        )!

        var s = ProfileStats()
        s.totalCount = memories.count
        s.thisYearCount = memories.filter { $0.dateTime >= startOfYear }.count
        s.thisMonthCount = memories.filter { $0.dateTime >= startOfMonth }.count
        s.thisWeekCount = memories.filter { $0.dateTime >= startOfWeek }.count
        s.favouriteCount = memories.filter { $0.isFavourite }.count
        s.streakCount = computeStreak(memories: memories, calendar: calendar, now: now)

        stats = s
    }

    // MARK: - Streak computation

    /// Counts how many consecutive calendar days (ending today or yesterday) have at least one memory.
    private func computeStreak(memories: [Memory], calendar: Calendar, now: Date) -> Int {
        guard !memories.isEmpty else { return 0 }

        // Unique set of date-only components (year, month, day) that have a memory
        let daysWithMemory: Set<String> = Set(memories.map { memory in
            let c = calendar.dateComponents([.year, .month, .day], from: memory.dateTime)
            return "\(c.year!)-\(c.month!)-\(c.day!)"
        })

        func key(for date: Date) -> String {
            let c = calendar.dateComponents([.year, .month, .day], from: date)
            return "\(c.year!)-\(c.month!)-\(c.day!)"
        }

        var streak = 0
        var checkDate = now

        // Allow streak to include today even if no memory logged yet today;
        // start checking from yesterday if today has no memory
        if !daysWithMemory.contains(key(for: checkDate)) {
            // Try yesterday as the anchor
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate),
                  daysWithMemory.contains(key(for: yesterday)) else {
                return 0
            }
            checkDate = yesterday
        }

        while daysWithMemory.contains(key(for: checkDate)) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }
}
