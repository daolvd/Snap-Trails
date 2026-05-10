import SwiftUI
import SwiftData

struct TimelineMonthSection: View {
    let group: TimelineMonthGroup
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService
    let onToggleFavourite: (Memory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(group.date.formatted(.dateTime.month(.wide)))
                .font(.title2.weight(.bold))
                .foregroundColor(.snapTextPrimary)

            ForEach(Array(group.days.enumerated()), id: \.element.id) { index, dayGroup in
                TimelineDaySection(
                    group: dayGroup,
                    isLast: index == group.days.count - 1,
                    allMemories: allMemories,
                    memoryDataService: memoryDataService,
                    categoryDataService: categoryDataService,
                    onToggleFavourite: onToggleFavourite
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.snapBackground.ignoresSafeArea()
            ScrollView {
                TimelineMonthSection(
                    group: TimelinePreviewData.monthGroup,
                    allMemories: TimelinePreviewData.memories,
                    memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
                    categoryDataService: CategoryDataService(modelContext: PreviewContainer.context),
                    onToggleFavourite: { _ in }
                )
                .padding()
            }
        }
    }
    .modelContainer(PreviewContainer.shared)
}
