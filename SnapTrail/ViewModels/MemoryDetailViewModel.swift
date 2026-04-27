import SwiftUI
import Combine

@MainActor
final class MemoryDetailViewModel: ObservableObject {
    @Published var memory: Memory
    @Published var errorMessage: String?
    @Published var isDeleted: Bool = false

    private let memoryDataService: MemoryDataService

    init(memory: Memory, memoryDataService: MemoryDataService) {
        self.memory = memory
        self.memoryDataService = memoryDataService
    }

    func toggleFavourite() {
        do {
            try memoryDataService.toggleFavourite(memory)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteMemory() {
        do {
            try memoryDataService.delete(memory)
            isDeleted = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
