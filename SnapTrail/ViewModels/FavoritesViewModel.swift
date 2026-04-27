import SwiftUI
import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favourites: [Memory] = []
    @Published var errorMessage: String?

    let memoryDataService: MemoryDataService

    init(memoryDataService: MemoryDataService) {
        self.memoryDataService = memoryDataService
    }

    func fetchFavourites() {
        do {
            favourites = try memoryDataService.fetchFavourites()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavourite(_ memory: Memory) {
        do {
            try memoryDataService.toggleFavourite(memory)
            fetchFavourites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ memory: Memory) {
        do {
            try memoryDataService.delete(memory)
            fetchFavourites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
