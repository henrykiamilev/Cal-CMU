import SwiftUI

enum AppTab: Int, CaseIterable {
    case home = 0
    case log = 1
    case scan = 2
    case insights = 3
    case profile = 4

    var icon: String {
        switch self {
        case .home: return "house"
        case .log: return "list.clipboard"
        case .scan: return "camera"
        case .insights: return "chart.bar"
        case .profile: return "person"
        }
    }

    var filledIcon: String {
        switch self {
        case .home: return "house.fill"
        case .log: return "list.clipboard.fill"
        case .scan: return "camera.fill"
        case .insights: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .home: return "Home"
        case .log: return "Log"
        case .scan: return "Scan"
        case .insights: return "Insights"
        case .profile: return "Profile"
        }
    }
}

struct MainTabView: View {
    @Environment(MealStore.self) private var store
    @State private var selectedTab: AppTab = .home
    @State private var showCamera = false
    @State private var showMealDetail = false
    @State private var capturedImage: UIImage?
    @State private var analyzedMeal: Meal?
    @State private var selectedMealType: MealType = .lunch

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        onScanTap: { openCamera(type: .lunch) },
                        onQuickAdd: { type in openCamera(type: type) },
                        onMealTap: { meal in
                            analyzedMeal = meal
                            capturedImage = meal.image
                            showMealDetail = true
                        }
                    )
                case .log:
                    LogView(onAddMeal: { type in openCamera(type: type) },
                            onMealTap: { meal in
                                analyzedMeal = meal
                                capturedImage = meal.image
                                showMealDetail = true
                            })
                case .scan:
                    Color.clear
                case .insights:
                    InsightsView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showCamera) {
            CameraView(mealType: selectedMealType) { image in
                capturedImage = image
                analyzedMeal = store.generateMockAnalysis(from: image, mealType: selectedMealType)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showMealDetail = true
                }
            }
        }
        .sheet(isPresented: $showMealDetail) {
            if let meal = analyzedMeal {
                MealDetailView(meal: meal, capturedImage: capturedImage) {
                    var savedMeal = meal
                    if let img = capturedImage, meal.imageData == nil {
                        savedMeal = Meal(
                            name: meal.name,
                            mealType: meal.mealType,
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
    }

    private func openCamera(type: MealType) {
        selectedMealType = type
        showCamera = true
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                if tab == .scan {
                    // Center camera button
                    scanButton
                } else {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -8)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var scanButton: some View {
        Button {
            openCamera(type: .lunch)
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.65, blue: 0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: .green.opacity(0.4), radius: 12, x: 0, y: 6)

                Image(systemName: "camera.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .offset(y: -18)
        .frame(maxWidth: .infinity)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.filledIcon : tab.icon)
                    .font(.system(size: 20))
                    .symbolEffect(.bounce, value: selectedTab == tab)

                Text(tab.label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundStyle(selectedTab == tab ? .green : .secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
        .environment(MealStore())
}
