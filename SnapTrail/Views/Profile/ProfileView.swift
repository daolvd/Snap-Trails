//
//  ProfileView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 28/4/2026.
//

import SwiftUI

import SwiftData
import SwiftData

struct ProfileView: View {
    @ObservedObject var viewModel: SettingsViewModel
    let memoryDataService: MemoryDataService

    @State private var thisWeekCount = 0
    @State private var favouriteCount = 0
    @State private var showFavourites = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Profile icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.snapCardLight)
                                    .frame(width: 100, height: 100)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(Color.snapAccent)
                            }

                            Text("My SnapTrails")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.snapTextPrimary)
                        }
                        .padding(.top, 24)

                        // Reminder card
                        DarkCard {
                            Toggle(isOn: Binding(
                                get: { viewModel.isDailyReminderEnabled },
                                set: { _ in viewModel.toggleDailyReminder() }
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Reminder")
                                        .font(.headline)
                                        .foregroundColor(.snapTextPrimary)
                                    Text("Capture your moment at 12:00 PM")
                                        .font(.caption)
                                        .foregroundColor(.snapTextSecondary)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.snapAccent))
                        }
                        .padding(.horizontal, 20)

                        // Archives section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("YOUR ARCHIVES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.snapTextSecondary)
                                .tracking(1)

                            HStack(spacing: 14) {
                                // Memories this week
                                archiveCard(
                                    count: thisWeekCount,
                                    label: "Memories this week",
                                    icon: "clock.arrow.circlepath",
                                    gradientColors: [Color.snapCard, Color.snapCard]
                                )

                                // Favourites
                                Button {
                                    showFavourites = true
                                } label: {
                                    archiveCard(
                                        count: favouriteCount,
                                        label: "Favorites",
                                        icon: "heart.fill",
                                        gradientColors: [
                                            Color(red: 0.4, green: 0.1, blue: 0.1),
                                            Color(red: 0.3, green: 0.08, blue: 0.08)
                                        ],
                                        accentIcon: true
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SNAPTRAIL")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color.snapAccent)
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { loadStats() }
            .sheet(isPresented: $showFavourites) {
                FavoritesView(
                    viewModel: FavoritesViewModel(memoryDataService: memoryDataService)
                )
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private func loadStats() {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        ) else { return }

        do {
            let all = try memoryDataService.fetchAll()
            thisWeekCount = all.filter { $0.dateTime >= startOfWeek }.count
            favouriteCount = all.filter { $0.isFavourite }.count
        } catch {
            // Silently fail; stats show 0
        }
    }

    private func archiveCard(
        count: Int,
        label: String,
        icon: String,
        gradientColors: [Color],
        accentIcon: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                if accentIcon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(Color.snapAccent)
                        .padding(6)
                        .background(Color.snapCardLight)
                        .clipShape(Circle())
                }
            }

            Spacer()

            Image(systemName: icon)
                .font(.title)
                .foregroundColor(accentIcon ? .pink.opacity(0.5) : Color.snapAccent.opacity(0.4))

            Text("\(count)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.snapTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.snapTextSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView(
        viewModel: SettingsViewModel(),
        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}
