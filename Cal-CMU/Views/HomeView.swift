import SwiftUI

struct HomeView: View {
    @Environment(MealStore.self) private var store
    let onScanTap: () -> Void
    let onQuickAdd: (MealType) -> Void
    let onMealTap: (Meal) -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    StreakBadgeView(streakDays: store.streakDays)
                    calorieCard
                    macroCard
                    quickAddSection
                    todaysMealsSection
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting), \(store.userName)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(dateString)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Profile avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.6), .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Text(String(store.userName.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.top, 16)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Calorie Card

    private var calorieCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Daily Calories")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(store.totalCaloriesToday) / \(store.dailyCalorieGoal)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
            }

            CalorieRingView(
                consumed: store.totalCaloriesToday,
                goal: store.dailyCalorieGoal
            )
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    // MARK: - Macro Card

    private var macroCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Macronutrients")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
            }

            MacroBarView(
                label: "Protein", current: store.totalProteinToday,
                goal: store.dailyProteinGoal, unit: "g", color: .blue
            )
            MacroBarView(
                label: "Carbs", current: store.totalCarbsToday,
                goal: store.dailyCarbsGoal, unit: "g", color: .orange
            )
            MacroBarView(
                label: "Fat", current: store.totalFatToday,
                goal: store.dailyFatGoal, unit: "g", color: .pink
            )
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    // MARK: - Quick Add

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.system(size: 17, weight: .semibold, design: .rounded))

            HStack(spacing: 10) {
                ForEach(MealType.allCases) { type in
                    Button {
                        onQuickAdd(type)
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: type.gradient,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)

                                Image(systemName: type.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                            }

                            Text(type.rawValue)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    // MARK: - Today's Meals

    private var todaysMealsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today's Meals")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Text("\(store.todaysMeals.count) logged")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            if store.todaysMeals.isEmpty {
                emptyMealsView
            } else {
                ForEach(store.todaysMeals) { meal in
                    MealCardView(meal: meal)
                        .onTapGesture { onMealTap(meal) }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
    }

    private var emptyMealsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.macro")
                .font(.system(size: 36))
                .foregroundStyle(.secondary.opacity(0.5))

            Text("No meals logged yet")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            Button {
                onScanTap()
            } label: {
                Text("Scan your first meal")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    HomeView(onScanTap: {}, onQuickAdd: { _ in }, onMealTap: { _ in })
        .environment(MealStore())
}
