import SwiftUI
import SwiftData

struct TimelineMonthListView: View {
    let yearGroups: [TimelineYearGroup]
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 240), spacing: 14, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 28, pinnedViews: [.sectionHeaders]) {
                ForEach(yearGroups) { yearGroup in
                    Section {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(yearGroup.months) { monthGroup in
                                TimelineMonthCard(
                                    group: monthGroup,
                                    allMemories: allMemories,
                                    memoryDataService: memoryDataService,
                                    categoryDataService: categoryDataService
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
            TimelineMonthListView(
                yearGroups: TimelinePreviewData.yearGroups,
                allMemories: TimelinePreviewData.memories,
                memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
                categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
            )
        }
    }
    .modelContainer(PreviewContainer.shared)
}
