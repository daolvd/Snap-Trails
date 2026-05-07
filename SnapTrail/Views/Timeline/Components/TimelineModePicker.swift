import SwiftUI

struct TimelineModePicker: View {
    @Binding var mode: TimelineDisplayMode

    var body: some View {
        HStack(spacing: 4) {
            ForEach(TimelineDisplayMode.allCases) { item in
                let isSelected = mode == item
                Button {
                    withAnimation(.easeInOut(duration: 0.12)) {
                        mode = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isSelected ? .black : .snapTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isSelected ? Color.snapAccent : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.snapCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.snapBackground)
    }
}

private struct TimelineModePickerPreview: View {
    @State private var mode: TimelineDisplayMode = .day
    var body: some View {
        ZStack {
            Color.snapBackground.ignoresSafeArea()
            VStack {
                TimelineModePicker(mode: $mode)
                Text("Selected: \(mode.rawValue)")
                    .foregroundColor(.snapTextSecondary)
                Spacer()
            }
        }
    }
}

#Preview {
    TimelineModePickerPreview()
}
