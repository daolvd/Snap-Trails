import SwiftUI
import SwiftData

struct TimelineMonthCard: View {
    let group: TimelineMonthGroup
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    var body: some View {
        let monthMemories = group.days.flatMap { $0.memories }
        let firstMemory = monthMemories.first
        let firstIndex = firstMemory.flatMap { m in
            allMemories.firstIndex(where: { $0.id == m.id })
        } ?? 0

        NavigationLink {
            if firstMemory != nil {
                MemoryDetailView(
                    memories: allMemories,
                    initialIndex: firstIndex,
                    memoryDataService: memoryDataService,
                    categoryDataService: categoryDataService
                )
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                TimelineThumbnailCollage(memories: monthMemories)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.date.formatted(.dateTime.month(.wide)))
                        .font(.headline)
                        .foregroundColor(.snapTextPrimary)
                    Text("\(group.memoryCount) memories")
                        .font(.caption)
                        .foregroundColor(.snapTextSecondary)
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.snapBackground.ignoresSafeArea()
            HStack(spacing: 14) {
                TimelineMonthCard(
                    group: TimelinePreviewData.monthGroup,
                    allMemories: TimelinePreviewData.memories,
                    memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
                    categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
                )
                TimelineMonthCard(
                    group: TimelinePreviewData.monthGroup,
                    allMemories: TimelinePreviewData.memories,
                    memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
                    categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
                )
            }
            .padding()
        }
    }
    .modelContainer(PreviewContainer.shared)
}
