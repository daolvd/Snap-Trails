import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundColor(Color.snapAccent.opacity(0.5))

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.snapTextPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.snapTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        EmptyStateView(
            icon: "photo.on.rectangle.angled",
            title: "No Memories Yet",
            message: "Capture your first memory by tapping the camera tab below."
        )
    }
}
