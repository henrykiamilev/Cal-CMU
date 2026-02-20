import SwiftUI

struct MacroBarView: View {
    let label: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color

    @State private var animatedProgress: Double = 0

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(current))\(unit)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                +
                Text(" / \(Int(goal))\(unit)")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.tertiary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    Capsule()
                        .fill(color.gradient)
                        .frame(width: geo.size.width * animatedProgress, height: 8)
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: current) { _, _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MacroBarView(label: "Protein", current: 75, goal: 150, unit: "g", color: .blue)
        MacroBarView(label: "Carbs", current: 122, goal: 250, unit: "g", color: .orange)
        MacroBarView(label: "Fat", current: 46, goal: 65, unit: "g", color: .pink)
    }
    .padding()
}
