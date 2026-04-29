import SwiftUI
import SwiftData

/// A vertically scrollable memory detail view.
/// Accepts a list of memories and an initial index.
/// Scrolls to the tapped memory on appear, user can scroll up/down to view others page-by-page.
struct MemoryDetailView: View {
    // Local state array so we can remove items dynamically when deleted
    @State private var localMemories: [Memory]
    let initialIndex: Int
    let memoryDataService: MemoryDataService

    @Environment(\.dismiss) private var dismiss
    @State private var hasScrolledToInitial = false
    /// Tracks the index of the page currently visible on screen.
    @State private var currentIndex: Int = 0

    init(memories: [Memory], initialIndex: Int, memoryDataService: MemoryDataService) {
        _localMemories = State(initialValue: memories)
        self.initialIndex = initialIndex
        self.memoryDataService = memoryDataService
    }

    /// Convenience init for single memory
    init(memory: Memory, memoryDataService: MemoryDataService) {
        self.init(memories: [memory], initialIndex: 0, memoryDataService: memoryDataService)
    }

    var body: some View {
        ZStack {
            Color.snapBackground.ignoresSafeArea()

            if localMemories.isEmpty {
                VStack {
                    Spacer()
                    Text("No memories left")
                        .foregroundColor(.snapTextSecondary)
                    Spacer()
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(localMemories.enumerated()), id: \.element.id) { index, memory in
                                MemoryDetailItemView(
                                    memory: memory,
                                    memoryDataService: memoryDataService,
                                    onDelete: {
                                        deleteMemory(memory, proxy: proxy)
                                    }
                                )
                                // Use stable UUID — not integer index — so SwiftUI never
                                // confuses views when items are removed and indices shift.
                                .id(memory.id)
                                // Makes each card take exactly the height of the ScrollView (TikTok style)
                                .containerRelativeFrame(.vertical)
                                // Track which page is currently filling the screen
                                .onAppear { currentIndex = index }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .ignoresSafeArea(edges: .bottom) // Allows cards to go to the bottom edge
                    .onAppear {
                        if !hasScrolledToInitial && !localMemories.isEmpty {
                            // Scroll to the tapped memory without animation on load
                            proxy.scrollTo(localMemories[initialIndex].id, anchor: .top)
                            currentIndex = initialIndex
                            hasScrolledToInitial = true
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("SNAPTRAIL")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(Color.snapAccent)
            }
        }
        .toolbarBackground(Color.snapBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func deleteMemory(_ memory: Memory, proxy: ScrollViewProxy) {
        // Find the position of the item being deleted before we remove it
        guard let deletedIndex = localMemories.firstIndex(where: { $0.id == memory.id }) else { return }

        // Decide which neighbour to land on after deletion:
        // • Not the first item  → scroll UP to the previous one
        // • Is the first item   → scroll DOWN to the next one (which becomes index 0 after removal)
        let targetID: UUID? = {
            if deletedIndex > 0 {
                return localMemories[deletedIndex - 1].id   // item before
            } else if localMemories.count > 1 {
                return localMemories[deletedIndex + 1].id   // item after (first becomes new head)
            }
            return nil  // only one item left — will dismiss
        }()

        do {
            try memoryDataService.delete(memory)
            localMemories.remove(at: deletedIndex)

            if localMemories.isEmpty {
                dismiss()
                return
            }

            // Scroll to the chosen neighbour using its stable UUID
            if let id = targetID {
                DispatchQueue.main.async {
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        } catch {
            print("Failed to delete memory: \(error)")
        }
    }
}


#Preview {
    NavigationStack {
        MemoryDetailView(
            memories: [PreviewContainer.sampleMemory],
            initialIndex: 0,
            memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
        )
    }
    .modelContainer(PreviewContainer.shared)
}
