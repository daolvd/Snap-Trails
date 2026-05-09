import SwiftUI
import SwiftData

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    let categoryDataService: CategoryDataService
    @Environment(\.dismiss) private var dismiss
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                if viewModel.favourites.isEmpty {
                    EmptyStateView(
                        icon: "heart.slash",
                        title: "No Favorites Yet",
                        message: "Tap the heart icon on any memory to save it here."
                    )
                } else {
                    GeometryReader { geo in
                        let screenWidth = geo.size.width
                        let padding: CGFloat = 20
                        let gridSpacing: CGFloat = 12
                        let contentWidth = screenWidth - padding * 2
                        let gridItemWidth = (contentWidth - gridSpacing) / 2
                        // Featured card height is proportional
                        let featuredHeight = min(contentWidth * 0.75, 380)
                        let gridItemHeight = min(gridItemWidth * 0.85, 180)

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 16) {
                                // Header
                                HStack {
                                    Text("Favorite Memories")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.snapTextPrimary)
                                    Spacer()
                                    Image(systemName: "heart.fill")
                                        .font(.title2)
                                        .foregroundColor(.snapTextSecondary)
                                }
                                .padding(.horizontal, 4)

                                // Grid layout matching design
                                if let first = viewModel.favourites.first {
                                    // Featured card
                                    Button {
                                        pushDetail(index: 0)
                                    } label: {
                                        featuredCard(
                                            memory: first,
                                            width: contentWidth,
                                            height: featuredHeight
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }

                                // Grid of remaining
                                let remaining = Array(viewModel.favourites.dropFirst())
                                let rows = stride(from: 0, to: remaining.count, by: 2).map {
                                    Array(remaining[$0..<min($0 + 2, remaining.count)])
                                }

                                ForEach(Array(rows.enumerated()), id: \.offset) { rowIdx, row in
                                    HStack(spacing: gridSpacing) {
                                        ForEach(row, id: \.id) { memory in
                                            let memoryIndex = viewModel.favourites.firstIndex(
                                                where: { $0.id == memory.id }
                                            ) ?? 0

                                            Button {
                                                pushDetail(index: memoryIndex)
                                            } label: {
                                                gridCard(
                                                    memory: memory,
                                                    width: gridItemWidth,
                                                    height: gridItemHeight
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }

                                        if row.count == 1 {
                                            Spacer()
                                                .frame(width: gridItemWidth)
                                        }
                                    }
                                }
                            }
                            .padding(padding)
                        }
                    }
                }
            }
            .navigationDestination(for: Int.self) { index in
                MemoryDetailView(
                    memories: viewModel.favourites,
                    initialIndex: index,
                    memoryDataService: viewModel.memoryDataService,
                    categoryDataService: categoryDataService
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.snapTextSecondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("SnapTrail")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(Color.snapAccent)
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.fetchFavourites()
            }
        }
    }

    private func pushDetail(index: Int) {
        guard path.isEmpty else { return }
        path.append(index)
    }

    private func featuredCard(memory: Memory, width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            MemoryImageView(fileName: memory.imageFileName, cornerRadius: 20)
                .frame(width: width, height: height)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                if !memory.locationName.isEmpty {
                    Text(memory.locationName)
                        .font(.caption)
                        .foregroundColor(.snapTextPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                if !memory.caption.isEmpty {
                    Text(memory.caption)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.snapTextPrimary)
                        .lineLimit(2)
                }
            }
            .padding(16)
        }
    }

    private func gridCard(memory: Memory, width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            MemoryImageView(fileName: memory.imageFileName, cornerRadius: 16)
                .frame(width: width, height: height)
                .clipped()

            VStack(alignment: .leading) {
                Text(memory.caption.isEmpty
                     ? DateFormatterHelper.displayDate(memory.dateTime)
                     : memory.caption)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.snapTextPrimary)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding(10)
        }
    }
}

#Preview {
    FavoritesView(
        viewModel: FavoritesViewModel(
            memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
        ),
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}
