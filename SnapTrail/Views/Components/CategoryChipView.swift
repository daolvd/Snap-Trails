import SwiftUI

struct CategoryChipView: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .foregroundColor(isSelected ? .black : .snapTextPrimary)
                .background(isSelected ? Color.snapAccent : Color.snapCardLight)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        HStack(spacing: 10) {
            CategoryChipView(name: "All", isSelected: true) {}
            CategoryChipView(name: "Study", isSelected: false) {}
            CategoryChipView(name: "Food", isSelected: false) {}
            CategoryChipView(name: "Travel", isSelected: false) {}
        }
        .padding()
    }
}
