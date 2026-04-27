import SwiftUI

struct MemoryImageView: View {
    let fileName: String
    var cornerRadius: CGFloat = 20

    var body: some View {
        if let uiImage = ImageStorageService.loadImage(fileName: fileName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.snapCardLight)
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.snapTextSecondary)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        MemoryImageView(fileName: "nonexistent.jpg")
            .frame(width: 300, height: 400)
            .padding()
    }
}
