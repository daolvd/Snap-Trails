//
//  CategoryManagementViewModel.swift
//  SnapTrail
//
//  Created by Quang Huy Vu on 11/5/2026.
//

import SwiftUI
import Combine

/// View model powering the full category management screen.
/// Supports listing, creating, editing, and deleting categories,
/// plus surfacing the memory count for each category.
@MainActor
final class CategoryManagementViewModel: ObservableObject {

    // MARK: - List state
    @Published var categories: [MemoryCategory] = []
    @Published var snapCounts: [UUID: Int] = [:]

    // MARK: - Create / Edit form state
    @Published var formName: String = ""
    @Published var formIcon: CategoryIcon = .tag
    @Published var formColor: CategoryColor = .green

    // MARK: - UI state
    @Published var isShowingCreateSheet = false
    @Published var editingCategory: MemoryCategory? = nil   // non-nil → edit sheet open
    @Published var categoryToDelete: MemoryCategory? = nil  // non-nil → delete confirm
    @Published var errorMessage: String? = nil

    private let categoryDataService: CategoryDataService
    private let memoryDataService: MemoryDataService

    init(categoryDataService: CategoryDataService,
         memoryDataService: MemoryDataService) {
        self.categoryDataService = categoryDataService
        self.memoryDataService = memoryDataService
    }

    // MARK: - Fetch

    func fetchCategories() {
        do {
            categories = try categoryDataService.fetchAll()
            refreshSnapCounts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshSnapCounts() {
        var counts: [UUID: Int] = [:]
        for category in categories {
            counts[category.id] = category.memories.count
        }
        snapCounts = counts
    }

    func snapCount(for category: MemoryCategory) -> Int {
        snapCounts[category.id] ?? 0
    }

    // MARK: - Create

    func openCreateSheet() {
        formName = ""
        formIcon = .tag
        formColor = .green
        isShowingCreateSheet = true
    }

    func createCategory() {
        do {
            try categoryDataService.create(
                name: formName,
                iconName: formIcon.rawValue,
                colorName: formColor.rawValue
            )
            isShowingCreateSheet = false
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Edit

    func openEditSheet(for category: MemoryCategory) {
        formName = category.name
        formIcon = CategoryIcon(rawValue: category.iconName) ?? .tag
        formColor = CategoryColor(rawValue: category.colorName) ?? .green
        editingCategory = category
    }

    func saveEdit() {
        guard let category = editingCategory else { return }
        do {
            try categoryDataService.update(
                category,
                name: formName,
                iconName: formIcon.rawValue,
                colorName: formColor.rawValue
            )
            editingCategory = nil
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelEdit() {
        editingCategory = nil
    }

    // MARK: - Delete

    func confirmDelete(_ category: MemoryCategory) {
        categoryToDelete = category
    }

    func executeDelete() {
        guard let category = categoryToDelete else { return }
        do {
            try categoryDataService.delete(category)
            categoryToDelete = nil
            fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelDelete() {
        categoryToDelete = nil
    }

    // MARK: - Form validation

    var isFormValid: Bool {
        !formName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
