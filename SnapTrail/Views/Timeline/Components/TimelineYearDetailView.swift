//
//  TimelineYearDetailView.swift
//  SnapTrail
//
//  Created by Quang Huy Vu on 11/5/2026.
//

import SwiftUI
import SwiftData

/// Shown when the user taps a year card in the Year tab.
/// Displays all months in that year as a grid of month cards.
struct TimelineYearDetailView: View {
    let yearGroup: TimelineYearGroup
    let allMemories: [Memory]
    let services: AppServices

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 240), spacing: 14, alignment: .top)
    ]

    var body: some View {
        ZStack {
            Color.snapBackground.ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(yearGroup.months) { monthGroup in
                        NavigationLink {
                            TimelineMonthDetailView(
                                monthGroup: monthGroup,
                                allMemories: allMemories,
                                services: services,
                            )
                        } label: {
                            TimelineMonthCard(
                                group: monthGroup,
                                allMemories: allMemories,
                                services: services,
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(String(yearGroup.year))
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.snapBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        TimelineYearDetailView(
            yearGroup: TimelinePreviewData.yearGroup,
            allMemories: TimelinePreviewData.memories,
            services: AppServices(modelContext: PreviewContainer.context),
        )
    }
    .modelContainer(PreviewContainer.shared)
}
