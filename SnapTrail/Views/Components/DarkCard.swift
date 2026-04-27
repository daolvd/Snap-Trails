import SwiftUI

struct DarkCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
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
        DarkCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Reminder")
                    .foregroundColor(.snapTextPrimary)
                    .font(.headline)
                Text("Capture your moment at 12:00 PM")
                    .foregroundColor(.snapTextSecondary)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}
