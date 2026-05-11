
import SwiftUI
import SwiftData

/// Extracted item view to properly observe SwiftData changes on individual Memories.
/// Supports long-press gesture to save the photo to the device's Photo Library.
struct MemoryDetailItemView: View {
    let memory: Memory
    let services: AppServices
    let onDelete: () -> Void

    @StateObject private var viewModel: MemoryDetailViewModel
    @State private var showDeleteConfirmation = false
    @State private var showFullCaption = false
    @State private var showEditSheet = false

    init(
        memory: Memory,
        services: AppServices,
        onDelete: @escaping () -> Void
    ) {
        self.memory = memory
        self.services = services
        self.onDelete = onDelete
        _viewModel = StateObject(wrappedValue: MemoryDetailViewModel(
            memory: memory,
            memoryDataService: services.memoryDataService,
            imageStorage: services.imageStorage
        ))
    }

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let horizontalPadding: CGFloat = 20
            let cardWidth = screenWidth - horizontalPadding * 2
            let cardHeight = geo.size.height - 160

            // Center everything vertically inside the container page
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Main card with image, overlays, and bottom bar
                    ZStack(alignment: .bottom) {
                        // Image with top overlays
                        ZStack(alignment: .top) {
                            // Photo — constrain height so overlays stay visible
                            MemoryImageView(
                                fileName: memory.imageFileName,
                                cornerRadius: 24
                            )
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()

                            // Top overlay — location badge + delete button
                            HStack {
                                // Location badge
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(Color.snapAccent)
                                    Text(memory.displayLocationName.uppercased())
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.snapTextPrimary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())

                                Spacer()

                                HStack(spacing: 10) {
                                    // Edit button
                                    Button {
                                        showEditSheet = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.body)
                                            .foregroundColor(.snapTextPrimary)
                                            .frame(width: 40, height: 40)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Circle())
                                    }

                                    // Delete button
                                    Button {
                                        showDeleteConfirmation = true
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .font(.body)
                                            .foregroundColor(.snapTextPrimary)
                                            .frame(width: 40, height: 40)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(16)
                        }

                        // Bottom section overlaid on image: caption + time/heart bar
                        VStack(spacing: 0) {
                            // Caption — natural size, truncated with "..." when it would exceed 45% of card height
                            if !memory.caption.isEmpty {
                                // ~22pt is the line height for .body font; cap the visible lines so the
                                // bubble cannot exceed 45% of the card height (minus vertical padding).
                                let captionLineLimit = max(1, Int((cardHeight * 0.45 - 28) / 22))

                                Text(memory.caption)
                                    .font(.body)
                                    .foregroundColor(.snapTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(captionLineLimit)
                                    .truncationMode(.tail)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                    )
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                    .onHover { isHovering in
                                        showFullCaption = isHovering
                                    }
                                    .onTapGesture {
                                        showFullCaption = true
                                    }
                                    .popover(isPresented: $showFullCaption) {
                                        ScrollView {
                                            Text(memory.caption)
                                                .font(.body)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                        }
                                        .frame(minWidth: 260, maxWidth: 320, maxHeight: 400)
                                        .presentationCompactAdaptation(.popover)
                                    }
                            }

                            // Time + Favourite row (inside the card)
                            HStack {
                                // Time badge
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    Text(DateFormatterHelper.displayTime(memory.dateTime))
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())

                                Spacer()

                                // Favourite button
                                Button {
                                    viewModel.toggleFavourite()
                                } label: {
                                    Image(systemName: memory.isFavourite ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            memory.isFavourite
                                            ? Color.pink
                                            : Color.snapCardLight
                                        )
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    // Long-press gesture to save photo to Camera Roll
                    .onLongPressGesture(minimumDuration: 0.5) {
                        viewModel.saveImageToPhotos()
                    }
                    .padding(.horizontal, horizontalPadding)

                    // Category tag below the card
                    if let cat = memory.category {
                        HStack(spacing: 8) {
                            Image(systemName: cat.iconName)
                                .font(.caption)
                                .foregroundColor(Color.snapAccent)
                            Text(cat.name)
                                .font(.subheadline)
                                .foregroundColor(.snapTextPrimary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.snapCard)
                        .clipShape(Capsule())
                        .padding(.top, 12)
                    }
                }

                Spacer()
            }
            .frame(width: geo.size.width, height: cardHeight)
            .padding(.top, 24)
        }
        // Save-to-Photos toast overlay
        .overlay(alignment: .top) {
            if let message = viewModel.saveToastMessage {
                HStack(spacing: 10) {
                    Image(systemName: viewModel.saveToastIsError ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(viewModel.saveToastIsError ? .red : .green)
                    Text(message)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.snapTextPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 60)
            }
        }
        .animation(.spring(duration: 0.4), value: viewModel.saveToastMessage)
        .sheet(isPresented: $showEditSheet) {
            EditMemoryView(
                memory: memory,
                services: services,
                onSave: {}
            )
        }
        .confirmationDialog(
            "Delete Memory",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This memory will be permanently deleted.")
        }
    }
}

#Preview {
    MemoryDetailItemView(
        memory: PreviewContainer.sampleMemory,
        services: AppServices(modelContext: PreviewContainer.context),
        onDelete: {
            print("Delete requested in preview")
        }
    )
    .background(Color.snapBackground)
    .modelContainer(PreviewContainer.shared)
}

