import SwiftUI
import SwiftData

struct TimelineYearCard: View {
    let group: TimelineYearGroup
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService

    var body: some View {
        let yearMemories = group.months.flatMap { $0.days.flatMap { $0.memories } }
        let firstMemory = yearMemories.first
        let firstIndex = firstMemory.flatMap { m in
            allMemories.firstIndex(where: { $0.id == m.id })
        } ?? 0

        NavigationLink {
            if firstMemory != nil {
                MemoryDetailView(
                    memories: allMemories,
                    initialIndex: firstIndex,
                    memoryDataService: memoryDataService
                )
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                TimelineThumbnailCollage(memories: yearMemories)
                    .aspectRatio(16.0/10.0, contentMode: .fit)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 22,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 22,
                            style: .continuous
                        )
                    )

                HStack(alignment: .firstTextBaseline) {
                    Text(verbatim: String(group.year))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.snapTextPrimary)
                    Spacer()
                    Text("\(group.memoryCount) memories")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.snapTextSecondary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color.snapCard)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 22,
                        bottomTrailingRadius: 22,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.snapBackground.ignoresSafeArea()
            ScrollView {
                TimelineYearCard(
                    group: TimelinePreviewData.yearGroup,
                    allMemories: TimelinePreviewData.memories,
                    memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
                )
                .padding()
            }
        }
    }
    .modelContainer(PreviewContainer.shared)
}
