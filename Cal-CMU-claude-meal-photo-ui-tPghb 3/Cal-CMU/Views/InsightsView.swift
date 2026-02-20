import SwiftUI

struct InsightsView: View {
    @Environment(MealStore.self) private var store
    @State private var animateScore = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Weekly chart
                    WeeklyChartView(
                        data: store.weeklyCalories,
                        goal: store.dailyCalorieGoal
                    )

                    // Average stats
                    averageStatsCard

                    // Macro split
                    macroSplitCard

                    // Top nutrients
                    topNutrientsCard

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Average Stats

    private var averageStatsCard: some View {
        HStack(spacing: 0) {
            statBubble(
                value: "\(store.averageWeeklyCalories)",
                label: "Avg Cal/Day",
                icon: "flame.fill",
                color: .orange
            )
            statBubble(
                value: "\(store.todaysMeals.count)",
                label: "Meals Today",
                icon: "fork.knife",
                color: .green
            )
            statBubble(
                value: "\(store.streakDays)",
                label: "Day Streak",
                icon: "flame.fill",
                color: .red
            )
        }
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private func statBubble(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Macro Split

    private var macroSplitCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macro Split")
                .font(.system(size: 17, weight: .semibold, design: .rounded))

            HStack(spacing: 16) {
                // Donut chart
                ZStack {
                    let p = store.macroPercentages

                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 16)
                        .frame(width: 100, height: 100)

                    // Protein arc
                    Circle()
                        .trim(from: 0, to: animateScore ? p.protein / 100 : 0)
                        .stroke(Color.blue.gradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    // Carbs arc
                    Circle()
                        .trim(from: 0, to: animateScore ? p.carbs / 100 : 0)
                        .stroke(Color.orange.gradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90 + 360 * p.protein / 100))

                    // Fat arc
                    Circle()
                        .trim(from: 0, to: animateScore ? p.fat / 100 : 0)
                        .stroke(Color.pink.gradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90 + 360 * (p.protein + p.carbs) / 100))

                    VStack(spacing: 0) {
                        Text("\(store.totalCaloriesToday)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("cal")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animateScore)

                // Legend
                VStack(alignment: .leading, spacing: 12) {
                    macroLegend("Protein", pct: store.macroPercentages.protein, grams: store.totalProteinToday, color: .blue)
                    macroLegend("Carbs", pct: store.macroPercentages.carbs, grams: store.totalCarbsToday, color: .orange)
                    macroLegend("Fat", pct: store.macroPercentages.fat, grams: store.totalFatToday, color: .pink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .onAppear { animateScore = true }
    }

    private func macroLegend(_ name: String, pct: Double, grams: Double, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color.gradient)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Text("\(Int(grams))g (\(Int(pct))%)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Top Nutrients

    private var topNutrientsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Breakdown")
                .font(.system(size: 17, weight: .semibold, design: .rounded))

            nutrientDetailRow("Calories", value: "\(store.totalCaloriesToday)", unit: "cal", icon: "flame.fill", color: .orange)
            nutrientDetailRow("Protein", value: "\(Int(store.totalProteinToday))", unit: "g", icon: "circle.hexagongrid.fill", color: .blue)
            nutrientDetailRow("Carbs", value: "\(Int(store.totalCarbsToday))", unit: "g", icon: "bolt.fill", color: .orange)
            nutrientDetailRow("Fat", value: "\(Int(store.totalFatToday))", unit: "g", icon: "drop.triangle.fill", color: .pink)
            nutrientDetailRow("Vitamin C", value: "\(Int(store.totalVitaminCToday))", unit: "mg", icon: "pills.fill", color: .yellow)
            nutrientDetailRow("Iron", value: String(format: "%.1f", store.totalIronToday), unit: "mg", icon: "cross.vial.fill", color: .red)
            nutrientDetailRow("Calcium", value: "\(Int(store.totalCalciumToday))", unit: "mg", icon: "bone.fill", color: .gray)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private func nutrientDetailRow(_ name: String, value: String, unit: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(name)
                .font(.system(size: 14, weight: .medium, design: .rounded))

            Spacer()

            Text("\(value) \(unit)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    InsightsView()
        .environment(MealStore())
}
