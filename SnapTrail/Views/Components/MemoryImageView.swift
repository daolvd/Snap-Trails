import SwiftUI

struct MemoryImageView: View {
    let fileName: String
    var cornerRadius: CGFloat = 20

    var body: some View {
        Color.snapCardLight
            .overlay {
                if let uiImage = ImageStorageService.loadImage(fileName: fileName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.snapTextSecondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview("Circle avatar") {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        HStack(spacing: 16) {
            MemoryImageView(fileName: "preview-1.jpg", cornerRadius: 30)
                .frame(width: 60, height: 60)
            MemoryImageView(fileName: "missing.jpg", cornerRadius: 30)
                .frame(width: 60, height: 60)
        }
    }
}

#Preview("Rounded rect") {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        MemoryImageView(fileName: "preview-1.jpg")
            .frame(width: 300, height: 200)
            .padding()
    }
}
