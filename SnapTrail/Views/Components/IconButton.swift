import SwiftUI

struct IconButton: View {
    let systemName: String
    let size: CGFloat
    let foreground: Color
    let background: Color
    let action: () -> Void

    init(
        systemName: String,
        size: CGFloat = 56,
        foreground: Color = .white,
        background: Color = Color.snapCardLight,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.size = size
        self.foreground = foreground
        self.background = background
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(foreground)
                .frame(width: size, height: size)
                .background(background)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        HStack(spacing: 24) {
            IconButton(systemName: "xmark") {}
            IconButton(
                systemName: "checkmark",
                foreground: .black,
                background: Color.snapAccent
            ) {}
            IconButton(systemName: "heart.fill", foreground: .pink) {}
        }
    }
}
