import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .fontWeight(.bold)
                    .font(.title3)

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title3)
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.snapAccent)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            PrimaryButton(title: "Continue", systemImage: "arrow.right") {}
            PrimaryButton(title: "Save") {}
        }
        .padding()
    }
}
