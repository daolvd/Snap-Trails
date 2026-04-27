import SwiftUI

struct LoadingView: View {
    let message: String

    init(_ message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.snapAccent))
                .scaleEffect(1.2)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.snapTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        LoadingView("Saving memory...")
    }
}
