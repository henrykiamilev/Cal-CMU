import SwiftUI

struct HomeView: View {
    @Environment(MealStore.self) private var store
    @State private var showCamera = false
    @State private var showMealDetail = false
    @State private var selectedMeal: Meal?
    @State private var capturedImage: UIImage?
    @State private var analyzedMeal: Meal?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        calorieCard
                        macroCard
                        todaysMealsSection
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .background(Color(.systemGroupedBackground))

                // Floating scan button
                floatingScanButton
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    capturedImage = image
                    analyzedMeal = generateMockAnalysis(from: image)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showMealDetail = true
                    }
                }
            }
            .sheet(isPresented: $showMealDetail) {
                if let meal = analyzedMeal {
                    MealDetailView(meal: meal, capturedImage: capturedImage) {
                        var savedMeal = meal
                        if let img = capturedImage {
                            savedMeal = Meal(
                                name: meal.name,
                                calories: meal.calories,
                                protein: meal.protein,
                                carbs: meal.carbs,
                                fat: meal.fat,
                                fiber: meal.fiber,
                                sugar: meal.sugar,
                                sodium: meal.sodium,
                                imageData: img.jpegData(compressionQuality: 0.6)
                            )
                        }
                        store.addMeal(savedMeal)
                    }
                }
            }
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(meal: meal, capturedImage: meal.image) {}
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(dateString)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
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
            CalorieRingView(
                consumed: store.totalCaloriesToday,
                goal: store.dailyCalorieGoal
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
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
                label: "Protein",
                current: store.totalProteinToday,
                goal: store.dailyProteinGoal,
                unit: "g",
                color: .blue
            )

            MacroBarView(
                label: "Carbs",
                current: store.totalCarbsToday,
                goal: store.dailyCarbsGoal,
                unit: "g",
                color: .orange
            )

            MacroBarView(
                label: "Fat",
                current: store.totalFatToday,
                goal: store.dailyFatGoal,
                unit: "g",
                color: .pink
            )
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
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
                        .onTapGesture {
                            selectedMeal = meal
                        }
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

            Text("Tap the button below to scan your first meal")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Floating Scan Button

    private var floatingScanButton: some View {
        Button {
            showCamera = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18, weight: .semibold))
                Text("Scan Meal")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(Color.green.gradient)
            .clipShape(Capsule())
            .shadow(color: .green.opacity(0.4), radius: 16, x: 0, y: 8)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Mock Analysis

    private func generateMockAnalysis(from image: UIImage) -> Meal {
        let mealOptions = [
            ("Grilled Chicken Salad", 420, 35.0, 28.0, 18.0, 6.0, 4.0, 580.0),
            ("Pasta Bolognese", 650, 28.0, 72.0, 24.0, 4.0, 8.0, 890.0),
            ("Avocado Toast", 380, 14.0, 36.0, 22.0, 8.0, 3.0, 440.0),
            ("Salmon Rice Bowl", 520, 32.0, 48.0, 20.0, 3.0, 5.0, 620.0),
            ("Greek Yogurt Parfait", 290, 18.0, 38.0, 8.0, 4.0, 22.0, 95.0),
            ("Steak and Vegetables", 560, 42.0, 18.0, 34.0, 5.0, 4.0, 720.0),
        ]

        let choice = mealOptions.randomElement()!
        return Meal(
            name: choice.0,
            calories: choice.1,
            protein: choice.2,
            carbs: choice.3,
            fat: choice.4,
            fiber: choice.5,
            sugar: choice.6,
            sodium: choice.7,
            imageData: image.jpegData(compressionQuality: 0.6)
        )
    }
}

extension Meal: @retroactive Equatable {
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    HomeView()
        .environment(MealStore())
}
