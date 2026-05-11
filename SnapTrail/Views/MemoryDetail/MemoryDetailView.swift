import SwiftUI
import SwiftData

/// A vertically scrollable memory detail view.
struct MemoryDetailView: View {
    @State private var localMemories: [Memory]
    let initialIndex: Int
    let services: AppServices

    @Environment(\.dismiss) private var dismiss
    @State private var hasScrolledToInitial = false
    @State private var currentIndex: Int = 0

    init(
        memories: [Memory],
        initialIndex: Int,
        services: AppServices
    ) {
        _localMemories = State(initialValue: memories)
        self.initialIndex = initialIndex
        self.services = services
    }

    init(memory: Memory, services: AppServices) {
        self.init(memories: [memory], initialIndex: 0, services: services)
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
                                    services: services,
                                    onDelete: {
                                        deleteMemory(memory, proxy: proxy)
                                    }
                                )
                                .id(memory.id)
                                .containerRelativeFrame(.vertical)
                                .onAppear { currentIndex = index }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .ignoresSafeArea(edges: .bottom)
                    .onAppear {
                        if !hasScrolledToInitial && !localMemories.isEmpty {
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
        guard let deletedIndex = localMemories.firstIndex(where: { $0.id == memory.id }) else { return }

        let targetID: UUID? = {
            if deletedIndex > 0 {
                return localMemories[deletedIndex - 1].id
            } else if localMemories.count > 1 {
                return localMemories[deletedIndex + 1].id
            }
            return nil
        }()

        do {
            try services.memoryDataService.delete(memory)
            localMemories.remove(at: deletedIndex)

            if localMemories.isEmpty {
                dismiss()
                return
            }

            if let id = targetID {
                DispatchQueue.main.async {
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        } catch {
            AppLog.error("Failed to delete memory", category: .data, error: error)
        }
    }
}

#Preview {
    NavigationStack {
        MemoryDetailView(
            memories: [PreviewContainer.sampleMemory],
            initialIndex: 0,
            services: AppServices(modelContext: PreviewContainer.context)
        )
    }
    .modelContainer(PreviewContainer.shared)
}
