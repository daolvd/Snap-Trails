import SwiftUI
import SwiftData

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                if viewModel.memories.isEmpty {
                    EmptyStateView(
                        icon: "photo.on.rectangle.angled",
                        title: "No Memories Yet",
                        message: "Capture your first memory by tapping the camera tab below."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(viewModel.memories.enumerated()), id: \.element.id) { index, memory in
                                NavigationLink {
                                    MemoryDetailView(
                                        memories: viewModel.memories,
                                        initialIndex: index,
                                        memoryDataService: viewModel.memoryDataService
                                    )
                                } label: {
                                    MemoryCardView(memory: memory) {
                                        viewModel.toggleFavourite(memory)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SNAPTRAIL")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color.snapAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.snapAccent)
                    }
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showSearch) {
                SearchView(
                    viewModel: SearchViewModel(
                        memoryDataService: viewModel.memoryDataService,
                        categoryDataService: CategoryDataService(
                            modelContext: viewModel.memoryDataService.modelContext
                        )
                    )
                )
            }
            .onAppear {
                viewModel.fetchMemories()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    TimelineView(
        viewModel: TimelineViewModel(
            memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
        )
    )
    .modelContainer(PreviewContainer.shared)
}
