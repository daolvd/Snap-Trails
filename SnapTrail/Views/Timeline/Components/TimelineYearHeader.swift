import SwiftUI

struct TimelineYearHeader: View {
    let group: TimelineYearGroup

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: String(group.year))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.snapTextPrimary)
            Spacer()
            Text("\(group.memoryCount) memories")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.snapTextSecondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Color.snapBackground
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                }
        )
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        VStack {
            TimelineYearHeader(group: TimelinePreviewData.yearGroup)
            Spacer()
        }
    }
}
