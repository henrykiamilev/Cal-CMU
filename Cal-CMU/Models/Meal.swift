import Foundation
import SwiftUI

struct Meal: Identifiable {
    let id: UUID
    let name: String
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

    static let sampleMeals: [Meal] = [
        Meal(
            name: "Grilled Chicken Salad",
            timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            calories: 420,
            protein: 35,
            carbs: 28,
            fat: 18,
            fiber: 6,
            sugar: 4,
            sodium: 580
        ),
        Meal(
            name: "Oatmeal with Berries",
            timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(),
            calories: 310,
            protein: 12,
            carbs: 52,
            fat: 8,
            fiber: 7,
            sugar: 14,
            sodium: 120
        ),
        Meal(
            name: "Turkey Wrap",
            timestamp: Calendar.current.date(byAdding: .hour, value: -9, to: Date()) ?? Date(),
            calories: 480,
            protein: 28,
            carbs: 42,
            fat: 20,
            fiber: 3,
            sugar: 6,
            sodium: 720
        ),
    ]
}

@Observable
class MealStore {
    var meals: [Meal] = Meal.sampleMeals
    var dailyCalorieGoal: Int = 2000
    var dailyProteinGoal: Double = 150
    var dailyCarbsGoal: Double = 250
    var dailyFatGoal: Double = 65

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

    func addMeal(_ meal: Meal) {
        withAnimation(.spring(response: 0.4)) {
            meals.insert(meal, at: 0)
        }
    }
}
