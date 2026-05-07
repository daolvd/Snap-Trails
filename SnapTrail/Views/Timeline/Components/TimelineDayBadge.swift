import SwiftUI

struct TimelineDayBadge: View {
    let date: Date
    @ScaledMetric(relativeTo: .title) private var size: CGFloat = 52

    var body: some View {
        let day = Calendar.current.component(.day, from: date)
        Text("\(day)")
            .font(.system(size: 26, weight: .heavy, design: .rounded))
            .foregroundColor(.snapAccent)
            .monospacedDigit()
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.snapCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.snapAccent, lineWidth: 0.5)
            )
            .shadow(color: Color.snapAccent.opacity(0.55), radius: 2)
            .shadow(color: Color.snapAccent.opacity(0.35), radius: 8)
    }
}

#Preview {
    ZStack {
        Color.snapBackground.ignoresSafeArea()
        HStack(spacing: 20) {
            TimelineDayBadge(date: Date())
            TimelineDayBadge(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            TimelineDayBadge(date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!)
        }
    }
}
