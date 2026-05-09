import SwiftUI
import SwiftData

struct TimelineDayListView: View {
    let yearGroups: [TimelineYearGroup]
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService
    let onToggleFavourite: (Memory) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 28, pinnedViews: [.sectionHeaders]) {
                ForEach(yearGroups) { yearGroup in
                    Section {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(yearGroup.months) { monthGroup in
                                TimelineMonthSection(
                                    group: monthGroup,
                                    allMemories: allMemories,
                                    memoryDataService: memoryDataService,
                                    categoryDataService: categoryDataService,
                                    onToggleFavourite: onToggleFavourite
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    } header: {
                        TimelineYearHeader(group: yearGroup)
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.snapBackground.ignoresSafeArea()
            TimelineDayListView(
                yearGroups: TimelinePreviewData.yearGroups,
                allMemories: TimelinePreviewData.memories,
                memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
                categoryDataService: CategoryDataService(modelContext: PreviewContainer.context),
                onToggleFavourite: { _ in }
            )
        }
    }
    .modelContainer(PreviewContainer.shared)
}
