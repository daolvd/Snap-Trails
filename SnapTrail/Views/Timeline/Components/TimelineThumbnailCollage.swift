import SwiftUI

struct TimelineThumbnailCollage: View {
    let memories: [Memory]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Color.snapCardLight
                content(size: size)
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
    }

    @ViewBuilder
    private func content(size: CGSize) -> some View {
        let preview = Array(memories.prefix(4))
        switch preview.count {
        case 0:
            Image(systemName: "photo.stack")
                .font(.largeTitle)
                .foregroundColor(.snapTextSecondary)
        case 1:
            MemoryImageView(fileName: preview[0].imageFileName, cornerRadius: 0)
        case 2:
            HStack(spacing: 2) {
                MemoryImageView(fileName: preview[0].imageFileName, cornerRadius: 0)
                    .frame(width: (size.width - 2) / 2)
                MemoryImageView(fileName: preview[1].imageFileName, cornerRadius: 0)
                    .frame(width: (size.width - 2) / 2)
            }
        case 3:
            HStack(spacing: 2) {
                MemoryImageView(fileName: preview[0].imageFileName, cornerRadius: 0)
                    .frame(width: (size.width - 2) / 2)
                VStack(spacing: 2) {
                    MemoryImageView(fileName: preview[1].imageFileName, cornerRadius: 0)
                        .frame(height: (size.height - 2) / 2)
                    MemoryImageView(fileName: preview[2].imageFileName, cornerRadius: 0)
                        .frame(height: (size.height - 2) / 2)
                }
                .frame(width: (size.width - 2) / 2)
            }
        default:
            let cell = CGSize(width: (size.width - 2) / 2, height: (size.height - 2) / 2)
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    MemoryImageView(fileName: preview[0].imageFileName, cornerRadius: 0)
                        .frame(width: cell.width, height: cell.height)
                    MemoryImageView(fileName: preview[1].imageFileName, cornerRadius: 0)
                        .frame(width: cell.width, height: cell.height)
                }
                HStack(spacing: 2) {
                    MemoryImageView(fileName: preview[2].imageFileName, cornerRadius: 0)
                        .frame(width: cell.width, height: cell.height)
                    MemoryImageView(fileName: preview[3].imageFileName, cornerRadius: 0)
                        .frame(width: cell.width, height: cell.height)
                }
            }
        }
    }
}

#Preview("1 to 4 photos") {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        VStack(spacing: 12) {
            ForEach(1...4, id: \.self) { count in
                TimelineThumbnailCollage(memories: Array(TimelinePreviewData.memories.prefix(count)))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
    }
}
