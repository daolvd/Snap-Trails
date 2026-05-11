//
//  TimelineMonthDetailView.swift
//  SnapTrail
//
//  Created by Quang Huy Vu on 11/5/2026.
//

import SwiftUI
import SwiftData

/// Shown when the user taps a month card (from either the Month tab or a Year detail).
/// Displays all days in that month using the existing TimelineMonthSection layout.
struct TimelineMonthDetailView: View {
    let monthGroup: TimelineMonthGroup
    let allMemories: [Memory]
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    /// Format: "January 2025"
    private var title: String {
        monthGroup.date.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        ZStack {
            Color.snapBackground.ignoresSafeArea()

            ScrollView {
                TimelineMonthSection(
                    group: monthGroup,
                    allMemories: allMemories,
                    memoryDataService: memoryDataService,
                    categoryDataService: categoryDataService,
                    onToggleFavourite: { _ in }
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.snapBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        TimelineMonthDetailView(
            monthGroup: TimelinePreviewData.monthGroup,
            allMemories: TimelinePreviewData.memories,
            memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
            categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
        )
    }
    .modelContainer(PreviewContainer.shared)
}
