//
//  ProfileView.swift
//  SnapTrail
//
//  Created by Quang Huy Vu on 09/5/2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    @StateObject private var vm: ProfileViewModel
    @State private var showFavourites = false
    @State private var showCategories = false
    @State private var pickerItem: PhotosPickerItem?

    init(
        viewModel: SettingsViewModel,
        memoryDataService: MemoryDataService,
        categoryDataService: CategoryDataService
    ) {
        self.settingsViewModel = viewModel
        self.memoryDataService = memoryDataService
        self.categoryDataService = categoryDataService
        _vm = StateObject(wrappedValue: ProfileViewModel(memoryDataService: memoryDataService))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        profileHeader
                            .padding(.top, 24)
                        statsSection
                        categoriesCard
                        reminderCard
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
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
            .onAppear { vm.refreshStats() }
            .sheet(isPresented: $showFavourites) {
                FavoritesView(
                    viewModel: FavoritesViewModel(memoryDataService: memoryDataService),
                    categoryDataService: categoryDataService
                )
            }
            .sheet(isPresented: $showCategories) {
                CategoryManagementView(
                    categoryDataService: categoryDataService,
                    memoryDataService: memoryDataService
                )
            }
            .alert("Error", isPresented: .constant(settingsViewModel.errorMessage != nil)) {
                Button("OK") { settingsViewModel.errorMessage = nil }
            } message: {
                Text(settingsViewModel.errorMessage ?? "")
            }
            .onChange(of: pickerItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        vm.applyPickedImage(image)
                    }
                    pickerItem = nil
                }
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let img = vm.profileImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color.snapCardLight
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Color.snapAccent)
                        }
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.snapAccent.opacity(0.5), lineWidth: 2))

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    ZStack {
                        Circle()
                            .fill(Color.snapAccent)
                            .frame(width: 30, height: 30)
                        Image(systemName: "camera.fill")
                            .font(.caption2)
                            .foregroundColor(.black)
                    }
                }
                .offset(x: 4, y: 4)
            }
            .contextMenu {
                if vm.profileImage != nil {
                    Button(role: .destructive) {
                        vm.removePhoto()
                    } label: {
                        Label("Remove Photo", systemImage: "trash")
                    }
                }
            }

            // Name + edit
            if vm.isEditingName {
                HStack(spacing: 10) {
                    TextField("Your name", text: $vm.draftName)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.snapTextPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 220)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.snapCard)
                        .cornerRadius(12)
                        .onSubmit { vm.commitNameEdit() }

                    Button { vm.commitNameEdit() } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.snapAccent)
                    }

                    Button { vm.cancelNameEdit() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.snapTextSecondary)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Text(vm.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.snapTextPrimary)

                    Button { vm.beginEditingName() } label: {
                        Image(systemName: "pencil")
                            .font(.subheadline)
                            .foregroundColor(.snapTextSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Stats grid

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("YOUR ARCHIVES")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.snapTextSecondary)
                .tracking(1)

            HStack(spacing: 14) {
                statTile(value: vm.stats.streakCount, label: "Day Streak",
                         icon: "flame.fill", iconColor: .orange,
                         accent: vm.stats.streakCount > 0)
                statTile(value: vm.stats.totalCount, label: "All Time",
                         icon: "photo.stack.fill", iconColor: Color.snapAccent)
            }
            HStack(spacing: 14) {
                statTile(value: vm.stats.thisYearCount, label: "This Year",
                         icon: "calendar", iconColor: .purple)
                statTile(value: vm.stats.thisMonthCount, label: "This Month",
                         icon: "calendar.badge.clock", iconColor: .cyan)
            }
            HStack(spacing: 14) {
                statTile(value: vm.stats.thisWeekCount, label: "This Week",
                         icon: "clock.arrow.circlepath", iconColor: .green)

                Button { showFavourites = true } label: {
                    statTile(value: vm.stats.favouriteCount, label: "Favourites",
                             icon: "heart.fill", iconColor: .pink, isTappable: true)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func statTile(
        value: Int,
        label: String,
        icon: String,
        iconColor: Color,
        accent: Bool = false,
        isTappable: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(iconColor)
                    .padding(7)
                    .background(iconColor.opacity(0.15))
                    .clipShape(Circle())
                Spacer()
                if isTappable {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.snapTextSecondary)
                }
            }

            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(accent ? iconColor : .snapTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.snapTextSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
        .background(Color.snapCard)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    accent ? iconColor.opacity(0.35) : Color.white.opacity(0.06),
                    lineWidth: accent ? 1.5 : 1
                )
        )
    }

    // MARK: - Categories card

    private var categoriesCard: some View {
        Button { showCategories = true } label: {
            DarkCard {
                HStack(spacing: 14) {
                    Image(systemName: "tag.fill")
                        .font(.subheadline)
                        .foregroundColor(Color.snapAccent)
                        .padding(8)
                        .background(Color.snapAccent.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Manage Categories")
                            .font(.headline)
                            .foregroundColor(.snapTextPrimary)
                        Text("Create, edit, and organise your tags")
                            .font(.caption)
                            .foregroundColor(.snapTextSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.snapTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Daily reminder card

    private var reminderCard: some View {
        DarkCard {
            Toggle(isOn: Binding(
                get: { settingsViewModel.isDailyReminderEnabled },
                set: { _ in settingsViewModel.toggleDailyReminder() }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Reminder")
                        .font(.headline)
                        .foregroundColor(.snapTextPrimary)
                    Text("Capture your moment at \(AppConstants.defaultReminderHour):00")
                        .font(.caption)
                        .foregroundColor(.snapTextSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.snapAccent))
        }
    }
}

#Preview {
    ProfileView(
        viewModel: SettingsViewModel(),
        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}
