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
                    VStack(spacing: 0) {
                        // Segmented picker
                        timelineModePicker
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 4)

                        // Content
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                ForEach(
                                    Array(viewModel.groupedMemories.enumerated()),
                                    id: \.element.key
                                ) { _, section in
                                    Section {
                                        sectionContent(
                                            memories: section.memories
                                        )
                                    } header: {
                                        sectionHeader(
                                            title: section.key,
                                            count: section.memories.count
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.groupMode)
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

    // MARK: - Segmented Picker

    private var timelineModePicker: some View {
        HStack(spacing: 4) {
            ForEach(TimelineGroupMode.allCases) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.groupMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            viewModel.groupMode == mode
                            ? .black
                            : .snapTextSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.groupMode == mode
                            ? Color.snapAccent
                            : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.snapCard)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.snapTextPrimary)

            Spacer()

            Text(viewModel.countLabel(for: count))
                .font(.caption)
                .foregroundColor(.snapTextSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color.snapBackground
                .opacity(0.95)
        )
        .background(.ultraThinMaterial)
    }

    // MARK: - Section Content

    @ViewBuilder
    private func sectionContent(memories: [Memory]) -> some View {
        switch viewModel.groupMode {
        case .year, .month:
            gridContent(memories: memories)
        case .day:
            listContent(memories: memories)
        }
    }

    // MARK: - Grid Layout (Year / Month)

    private func gridContent(memories: [Memory]) -> some View {
        GeometryReader { geo in
            let spacing: CGFloat = 3
            let columns = 3
            let totalSpacing = spacing * CGFloat(columns - 1) + 20 * 2
            let itemSize = (geo.size.width - totalSpacing) / CGFloat(columns)

            let rows = stride(from: 0, to: memories.count, by: columns).map {
                Array(memories[$0..<min($0 + columns, memories.count)])
            }

            VStack(spacing: spacing) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.id) { memory in
                            NavigationLink {
                                MemoryDetailView(
                                    memories: viewModel.memories,
                                    initialIndex: viewModel.memories.firstIndex(
                                        where: { $0.id == memory.id }
                                    ) ?? 0,
                                    memoryDataService: viewModel.memoryDataService
                                )
                            } label: {
                                TimelineGridItemView(
                                    memory: memory,
                                    size: itemSize
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // Fill remaining space if row is incomplete
                        if row.count < columns {
                            ForEach(0..<(columns - row.count), id: \.self) { _ in
                                Color.clear
                                    .frame(width: itemSize, height: itemSize)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: gridHeight(for: memories.count, in: 3))
    }

    /// Calculates the height needed for the grid
    private func gridHeight(for itemCount: Int, in columns: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 3
        let totalSpacing = spacing * CGFloat(columns - 1) + 20 * 2
        let itemSize = (screenWidth - totalSpacing) / CGFloat(columns)
        let rowCount = ceil(Double(itemCount) / Double(columns))
        return CGFloat(rowCount) * (itemSize + spacing) - spacing + 8
    }

    // MARK: - List Layout (Day)

    private func listContent(memories: [Memory]) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(memories.enumerated()), id: \.element.id) { _, memory in
                NavigationLink {
                    MemoryDetailView(
                        memories: viewModel.memories,
                        initialIndex: viewModel.memories.firstIndex(
                            where: { $0.id == memory.id }
                        ) ?? 0,
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
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
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
