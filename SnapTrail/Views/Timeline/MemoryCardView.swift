import SwiftUI

struct MemoryCardView: View {
    let memory: Memory
    let onFavouriteTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            MemoryImageView(fileName: memory.imageFileName, cornerRadius: 30)
                .frame(width: 60, height: 60)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(memory.displayLocationName)
                    .font(.headline)
                    .foregroundColor(.snapTextPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.snapTextSecondary)
                    Text(DateFormatterHelper.displayDateTime(memory.dateTime))
                        .font(.caption)
                        .foregroundColor(.snapTextSecondary)
                }
            }

            Spacer()

            // Favourite
            Button(action: onFavouriteTap) {
                Image(systemName: memory.isFavourite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(memory.isFavourite ? Color.snapAccent : .snapTextSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.snapCard)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        VStack(spacing: 12) {
            MemoryCardView(
                memory: PreviewContainer.sampleMemory,
                onFavouriteTap: {}
            )
            MemoryCardView(
                memory: Memory(
                    imageFileName: "test.jpg",
                    location: GeoLocation(latitude: -33.88, longitude: 151.21, name: "Central Station"),
                    caption: "Morning commute"
                ),
                onFavouriteTap: {}
            )
        }
        .padding()
    }
}
