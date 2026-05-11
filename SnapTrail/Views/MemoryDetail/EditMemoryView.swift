import SwiftUI
import SwiftData

/// Full-screen sheet that lets the user edit every field of a saved Memory:
/// caption, location name, date/time, and category tag.
struct EditMemoryView: View {
    let memory: Memory
    let services: AppServices
    let onSave: () -> Void

    @StateObject private var viewModel: EditMemoryViewModel
    @StateObject private var categoryVM: CategoryViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var showNewTagField = false

    init(
        memory: Memory,
        services: AppServices,
        onSave: @escaping () -> Void
    ) {
        self.memory = memory
        self.services = services
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: EditMemoryViewModel(
            memory: memory,
            memoryDataService: services.memoryDataService,
            locationService: services.makeLocationService(),
            geocodingService: services.geocodingService
        ))
        _categoryVM = StateObject(wrappedValue: CategoryViewModel(
            categoryDataService: services.categoryDataService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Photo preview (read-only thumbnail)
                        photoThumbnail
                            .padding(.top, 16)
                            .padding(.horizontal, 20)

                        // Form fields
                        VStack(spacing: 20) {
                            captionSection
                            locationSection
                            dateTimeSection
                            tagSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }

                // Save / Cancel pinned at bottom
                VStack {
                    Spacer()
                    bottomActions
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Memory")
                        .font(.headline)
                        .foregroundColor(.snapTextPrimary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.snapTextSecondary)
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                categoryVM.fetchCategories()
            }
            .onChange(of: viewModel.didSave) { _, saved in
                if saved {
                    onSave()
                    dismiss()
                }
            }
            .onChange(of: categoryVM.newCategoryName) { _, _ in
                if categoryVM.errorMessage != nil {
                    categoryVM.errorMessage = nil
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Photo thumbnail

    private var photoThumbnail: some View {
        MemoryImageView(
            fileName: memory.imageFileName,
            cornerRadius: 20
        )
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Caption

    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Caption", icon: "text.alignleft")

            VStack(alignment: .trailing, spacing: 4) {
                TextField("Add a field note...", text: $viewModel.caption, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.snapTextPrimary)
                    .lineLimit(3...8)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.snapCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )

                if let warning = viewModel.captionWarning {
                    Text(warning)
                        .font(.caption2)
                        .foregroundColor(
                            viewModel.captionCharacterCount >= viewModel.captionMaxLength
                                ? .red : .orange
                        )
                        .padding(.horizontal, 4)
                }
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Location", icon: "mappin.and.ellipse")

            HStack(spacing: 10) {
                TextField("Location name", text: $viewModel.locationName)
                    .font(.subheadline)
                    .foregroundColor(.snapTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.snapCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )

                // Re-fetch current GPS location
                Button {
                    viewModel.refreshLocationFromDevice()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.snapCard)
                            .frame(width: 44, height: 44)
                        if viewModel.isFetchingLocation {
                            ProgressView()
                                .tint(Color.snapAccent)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "location.fill")
                                .font(.body)
                                .foregroundColor(Color.snapAccent)
                        }
                    }
                }
                .disabled(viewModel.isFetchingLocation)
            }
        }
    }

    // MARK: - Date & Time

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Date & Time", icon: "calendar.clock")

            DatePicker(
                "",
                selection: $viewModel.dateTime,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .colorScheme(.dark)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.snapCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Tag (Category)

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Trail Tag", icon: "tag.fill")

            Menu {
                Button("None") { viewModel.selectedCategory = nil }
                ForEach(categoryVM.categories, id: \.id) { cat in
                    Button {
                        viewModel.selectedCategory = cat
                    } label: {
                        Label(cat.name, systemImage: cat.iconName)
                    }
                }
                Divider()
                Button {
                    withAnimation { showNewTagField.toggle() }
                } label: {
                    Label("Create New Tag", systemImage: "plus")
                }
            } label: {
                HStack {
                    if let cat = viewModel.selectedCategory {
                        Image(systemName: cat.iconName)
                            .font(.caption)
                            .foregroundColor(Color.snapAccent)
                        Text(cat.name)
                            .foregroundColor(.snapTextPrimary)
                    } else {
                        Text("Select Tag")
                            .foregroundColor(.snapTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.snapTextSecondary)
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.snapCard)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }

            if showNewTagField {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("New tag name", text: $categoryVM.newCategoryName)
                            .font(.subheadline)
                            .foregroundColor(.snapTextPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.snapCard)
                            .cornerRadius(12)

                        Button {
                            if categoryVM.createCategory() {
                                showNewTagField = false
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.snapAccent)
                        }
                        .disabled(
                            categoryVM.newCategoryName
                                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                    }

                    if let msg = categoryVM.errorMessage {
                        HStack {
                            Text(msg)
                                .font(.caption)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(CategoryIcon.allCases) { icon in
                                Button {
                                    categoryVM.selectedIcon = icon
                                } label: {
                                    Image(systemName: icon.rawValue)
                                        .font(.body)
                                        .foregroundColor(
                                            categoryVM.selectedIcon == icon ? .black : .snapTextSecondary
                                        )
                                        .frame(width: 36, height: 36)
                                        .background(
                                            categoryVM.selectedIcon == icon
                                                ? Color.snapAccent : Color.snapCard
                                        )
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showNewTagField)
    }

    // MARK: - Bottom actions

    private var bottomActions: some View {
        HStack(spacing: 16) {
            // Cancel
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.snapTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.snapCard)
                    .cornerRadius(16)
            }

            // Save
            Button {
                viewModel.saveEdits()
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.black)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                    Text("Save")
                        .font(.headline)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.snapAccent)
                .cornerRadius(16)
            }
            .disabled(viewModel.isSaving || !viewModel.isCaptionValid)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 12)
        .background(
            Color.snapBackground
                .opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color.snapAccent)
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.snapTextSecondary)
                .tracking(0.5)
        }
    }
}

#Preview {
    EditMemoryView(
        memory: PreviewContainer.sampleMemory,
        services: AppServices(modelContext: PreviewContainer.context),
        onSave: {}
    )
    .modelContainer(PreviewContainer.shared)
}
