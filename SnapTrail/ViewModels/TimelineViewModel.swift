import SwiftUI
import Combine

/// Determines how memories are grouped on the timeline
enum TimelineGroupMode: String, CaseIterable, Identifiable {
    case year = "Year"
    case month = "Month"
    case day = "Day"

    var id: String { rawValue }
}

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var memories: [Memory] = []
    @Published var errorMessage: String?
    @Published var groupMode: TimelineGroupMode = .month

    let memoryDataService: MemoryDataService

    init(memoryDataService: MemoryDataService) {
        self.memoryDataService = memoryDataService
    }

    var totalCount: Int { memories.count }

    var favouriteCount: Int {
        memories.filter { $0.isFavourite }.count
    }

    var thisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        ) else { return 0 }
        return memories.filter { $0.dateTime >= startOfWeek }.count
    }

    // MARK: - Grouped Memories

    /// Groups memories by the selected mode and returns sections with a display key.
    /// Each section contains its memories sorted newest-first (already sorted from fetch).
    var groupedMemories: [(key: String, memories: [Memory])] {
        let calendar = Calendar.current

        let grouped: [String: [Memory]]

        switch groupMode {
        case .year:
            grouped = Dictionary(grouping: memories) { memory in
                let year = calendar.component(.year, from: memory.dateTime)
                return "\(year)"
            }
        case .month:
            grouped = Dictionary(grouping: memories) { memory in
                let comps = calendar.dateComponents([.year, .month], from: memory.dateTime)
                return Self.monthYearKey(year: comps.year!, month: comps.month!)
            }
        case .day:
            grouped = Dictionary(grouping: memories) { memory in
                return Self.dayKey(for: memory.dateTime, calendar: calendar)
            }
        }

        // Sort sections by the newest memory in each group (descending)
        return grouped
            .map { (key: $0.key, memories: $0.value) }
            .sorted { a, b in
                guard let aDate = a.memories.first?.dateTime,
                      let bDate = b.memories.first?.dateTime else { return false }
                return aDate > bDate
            }
    }

    // MARK: - Data Operations

    func fetchMemories() {
        do {
            memories = try memoryDataService.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavourite(_ memory: Memory) {
        do {
            try memoryDataService.toggleFavourite(memory)
            fetchMemories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ memory: Memory) {
        do {
            try memoryDataService.delete(memory)
            fetchMemories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Date Formatting Helpers

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    private static func monthYearKey(year: Int, month: Int) -> String {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        let date = Calendar.current.date(from: comps) ?? Date()
        return monthFormatter.string(from: date)
    }

    private static func dayKey(for date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }

    /// Returns the number of memories in a section for display in the header badge
    func countLabel(for count: Int) -> String {
        count == 1 ? "1 memory" : "\(count) memories"
    }
}

