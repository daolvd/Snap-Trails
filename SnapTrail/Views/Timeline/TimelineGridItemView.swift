import SwiftUI

/// A square photo thumbnail used in Year and Month grid modes.
/// Shows the image with a location overlay and optional favourite indicator.
struct TimelineGridItemView: View {
    let memory: Memory
    let size: CGFloat

    var body: some View {
        ZStack {
            // Photo thumbnail
            MemoryImageView(fileName: memory.imageFileName, cornerRadius: 12)
                .frame(width: size, height: size)
                .clipped()

            // Gradient overlay for text readability
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: size * 0.45)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Bottom-left: location name
            VStack {
                Spacer()
                HStack {
                    Text(memory.locationName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }

            // Top-right: favourite heart
            if memory.isFavourite {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.pink)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(6)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        HStack(spacing: 8) {
            TimelineGridItemView(
                memory: PreviewContainer.sampleMemory,
                size: 120
            )
            TimelineGridItemView(
                memory: {
                    let m = Memory(
                        imageFileName: "test.jpg",
                        locationName: "Central Station",
                        latitude: 0, longitude: 0,
                        caption: ""
                    )
                    return m
                }(),
                size: 120
            )
        }
    }
}
