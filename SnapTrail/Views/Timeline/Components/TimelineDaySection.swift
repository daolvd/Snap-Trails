import SwiftUI
import SwiftData

struct TimelineDaySection: View {
    let group: TimelineDayGroup
    let isLast: Bool
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService
    let onToggleFavourite: (Memory) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                TimelineDayBadge(date: group.date)
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.snapAccent.opacity(0.7), Color.snapAccent.opacity(0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .shadow(color: Color.snapAccent.opacity(0.5), radius: 4)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.date.formatted(.dateTime.weekday(.wide)))
                        .font(.headline)
                        .foregroundColor(.snapTextPrimary)
                    if let label = relativeLabel {
                        Text(label)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.snapAccent)
                    }
                }

                ForEach(group.memories) { memory in
                    NavigationLink {
                        MemoryDetailView(
                            memories: allMemories,
                            initialIndex: allMemories.firstIndex(where: { $0.id == memory.id }) ?? 0,
                            memoryDataService: memoryDataService
                        )
                    } label: {
                        MemoryCardView(memory: memory) {
                            onToggleFavourite(memory)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, isLast ? 0 : 8)
        }
    }

    private var relativeLabel: String? {
        let calendar = Calendar.current
        if calendar.isDateInToday(group.date) { return "Today" }
        if calendar.isDateInYesterday(group.date) { return "Yesterday" }
        return nil
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.snapBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    TimelineDaySection(
                        group: TimelinePreviewData.dayGroup,
                        isLast: false,
                        allMemories: TimelinePreviewData.memories,
                        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
                        onToggleFavourite: { _ in }
                    )
                    TimelineDaySection(
                        group: TimelineDayGroup(
                            id: "y",
                            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                            memories: [TimelinePreviewData.memories[2]]
                        ),
                        isLast: true,
                        allMemories: TimelinePreviewData.memories,
                        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
                        onToggleFavourite: { _ in }
                    )
                }
                .padding()
            }
        }
    }
    .modelContainer(PreviewContainer.shared)
}
