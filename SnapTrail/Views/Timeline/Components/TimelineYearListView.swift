import SwiftUI
import SwiftData

struct TimelineYearListView: View {
    let yearGroups: [TimelineYearGroup]
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService

    private let columns = [
        GridItem(.adaptive(minimum: 360, maximum: 640), spacing: 22, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 22) {
                ForEach(yearGroups) { yearGroup in
                    TimelineYearCard(
                        group: yearGroup,
                        allMemories: allMemories,
                        memoryDataService: memoryDataService
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.snapBackground.ignoresSafeArea()
            TimelineYearListView(
                yearGroups: TimelinePreviewData.yearGroups,
                allMemories: TimelinePreviewData.memories,
                memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
            )
        }
    }
    .modelContainer(PreviewContainer.shared)
}
