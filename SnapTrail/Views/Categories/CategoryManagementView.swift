//
//  CategoryManagementView.swift
//  SnapTrail
//
//  Created by Quang Huy Vu on 11/5/2026.
//

import SwiftUI
import SwiftData

// MARK: - Main view

struct CategoryManagementView: View {
    @StateObject private var viewModel: CategoryManagementViewModel
    @Environment(\.dismiss) private var dismiss

    init(categoryDataService: CategoryDataService,
         memoryDataService: MemoryDataService) {
        _viewModel = StateObject(wrappedValue: CategoryManagementViewModel(
            categoryDataService: categoryDataService,
            memoryDataService: memoryDataService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                if viewModel.categories.isEmpty {
                    EmptyStateView(
                        icon: "tag.slash",
                        title: "No Categories Yet",
                        message: "Tap + to create your first category and start organising your memories."
                    )
                } else {
                    categoryList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Categories")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.snapTextPrimary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.snapTextSecondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.openCreateSheet()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color.snapAccent)
                            .fontWeight(.semibold)
                    }
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { viewModel.fetchCategories() }
            // Create sheet
            .sheet(isPresented: $viewModel.isShowingCreateSheet) {
                CategoryFormSheet(
                    title: "New Category",
                    confirmLabel: "Create",
                    name: $viewModel.formName,
                    icon: $viewModel.formIcon,
                    color: $viewModel.formColor,
                    isValid: viewModel.isFormValid,
                    onConfirm: { viewModel.createCategory() },
                    onCancel: { viewModel.isShowingCreateSheet = false }
                )
            }
            // Edit sheet
            .sheet(item: $viewModel.editingCategory) { _ in
                CategoryFormSheet(
                    title: "Edit Category",
                    confirmLabel: "Save",
                    name: $viewModel.formName,
                    icon: $viewModel.formIcon,
                    color: $viewModel.formColor,
                    isValid: viewModel.isFormValid,
                    onConfirm: { viewModel.saveEdit() },
                    onCancel: { viewModel.cancelEdit() }
                )
            }
            // Delete confirmation
            .confirmationDialog(
                deleteTitle,
                isPresented: .init(
                    get: { viewModel.categoryToDelete != nil },
                    set: { if !$0 { viewModel.cancelDelete() } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Category", role: .destructive) {
                    viewModel.executeDelete()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
            } message: {
                Text(deleteMessage)
            }
            // Error alert
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Category list

    private var categoryList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Summary header
                summaryHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                // Category rows
                VStack(spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        CategoryRow(
                            category: category,
                            snapCount: viewModel.snapCount(for: category),
                            onEdit: { viewModel.openEditSheet(for: category) },
                            onDelete: { viewModel.confirmDelete(category) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Summary header

    private var summaryHeader: some View {
        HStack(spacing: 12) {
            summaryTile(
                value: "\(viewModel.categories.count)",
                label: "Categories",
                icon: "tag.fill",
                color: Color.snapAccent
            )
            summaryTile(
                value: "\(totalSnaps)",
                label: "Total Snaps",
                icon: "photo.fill",
                color: Color(red: 0.20, green: 0.60, blue: 1.00)
            )
        }
    }

    private func summaryTile(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.snapTextPrimary)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.snapTextSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.snapCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private var totalSnaps: Int {
        viewModel.snapCounts.values.reduce(0, +)
    }

    private var deleteTitle: String {
        guard let cat = viewModel.categoryToDelete else { return "Delete Category" }
        return "Delete "\(cat.name)"?"
    }

    private var deleteMessage: String {
        guard let cat = viewModel.categoryToDelete else { return "" }
        let count = viewModel.snapCount(for: cat)
        if count == 0 {
            return "This category has no snaps and will be permanently removed."
        } else {
            return "This will remove the category. The \(count) snap\(count == 1 ? "" : "s") inside will become uncategorised."
        }
    }
}

// MARK: - Category row

private struct CategoryRow: View {
    let category: MemoryCategory
    let snapCount: Int
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var accentColor: Color {
        CategoryColor.color(for: category.colorName)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Colour + icon badge
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(systemName: category.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(accentColor)
            }

            // Name + snap count
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.snapTextPrimary)
                    .lineLimit(1)
                Label(
                    "\(snapCount) snap\(snapCount == 1 ? "" : "s")",
                    systemImage: "photo.fill"
                )
                .font(.caption)
                .foregroundColor(.snapTextSecondary)
            }

            Spacer()

            // Action buttons
            HStack(spacing: 4) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundColor(.snapTextSecondary)
                        .frame(width: 36, height: 36)
                        .background(Color.snapCardLight)
                        .clipShape(Circle())
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 1, green: 0.3, blue: 0.3))
                        .frame(width: 36, height: 36)
                        .background(Color(red: 1, green: 0.3, blue: 0.3).opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Color.snapCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Shared create / edit form sheet

struct CategoryFormSheet: View {
    let title: String
    let confirmLabel: String

    @Binding var name: String
    @Binding var icon: CategoryIcon
    @Binding var color: CategoryColor

    let isValid: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {

                        // Name field
                        formSection(label: "Name") {
                            HStack {
                                TextField("e.g. Travel, Food, Study…", text: $name)
                                    .foregroundColor(.snapTextPrimary)
                                    .autocorrectionDisabled()
                                if !name.isEmpty {
                                    Button { name = "" } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.snapTextSecondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.snapCard)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }

                        // Icon picker
                        formSection(label: "Icon") {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5),
                                spacing: 10
                            ) {
                                ForEach(CategoryIcon.allCases) { item in
                                    Button {
                                        icon = item
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: item.rawValue)
                                                .font(.system(size: 22))
                                                .foregroundColor(icon == item ? .black : .snapTextSecondary)
                                                .frame(width: 52, height: 52)
                                                .background(icon == item ? Color.snapAccent : Color.snapCard)
                                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .stroke(
                                                            icon == item ? Color.clear : Color.white.opacity(0.06),
                                                            lineWidth: 1
                                                        )
                                                )
                                            Text(item.displayName)
                                                .font(.system(size: 10))
                                                .foregroundColor(icon == item ? Color.snapAccent : .snapTextSecondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Colour picker
                        formSection(label: "Colour") {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 8),
                                spacing: 10
                            ) {
                                ForEach(CategoryColor.allCases) { item in
                                    Button {
                                        color = item
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(item.color)
                                                .frame(width: 36, height: 36)
                                            if color == item {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.black)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Live preview
                        formSection(label: "Preview") {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(color.color.opacity(0.18))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: icon.rawValue)
                                        .font(.system(size: 22))
                                        .foregroundColor(color.color)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name.isEmpty ? "Category Name" : name)
                                        .font(.headline)
                                        .foregroundColor(name.isEmpty ? .snapTextSecondary : .snapTextPrimary)
                                    Text("0 snaps")
                                        .font(.caption)
                                        .foregroundColor(.snapTextSecondary)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.snapCard)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.snapTextPrimary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                        .foregroundColor(.snapTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(confirmLabel, action: onConfirm)
                        .fontWeight(.semibold)
                        .foregroundColor(isValid ? Color.snapAccent : Color.snapTextSecondary)
                        .disabled(!isValid)
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func formSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.snapTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            content()
        }
    }
}

// MARK: - Previews

#Preview("Management") {
    CategoryManagementView(
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context),
        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}

#Preview("Form") {
    CategoryFormSheet(
        title: "New Category",
        confirmLabel: "Create",
        name: .constant("Travel"),
        icon: .constant(.travel),
        color: .constant(.teal),
        isValid: true,
        onConfirm: {},
        onCancel: {}
    )
}
