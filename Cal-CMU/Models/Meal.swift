import Foundation
import SwiftUI

// MARK: - Meal Type

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .indigo
        case .snack: return .mint
        }
    }

    var gradient: [Color] {
        switch self {
        case .breakfast: return [.orange, .yellow]
        case .lunch: return [.yellow, .orange]
        case .dinner: return [.indigo, .purple]
        case .snack: return [.mint, .green]
        }
    }
}

// MARK: - Meal

struct Meal: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let mealType: MealType
    let timestamp: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    var imageData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        mealType: MealType = .lunch,
        timestamp: Date = Date(),
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0,
        sugar: Double = 0,
        sodium: Double = 0,
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.timestamp = timestamp
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.imageData = imageData
    }

    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    static func == (lhs: Meal, rhs: Meal) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static let sampleMeals: [Meal] = [
        Meal(
            name: "Grilled Chicken Salad",
            mealType: .lunch,
            timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            calories: 420, protein: 35, carbs: 28, fat: 18,
            fiber: 6, sugar: 4, sodium: 580
        ),
        Meal(
            name: "Oatmeal with Berries",
            mealType: .breakfast,
            timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(),
            calories: 310, protein: 12, carbs: 52, fat: 8,
            fiber: 7, sugar: 14, sodium: 120
        ),
        Meal(
            name: "Turkey Wrap",
            mealType: .dinner,
            timestamp: Calendar.current.date(byAdding: .hour, value: -9, to: Date()) ?? Date(),
            calories: 480, protein: 28, carbs: 42, fat: 20,
            fiber: 3, sugar: 6, sodium: 720
        ),
        Meal(
            name: "Mixed Nuts",
            mealType: .snack,
            timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            calories: 170, protein: 5, carbs: 8, fat: 14,
            fiber: 2, sugar: 1, sodium: 95
        ),
    ]
}

// MARK: - MealStore

@Observable
class MealStore {
    var meals: [Meal] = Meal.sampleMeals

    // Daily Goals
    var dailyCalorieGoal: Int = 2000
    var dailyProteinGoal: Double = 150
    var dailyCarbsGoal: Double = 250
    var dailyFatGoal: Double = 65

    // Water Tracking
    var waterIntake: Int = 5
    var waterGoal: Int = 8

    // Streak
    var streakDays: Int = 7

    // Profile
    var userName: String = "Henry"
    var userAge: Int = 22
    var userWeight: Double = 165
    var userHeight: Double = 72
    var showNotifications: Bool = true
    var useDarkMode: Bool = false

    // MARK: - Today's Data

    var todaysMeals: [Meal] {
        meals.filter { Calendar.current.isDateInToday($0.timestamp) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var totalCaloriesToday: Int {
        todaysMeals.reduce(0) { $0 + $1.calories }
    }

    var totalProteinToday: Double {
        todaysMeals.reduce(0) { $0 + $1.protein }
    }

    var totalCarbsToday: Double {
        todaysMeals.reduce(0) { $0 + $1.carbs }
    }

    var totalFatToday: Double {
        todaysMeals.reduce(0) { $0 + $1.fat }
    }

    func mealsForType(_ type: MealType) -> [Meal] {
        todaysMeals.filter { $0.mealType == type }
    }

    func caloriesForType(_ type: MealType) -> Int {
        mealsForType(type).reduce(0) { $0 + $1.calories }
    }

    // MARK: - Weekly Data

    var weeklyCalories: [(day: String, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
        let todayWeekday = (calendar.component(.weekday, from: today) + 5) % 7

        return (0..<7).map { offset in
            let dayIndex = offset
            if dayIndex < todayWeekday {
                let fakeCals = [1650, 1820, 2100, 1950, 1780, 2200, 1400]
                return (dayLabels[dayIndex], fakeCals[dayIndex])
            } else if dayIndex == todayWeekday {
                return (dayLabels[dayIndex], totalCaloriesToday)
            } else {
                return (dayLabels[dayIndex], 0)
            }
        }
    }

    var averageWeeklyCalories: Int {
        let nonZero = weeklyCalories.filter { $0.calories > 0 }
        guard !nonZero.isEmpty else { return 0 }
        return nonZero.reduce(0) { $0 + $1.calories } / nonZero.count
    }

    // MARK: - Macro Percentages

    var macroPercentages: (protein: Double, carbs: Double, fat: Double) {
        let totalP = totalProteinToday * 4
        let totalC = totalCarbsToday * 4
        let totalF = totalFatToday * 9
        let total = totalP + totalC + totalF
        guard total > 0 else { return (33, 34, 33) }
        return (
            protein: (totalP / total) * 100,
            carbs: (totalC / total) * 100,
            fat: (totalF / total) * 100
        )
    }

    var nutritionScore: Int {
        var score = 50
        let calRatio = Double(totalCaloriesToday) / Double(dailyCalorieGoal)
        if calRatio > 0.7 && calRatio < 1.1 { score += 20 }
        else if calRatio > 0.5 { score += 10 }
        let protRatio = totalProteinToday / dailyProteinGoal
        if protRatio > 0.7 { score += 15 }
        let waterRatio = Double(waterIntake) / Double(waterGoal)
        if waterRatio >= 1.0 { score += 15 }
        else if waterRatio > 0.5 { score += 8 }
        return min(score, 100)
    }

    // MARK: - Actions

    func addMeal(_ meal: Meal) {
        withAnimation(.spring(response: 0.4)) {
            meals.insert(meal, at: 0)
        }
    }

    func deleteMeal(_ meal: Meal) {
        withAnimation(.spring(response: 0.3)) {
            meals.removeAll { $0.id == meal.id }
        }
    }

    func addWater() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if waterIntake < waterGoal + 4 {
                waterIntake += 1
            }
        }
    }

    func removeWater() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if waterIntake > 0 {
                waterIntake -= 1
            }
        }
    }

    // MARK: - Mock Analysis

    func generateMockAnalysis(from image: UIImage, mealType: MealType) -> Meal {
        let options: [(String, Int, Double, Double, Double, Double, Double, Double)] = [
            ("Grilled Chicken Salad", 420, 35, 28, 18, 6, 4, 580),
            ("Pasta Bolognese", 650, 28, 72, 24, 4, 8, 890),
            ("Avocado Toast", 380, 14, 36, 22, 8, 3, 440),
            ("Salmon Rice Bowl", 520, 32, 48, 20, 3, 5, 620),
            ("Greek Yogurt Parfait", 290, 18, 38, 8, 4, 22, 95),
            ("Steak and Vegetables", 560, 42, 18, 34, 5, 4, 720),
            ("Acai Bowl", 340, 8, 52, 12, 9, 28, 45),
            ("Caesar Wrap", 460, 24, 38, 22, 3, 4, 820),
        ]

        let choice = options.randomElement()!
        return Meal(
            name: choice.0,
            mealType: mealType,
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
