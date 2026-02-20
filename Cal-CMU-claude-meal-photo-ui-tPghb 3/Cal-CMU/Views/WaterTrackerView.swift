import SwiftUI

struct WaterTrackerView: View {
    @Environment(MealStore.self) private var store

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
                    .font(.system(size: 16))
                Text("Water Intake")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(store.waterIntake) / \(store.waterGoal)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
            }

            // Water glasses
            HStack(spacing: 6) {
                ForEach(0..<store.waterGoal, id: \.self) { index in
                    WaterGlass(filled: index < store.waterIntake)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                if index < store.waterIntake {
                                    store.waterIntake = index
                                } else {
                                    store.waterIntake = index + 1
                                }
                            }
                            Task { await store.saveWaterLogManually() }
                        }
                }

                Spacer()

                // Plus / Minus buttons
                HStack(spacing: 8) {
                    Button {
                        store.removeWater()
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }

                    Button {
                        store.addWater()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.cyan.gradient)
                            .clipShape(Circle())
                    }
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.cyan.opacity(0.12))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.cyan.gradient)
                        .frame(
                            width: geo.size.width * min(Double(store.waterIntake) / Double(store.waterGoal), 1.0),
                            height: 6
                        )
                        .animation(.spring(response: 0.4), value: store.waterIntake)
                }
            }
            .frame(height: 6)
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct WaterGlass: View {
    let filled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(filled ? Color.cyan.opacity(0.2) : Color(.systemGray6))
                .frame(width: 26, height: 32)

            Image(systemName: filled ? "drop.fill" : "drop")
                .font(.system(size: 12))
                .foregroundStyle(filled ? .cyan : Color(.systemGray4))
        }
        .scaleEffect(filled ? 1.0 : 0.9)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: filled)
    }
}

#Preview {
    WaterTrackerView()
        .padding()
        .background(Color(.systemGroupedBackground))
        .environment(MealStore())
}
