
import SwiftUI
import SwiftData

/// Extracted item view to properly observe SwiftData changes on individual Memories
struct MemoryDetailItemView: View {
    let memory: Memory
    let memoryDataService: MemoryDataService
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let horizontalPadding: CGFloat = 20
            let cardWidth = screenWidth - horizontalPadding * 2
            let cardHeight = geo.size.height - 120

            // Center everything vertically inside the container page
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Main card with image, overlays, and bottom bar
                    ZStack(alignment: .bottom) {
                        // Image with top overlays
                        ZStack(alignment: .top) {
                            // Photo
                            MemoryImageView(
                                fileName: memory.imageFileName,
                                cornerRadius: 24
                            )
                            .frame(width: cardWidth)
                            .clipped()

                            // Top overlay — location badge + delete button
                            HStack {
                                // Location badge
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(Color.snapAccent)
                                    Text(memory.locationName.uppercased())
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
                            .padding(16)
                        }

                        // Bottom section overlaid on image: caption + time/heart bar
                        VStack(spacing: 0) {
                            // Caption
                            if !memory.caption.isEmpty {
                                Text(memory.caption)
                                    .font(.body)
                                    .foregroundColor(.snapTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                         RoundedRectangle(cornerRadius: 16)
                                             .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                     )
                                    .padding(.horizontal, 16)
                                
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
                                    toggleFavourite()
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

    private func toggleFavourite() {
        do {
            try memoryDataService.toggleFavourite(memory)
        } catch {
            print("Failed to toggle favourite: \(error)")
        }
    }
}

#Preview {
    MemoryDetailItemView(
        memory: PreviewContainer.sampleMemory,
        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
        onDelete: {
            print("Delete requested in preview")
        }
    )
    .background(Color.snapBackground)
    .modelContainer(PreviewContainer.shared)
}
