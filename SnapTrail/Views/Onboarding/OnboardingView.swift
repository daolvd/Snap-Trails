import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.snapBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                Text("SnapTrail")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(Color.snapAccent)
                    .padding(.top, 60)

                // Hero card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.snapCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )

                    VStack(spacing: 0) {
                        // Preview image placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.snapCardLight)

                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 64))
                                .foregroundColor(Color.snapAccent.opacity(0.4))

                            // Viewfinder overlay
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.snapAccent.opacity(0.5), lineWidth: 1)
                                .frame(width: 140, height: 140)
                        }
                        .frame(height: 260)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Feature badges
                        VStack(alignment: .leading, spacing: 10) {
                            featureBadge(icon: "location.fill", text: "LOCATION LINKED")
                            featureBadge(icon: "iphone", text: "DEVICE ONLY")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)

                        Spacer(minLength: 0)
                    }

                    // Corner icons
                    VStack {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundColor(Color.snapAccent)
                                .frame(width: 40, height: 40)
                                .background(Color.snapCardLight)
                                .clipShape(Circle())

                            Spacer()

                            Image(systemName: "mappin.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color.snapAccent)
                                .frame(width: 40, height: 40)
                                .background(Color.snapCardLight)
                                .clipShape(Circle())
                        }
                        .padding(20)

                        Spacer()
                    }
                }
                .frame(height: 400)
                .padding(.horizontal, 32)
                .padding(.top, 24)

                // Description
                VStack(spacing: 12) {
                    Text("Capture your reality.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.snapTextPrimary)

                    Text("Photos tied to coordinates. Stored completely offline in your private local storage. No cloud tracking.")
                        .font(.subheadline)
                        .foregroundColor(.snapTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 28)

                Spacer()

                // Continue button
                PrimaryButton(title: "Continue", systemImage: "arrow.right") {
                    onContinue()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }

    private func featureBadge(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color.snapAccent)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.snapTextPrimary)
                .tracking(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.snapCardLight)
        .clipShape(Capsule())
    }
}

#Preview {
    OnboardingView {
        print("Continue tapped")
    }
}
