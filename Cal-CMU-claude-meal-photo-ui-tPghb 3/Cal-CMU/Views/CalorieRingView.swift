import SwiftUI

struct CalorieRingView: View {
    let consumed: Int
    let goal: Int

    @State private var animatedProgress: Double = 0

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(consumed) / Double(goal), 1.0)
    }

    private var remaining: Int {
        max(goal - consumed, 0)
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 20)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.7),
                            Color.green,
                            Color.green.opacity(0.9)
                        ]),
                        center: .center,
                        startAngle: .degrees(-10),
                        endAngle: .degrees(350)
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)

            // Center text
            VStack(spacing: 4) {
                Text("\(consumed)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text("of \(goal) cal")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Text("\(remaining) left")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: consumed) { _, _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    CalorieRingView(consumed: 1210, goal: 2000)
        .padding()
}
