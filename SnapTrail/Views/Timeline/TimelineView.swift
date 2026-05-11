import SwiftUI
import SwiftData

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    let categoryDataService: CategoryDataService
    @State private var showSearch = false
    @State private var displayMode: TimelineDisplayMode = .day

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
                    VStack(spacing: 0) {
                        TimelineModePicker(mode: $displayMode)
                        contentForMode
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
                        categoryDataService: categoryDataService
                    ),
                    categoryDataService: categoryDataService
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

    @ViewBuilder
    private var contentForMode: some View {
        switch displayMode {
        case .day:
            TimelineDayListView(
                yearGroups: viewModel.groupedMemories,
                allMemories: viewModel.memories,
                memoryDataService: viewModel.memoryDataService,
                categoryDataService: categoryDataService,
                onToggleFavourite: viewModel.toggleFavourite
            )
        case .month:
            TimelineMonthListView(
                yearGroups: viewModel.groupedMemories,
                allMemories: viewModel.memories,
                memoryDataService: viewModel.memoryDataService,
                categoryDataService: categoryDataService
            )
        case .year:
            TimelineYearListView(
                yearGroups: viewModel.groupedMemories,
                allMemories: viewModel.memories,
                memoryDataService: viewModel.memoryDataService,
                categoryDataService: categoryDataService
            )
        }
    }
}

#Preview {
    TimelineView(
        viewModel: TimelineViewModel(
            memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
        ),
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}
