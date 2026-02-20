import SwiftUI

struct StreakBadgeView: View {
    let streakDays: Int
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            // Fire icon with glow
            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.orange.opacity(0.3))
                    .blur(radius: 8)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakDays) Day Streak")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Keep it going!")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Streak dots
            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { day in
                    Circle()
                        .fill(day < streakDays % 7 || streakDays >= 7
                              ? AnyShapeStyle(Color.orange.gradient)
                              : AnyShapeStyle(Color(.systemGray5)))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.08), Color.red.opacity(0.04)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
        )
        .onAppear { isAnimating = true }
    }
}

#Preview {
    StreakBadgeView(streakDays: 7)
        .padding()
}
