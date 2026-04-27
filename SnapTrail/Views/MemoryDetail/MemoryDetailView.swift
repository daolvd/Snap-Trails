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
                                        deleteMemory(memory)
                                    }
                                )
                                .id(index)
                                // Makes each card take exactly the height of the ScrollView (TikTok style)
                                .containerRelativeFrame(.vertical)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .ignoresSafeArea(edges: .bottom) // Allows cards to go to the bottom edge
                    .onAppear {
                        if !hasScrolledToInitial && !localMemories.isEmpty {
                            // Scroll to the tapped memory without animation on load
                            proxy.scrollTo(initialIndex, anchor: .top)
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

    private func deleteMemory(_ memory: Memory) {
        do {
            try memoryDataService.delete(memory)
            // Remove from local array so the view updates immediately
            withAnimation {
                localMemories.removeAll { $0.id == memory.id }
            }
            // If all memories are deleted, dismiss
            if localMemories.isEmpty {
                dismiss()
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
