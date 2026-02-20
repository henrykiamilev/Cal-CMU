import SwiftUI

@main
struct Cal_CMUApp: App {
    @State private var mealStore = MealStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(mealStore)
                .preferredColorScheme(mealStore.useDarkMode ? .dark : .light)
        }
    }
}
