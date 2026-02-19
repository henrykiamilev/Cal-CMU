import SwiftUI

@main
struct Cal_CMUApp: App {
    @State private var mealStore = MealStore()
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    splashView
                } else if authManager.isAuthenticated {
                    MainTabView()
                        .environment(mealStore)
                        .environment(authManager)
                        .preferredColorScheme(mealStore.useDarkMode ? .dark : .light)
                } else {
                    LoginView()
                        .environment(authManager)
                }
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuth in
                if isAuth && !authManager.userEmail.isEmpty {
                    let emailPrefix = authManager.userEmail.components(separatedBy: "@").first ?? ""
                    if !emailPrefix.isEmpty {
                        mealStore.userName = emailPrefix
                    }
                }
            }
        }
    }

    private var splashView: some View {
        ZStack {
            Color(red: 0.03, green: 0.08, blue: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.65, blue: 0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(color: .green.opacity(0.4), radius: 16, x: 0, y: 8)

                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(.white)
                }

                Text("Cal-CMU")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                ProgressView()
                    .tint(.green)
                    .scaleEffect(1.2)
            }
        }
    }
}
