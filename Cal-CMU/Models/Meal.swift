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

// MARK: - Scan Source

enum ScanSource: String, Codable {
    case receipt = "Receipt"
    case screenshot = "Screenshot"
    case photo = "Photo"

    var icon: String {
        switch self {
        case .receipt: return "doc.text.viewfinder"
        case .screenshot: return "rectangle.on.rectangle"
        case .photo: return "camera.fill"
        }
    }

    var label: String {
        switch self {
        case .receipt: return "Receipt Scan"
        case .screenshot: return "Screenshot"
        case .photo: return "Food Photo"
        }
    }

    var color: Color {
        switch self {
        case .receipt: return .blue
        case .screenshot: return .purple
        case .photo: return .green
        }
    }
}

// MARK: - Meal

struct Meal: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let mealType: MealType
    let scanSource: ScanSource
    let timestamp: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    // Vitamins
    let vitaminC: Double
    let vitaminB6: Double
    let vitaminB12: Double
    let vitaminD: Double
    let vitaminA: Double
    // Minerals
    let potassium: Double
    let iron: Double
    let calcium: Double
    let magnesium: Double
    let zinc: Double
    // Receipt data
    let receiptItems: [String]
    let restaurantName: String?
    var imageData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        mealType: MealType = .lunch,
        scanSource: ScanSource = .photo,
        timestamp: Date = Date(),
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0,
        sugar: Double = 0,
        sodium: Double = 0,
        vitaminC: Double = 0,
        vitaminB6: Double = 0,
        vitaminB12: Double = 0,
        vitaminD: Double = 0,
        vitaminA: Double = 0,
        potassium: Double = 0,
        iron: Double = 0,
        calcium: Double = 0,
        magnesium: Double = 0,
        zinc: Double = 0,
        receiptItems: [String] = [],
        restaurantName: String? = nil,
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.scanSource = scanSource
        self.timestamp = timestamp
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.vitaminC = vitaminC
        self.vitaminB6 = vitaminB6
        self.vitaminB12 = vitaminB12
        self.vitaminD = vitaminD
        self.vitaminA = vitaminA
        self.potassium = potassium
        self.iron = iron
        self.calcium = calcium
        self.magnesium = magnesium
        self.zinc = zinc
        self.receiptItems = receiptItems
        self.restaurantName = restaurantName
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
            scanSource: .receipt,
            timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            calories: 420, protein: 35, carbs: 28, fat: 18,
            fiber: 6, sugar: 4, sodium: 580,
            vitaminC: 28, vitaminB6: 0.6, vitaminB12: 0.3, vitaminD: 1.2, vitaminA: 180,
            potassium: 520, iron: 2.8, calcium: 85, magnesium: 42, zinc: 3.1,
            receiptItems: ["Grilled Chicken Breast", "Mixed Greens", "Cherry Tomatoes", "Balsamic Vinaigrette"],
            restaurantName: "Sweetgreen"
        ),
        Meal(
            name: "Oatmeal with Berries",
            mealType: .breakfast,
            scanSource: .photo,
            timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(),
            calories: 310, protein: 12, carbs: 52, fat: 8,
            fiber: 7, sugar: 14, sodium: 120,
            vitaminC: 15, vitaminB6: 0.2, vitaminB12: 0.0, vitaminD: 0.5, vitaminA: 45,
            potassium: 280, iron: 3.4, calcium: 110, magnesium: 56, zinc: 1.8
        ),
        Meal(
            name: "Turkey Club Combo",
            mealType: .dinner,
            scanSource: .receipt,
            timestamp: Calendar.current.date(byAdding: .hour, value: -9, to: Date()) ?? Date(),
            calories: 480, protein: 28, carbs: 42, fat: 20,
            fiber: 3, sugar: 6, sodium: 720,
            vitaminC: 12, vitaminB6: 0.5, vitaminB12: 1.2, vitaminD: 0.8, vitaminA: 95,
            potassium: 340, iron: 2.1, calcium: 65, magnesium: 32, zinc: 2.8,
            receiptItems: ["Turkey Club Sandwich", "Side Salad", "Iced Tea"],
            restaurantName: "Panera Bread"
        ),
        Meal(
            name: "Mixed Nuts",
            mealType: .snack,
            scanSource: .screenshot,
            timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            calories: 170, protein: 5, carbs: 8, fat: 14,
            fiber: 2, sugar: 1, sodium: 95,
            vitaminC: 0.5, vitaminB6: 0.1, vitaminB12: 0.0, vitaminD: 0.0, vitaminA: 2,
            potassium: 210, iron: 1.6, calcium: 38, magnesium: 68, zinc: 1.5,
            receiptItems: ["Trail Mix - Large"]
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

    // Vitamin & Mineral Totals
    var totalVitaminCToday: Double { todaysMeals.reduce(0) { $0 + $1.vitaminC } }
    var totalVitaminB6Today: Double { todaysMeals.reduce(0) { $0 + $1.vitaminB6 } }
    var totalVitaminB12Today: Double { todaysMeals.reduce(0) { $0 + $1.vitaminB12 } }
    var totalVitaminDToday: Double { todaysMeals.reduce(0) { $0 + $1.vitaminD } }
    var totalVitaminAToday: Double { todaysMeals.reduce(0) { $0 + $1.vitaminA } }
    var totalPotassiumToday: Double { todaysMeals.reduce(0) { $0 + $1.potassium } }
    var totalIronToday: Double { todaysMeals.reduce(0) { $0 + $1.iron } }
    var totalCalciumToday: Double { todaysMeals.reduce(0) { $0 + $1.calcium } }
    var totalMagnesiumToday: Double { todaysMeals.reduce(0) { $0 + $1.magnesium } }
    var totalZincToday: Double { todaysMeals.reduce(0) { $0 + $1.zinc } }

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
        let carbRatio = totalCarbsToday / dailyCarbsGoal
        if carbRatio > 0.7 && carbRatio < 1.2 { score += 10 }
        let fatRatio = totalFatToday / dailyFatGoal
        if fatRatio > 0.5 && fatRatio < 1.2 { score += 5 }
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

    // MARK: - Mock Analysis

    func generateMockAnalysis(from image: UIImage, mealType: MealType, scanSource: ScanSource) -> Meal {
        if scanSource == .receipt || scanSource == .screenshot {
            return generateReceiptAnalysis(from: image, mealType: mealType, scanSource: scanSource)
        } else {
            return generatePhotoAnalysis(from: image, mealType: mealType)
        }
    }

    private func generateReceiptAnalysis(from image: UIImage, mealType: MealType, scanSource: ScanSource) -> Meal {
        let options: [(name: String, restaurant: String, items: [String], cal: Int, protein: Double, carbs: Double, fat: Double, fiber: Double, sugar: Double, sodium: Double, vitC: Double, b6: Double, b12: Double, vitD: Double, vitA: Double, potassium: Double, iron: Double, calcium: Double, magnesium: Double, zinc: Double)] = [
            ("Chipotle Burrito Bowl", "Chipotle", ["Chicken", "White Rice", "Black Beans", "Fajita Veggies", "Tomato Salsa", "Cheese", "Lettuce"], 740, 45, 68, 28, 12, 4, 1680, 18, 0.6, 0.4, 0.0, 165, 620, 4.5, 280, 78, 4.2),
            ("Big Mac Combo", "McDonald's", ["Big Mac", "Medium Fries", "Medium Coke"], 1080, 28, 138, 48, 6, 52, 1340, 4, 0.3, 2.4, 0.0, 45, 680, 4.8, 220, 42, 3.8),
            ("Spicy Chicken Sandwich", "Chick-fil-A", ["Spicy Chicken Sandwich", "Waffle Fries", "Lemonade"], 920, 34, 108, 38, 4, 42, 1820, 12, 0.4, 0.2, 0.0, 28, 520, 2.8, 65, 36, 2.1),
            ("Poke Bowl - Regular", "Pokeworks", ["Salmon", "Tuna", "Sushi Rice", "Edamame", "Seaweed Salad", "Sriracha Aioli"], 620, 38, 58, 22, 5, 8, 890, 8, 0.9, 5.2, 8.5, 310, 580, 2.2, 48, 62, 1.8),
            ("Veggie Delight Sub", "Subway", ["6-inch Wheat Bread", "Lettuce", "Tomato", "Cucumber", "Green Peppers", "Onions", "Provolone"], 340, 16, 42, 12, 6, 5, 680, 22, 0.2, 0.6, 0.0, 95, 260, 2.8, 180, 32, 1.6),
            ("Acai Supergreens Bowl", "Jamba Juice", ["Acai", "Banana", "Blueberries", "Granola", "Honey", "Chia Seeds"], 470, 10, 82, 14, 11, 38, 45, 42, 0.4, 0.0, 0.0, 65, 420, 2.4, 120, 48, 1.2),
        ]

        let c = options.randomElement()!
        return Meal(
            name: c.name, mealType: mealType, scanSource: scanSource,
            calories: c.cal, protein: c.protein, carbs: c.carbs, fat: c.fat,
            fiber: c.fiber, sugar: c.sugar, sodium: c.sodium,
            vitaminC: c.vitC, vitaminB6: c.b6, vitaminB12: c.b12,
            vitaminD: c.vitD, vitaminA: c.vitA,
            potassium: c.potassium, iron: c.iron, calcium: c.calcium,
            magnesium: c.magnesium, zinc: c.zinc,
            receiptItems: c.items, restaurantName: c.restaurant,
            imageData: image.jpegData(compressionQuality: 0.6)
        )
    }

    private func generatePhotoAnalysis(from image: UIImage, mealType: MealType) -> Meal {
        let options: [(String, Int, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double)] = [
            ("Grilled Chicken Salad", 420, 35, 28, 18, 6, 4, 580, 28, 0.6, 0.3, 1.2, 180, 520, 2.8, 85, 42, 3.1),
            ("Pasta Bolognese", 650, 28, 72, 24, 4, 8, 890, 10, 0.4, 1.8, 0.3, 120, 610, 4.2, 52, 38, 4.5),
            ("Avocado Toast", 380, 14, 36, 22, 8, 3, 440, 12, 0.3, 0.0, 0.0, 45, 480, 1.8, 28, 58, 1.2),
            ("Salmon Rice Bowl", 520, 32, 48, 20, 3, 5, 620, 6, 0.8, 4.9, 14.2, 280, 690, 1.2, 22, 52, 1.0),
            ("Greek Yogurt Parfait", 290, 18, 38, 8, 4, 22, 95, 18, 0.2, 1.1, 0.0, 35, 380, 0.6, 220, 28, 1.4),
            ("Steak and Vegetables", 560, 42, 18, 34, 5, 4, 720, 22, 0.7, 2.8, 0.5, 65, 580, 3.8, 32, 45, 6.2),
            ("Acai Bowl", 340, 8, 52, 12, 9, 28, 45, 32, 0.3, 0.0, 0.0, 55, 310, 1.4, 48, 34, 0.8),
            ("Caesar Wrap", 460, 24, 38, 22, 3, 4, 820, 14, 0.4, 0.5, 0.2, 110, 290, 2.2, 95, 26, 2.4),
        ]

        let c = options.randomElement()!
        return Meal(
            name: c.0, mealType: mealType, scanSource: .photo,
            calories: c.1, protein: c.2, carbs: c.3, fat: c.4,
            fiber: c.5, sugar: c.6, sodium: c.7,
            vitaminC: c.8, vitaminB6: c.9, vitaminB12: c.10,
            vitaminD: c.11, vitaminA: c.12,
            potassium: c.13, iron: c.14, calcium: c.15,
            magnesium: c.16, zinc: c.17,
            imageData: image.jpegData(compressionQuality: 0.6)
        )
    }
}
