import SwiftUI

struct GoalSettingView: View {
    @Environment(MealStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var calories: Double = 2000
    @State private var protein: Double = 150
    @State private var carbs: Double = 250
    @State private var fat: Double = 65
    @State private var water: Double = 8
    @State private var hasInitialized = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Calories
                    goalSlider(
                        title: "Daily Calories",
                        icon: "flame.fill",
                        color: .orange,
                        value: $calories,
                        range: 1200...4000,
                        step: 50,
                        unit: "cal"
                    )

                    // Protein
                    goalSlider(
                        title: "Protein",
                        icon: "circle.hexagongrid.fill",
                        color: .blue,
                        value: $protein,
                        range: 50...300,
                        step: 5,
                        unit: "g"
                    )

                    // Carbs
                    goalSlider(
                        title: "Carbohydrates",
                        icon: "bolt.fill",
                        color: .orange,
                        value: $carbs,
                        range: 100...500,
                        step: 10,
                        unit: "g"
                    )

                    // Fat
                    goalSlider(
                        title: "Fat",
                        icon: "drop.triangle.fill",
                        color: .pink,
                        value: $fat,
                        range: 30...150,
                        step: 5,
                        unit: "g"
                    )

                    // Water
                    goalSlider(
                        title: "Water",
                        icon: "drop.fill",
                        color: .cyan,
                        value: $water,
                        range: 4...16,
                        step: 1,
                        unit: "glasses"
                    )

                    // Calorie breakdown info
                    calorieBreakdown
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoals()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                }
            }
            .onAppear {
                if !hasInitialized {
                    calories = Double(store.dailyCalorieGoal)
                    protein = store.dailyProteinGoal
                    carbs = store.dailyCarbsGoal
                    fat = store.dailyFatGoal
                    water = Double(store.waterGoal)
                    hasInitialized = true
                }
            }
        }
    }

    private func goalSlider(
        title: String, icon: String, color: Color,
        value: Binding<Double>, range: ClosedRange<Double>,
        step: Double, unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                Text("\(Int(value.wrappedValue)) \(unit)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }

            Slider(value: value, in: range, step: step)
                .tint(color)

            HStack {
                Text("\(Int(range.lowerBound))")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("\(Int(range.upperBound))")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private var calorieBreakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calorie Breakdown")
                .font(.system(size: 15, weight: .semibold, design: .rounded))

            let proteinCals = protein * 4
            let carbsCals = carbs * 4
            let fatCals = fat * 9
            let total = proteinCals + carbsCals + fatCals

            HStack(spacing: 16) {
                breakdownItem("Protein", cals: Int(proteinCals), pct: total > 0 ? proteinCals / total * 100 : 0, color: .blue)
                breakdownItem("Carbs", cals: Int(carbsCals), pct: total > 0 ? carbsCals / total * 100 : 0, color: .orange)
                breakdownItem("Fat", cals: Int(fatCals), pct: total > 0 ? fatCals / total * 100 : 0, color: .pink)
            }

            if abs(total - calories) > 100 {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.yellow)
                    Text("Macro total (\(Int(total)) cal) differs from calorie goal (\(Int(calories)) cal)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func breakdownItem(_ label: String, cals: Int, pct: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(pct))%")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Text("\(cals) cal")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func saveGoals() {
        store.dailyCalorieGoal = Int(calories)
        store.dailyProteinGoal = protein
        store.dailyCarbsGoal = carbs
        store.dailyFatGoal = fat
        store.waterGoal = Int(water)
    }
}

#Preview {
    GoalSettingView()
        .environment(MealStore())
}
