//
//  SaveMemoryView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 30/4/2026.
//

import SwiftUI
import SwiftData
import CoreLocation

struct SaveMemoryView: View {
    let image: UIImage
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService
    let onDismiss: () -> Void

    @StateObject private var viewModel: SaveMemoryViewModel
    @StateObject private var categoryVM: CategoryViewModel
    @StateObject private var locationService = LocationService()

    @State private var currentLocation: CLLocation?
    @State private var isFetchingLocation = true
    @State private var showNewTagField = false
    @State private var showSuccess = false

    private let geocodingService = GeocodingService()

    init(
        image: UIImage,
        memoryDataService: MemoryDataService,
        categoryDataService: CategoryDataService,
        onDismiss: @escaping () -> Void
    ) {
        self.image = image
        self.memoryDataService = memoryDataService
        self.categoryDataService = categoryDataService
        self.onDismiss = onDismiss

        _viewModel = StateObject(wrappedValue: SaveMemoryViewModel(memoryDataService: memoryDataService))
        _categoryVM = StateObject(wrappedValue: CategoryViewModel(categoryDataService: categoryDataService))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                GeometryReader { geo in
                    let screenWidth = geo.size.width
                    let horizontalPadding: CGFloat = 20
                    let imageWidth = screenWidth - horizontalPadding * 2
                    // Use aspect ratio of ~3:4 for the photo card, clamped to reasonable bounds
                    let imageHeight = min(max(imageWidth * 1.15, 280), geo.size.height * 0.6)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Photo preview with overlay info
                            photoCard(imageWidth: imageWidth, imageHeight: imageHeight)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, 12)

                            // Trail Tag section
                            trailTagSection
                                .padding(.horizontal, 24)
                                .padding(.top, 24)

                            Spacer(minLength: 120)
                        }
                    }

                    // Bottom action buttons — pinned to bottom
                    VStack {
                        Spacer()

                        HStack {
                            // Cancel
                            IconButton(systemName: "xmark", size: 64) {
                                onDismiss()
                            }

                            Spacer()

                            // Save
                            IconButton(
                                systemName: "checkmark",
                                size: 64,
                                foreground: .black,
                                background: Color.snapAccent
                            ) {
                                let success = viewModel.saveMemory(
                                    image: image,
                                    location: currentLocation
                                )
                                if success {
                                    showSuccess = true
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 16 : 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.snapTextSecondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("SNAPTRAIL")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(Color.snapAccent)
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                categoryVM.fetchCategories()
                fetchLocation()
            }
            .overlay {
                if viewModel.isSaving {
                    LoadingView("Saving memory...")
                        .background(Color.black.opacity(0.6))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    onDismiss()
                }
            } message: {
                Text("Memory has been uploaded successfully!")
            }
            .alert("Error", isPresented: .constant(categoryVM.errorMessage != nil)) {
                Button("OK") { categoryVM.errorMessage = nil }
            } message: {
                Text(categoryVM.errorMessage ?? "")
            }
        }
    }

    // MARK: - Photo Card

    private func photoCard(imageWidth: CGFloat, imageHeight: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageWidth, height: imageHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                // Location and date badges
                HStack {
                    // Location badge
                    HStack(spacing: 6) {
                        if isFetchingLocation {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.snapAccent))
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color.snapAccent)
                        }
                        Text(isFetchingLocation ? "Fetching location..." : viewModel.locationName)
                            .font(.caption)
                            .foregroundColor(isFetchingLocation ? .snapTextSecondary : .snapTextPrimary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                    Spacer()

                    // Date badge
                    Text(DateFormatterHelper.displayDateTime(Date()))
                        .font(.caption)
                        .foregroundColor(.snapTextPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .padding(16)
            }

            // Caption input overlaid at the bottom of the image
            VStack(alignment: .trailing, spacing: 4) {
                TextField("Add a field note...", text: $viewModel.caption)
                    .font(.subheadline)
                    .foregroundColor(.snapTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                if let warning = viewModel.captionWarning {
                    Text(warning)
                        .font(.caption2)
                        .foregroundColor(
                            viewModel.captionCharacterCount >= SaveMemoryViewModel.captionMaxLength
                            ? .red : .orange
                        )
                        .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Trail Tag Section

    private var trailTagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trail Tag")
                .font(.headline)
                .foregroundColor(.snapTextPrimary)

            // Category picker
            Menu {
                Button("None") {
                    viewModel.selectedCategory = nil
                }
                ForEach(categoryVM.categories, id: \.id) { cat in
                    Button {
                        viewModel.selectedCategory = cat
                    } label: {
                        Label(cat.name, systemImage: cat.iconName)
                    }
                }

                Divider()

                Button {
                    showNewTagField.toggle()
                } label: {
                    Label("Create New Tag", systemImage: "plus")
                }
            } label: {
                HStack {
                    Text(viewModel.selectedCategory?.name ?? "Select Tag")
                        .foregroundColor(
                            viewModel.selectedCategory != nil
                            ? .snapTextPrimary : .snapTextSecondary
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.snapTextSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.snapCard)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }

            // Create new category — only shown when toggled
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
                            categoryVM.createCategory()
                            showNewTagField = false
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.snapAccent)
                        }
                        .disabled(categoryVM.newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    // Icon picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(CategoryIcon.allCases) { icon in
                                Button {
                                    categoryVM.selectedIcon = icon
                                } label: {
                                    Image(systemName: icon.rawValue)
                                        .font(.body)
                                        .foregroundColor(categoryVM.selectedIcon == icon ? .black : .snapTextSecondary)
                                        .frame(width: 36, height: 36)
                                        .background(categoryVM.selectedIcon == icon ? Color.snapAccent : Color.snapCard)
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

    private func fetchLocation() {
        isFetchingLocation = true   // ← explicitly set true at the start
        Task {
            do {
                let location = try await locationService.getCurrentLocation()
                currentLocation = location
                let name = await geocodingService.reverseGeocode(location: location)
                viewModel.locationName = name
            } catch {
                viewModel.locationName = "Location unavailable"
            }
            isFetchingLocation = false
        }
    }
}

#Preview {
    let previewImage = UIImage(systemName: "photo.fill")!
        .withTintColor(.gray, renderingMode: .alwaysOriginal)

    SaveMemoryView(
        image: previewImage,
        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context),
        onDismiss: {}
    )
    .modelContainer(PreviewContainer.shared)
}
