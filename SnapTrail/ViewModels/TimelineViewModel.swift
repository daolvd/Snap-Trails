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
