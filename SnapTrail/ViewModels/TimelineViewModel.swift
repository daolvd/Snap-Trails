import SwiftUI
import Combine

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var memories: [Memory] = []
    @Published var errorMessage: String?

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

    var groupedMemories: [TimelineYearGroup] {
        let calendar = Calendar.current
        let sorted = memories.sorted { $0.dateTime > $1.dateTime }

        let byDay = Dictionary(grouping: sorted) { memory -> Date in
            calendar.startOfDay(for: memory.dateTime)
        }

        let dayGroups: [TimelineDayGroup] = byDay
            .map { (date, memories) in
                TimelineDayGroup(
                    id: ISO8601DateFormatter().string(from: date),
                    date: date,
                    memories: memories.sorted { $0.dateTime > $1.dateTime }
                )
            }
            .sorted { $0.date > $1.date }

        let byMonth = Dictionary(grouping: dayGroups) { day -> DateComponents in
            calendar.dateComponents([.year, .month], from: day.date)
        }

        let monthGroups: [TimelineMonthGroup] = byMonth
            .compactMap { (components, days) -> TimelineMonthGroup? in
                guard let date = calendar.date(from: components),
                      let year = components.year,
                      let month = components.month else { return nil }
                return TimelineMonthGroup(
                    id: "\(year)-\(month)",
                    date: date,
                    days: days
                )
            }
            .sorted { $0.date > $1.date }

        let byYear = Dictionary(grouping: monthGroups) { month -> Int in
            calendar.component(.year, from: month.date)
        }

        return byYear
            .map { (year, months) in
                TimelineYearGroup(
                    id: year,
                    year: year,
                    months: months.sorted { $0.date > $1.date }
                )
            }
            .sorted { $0.year > $1.year }
    }

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
            try memoryDataService.setFavourite(memory, to: !memory.isFavourite)
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
}
