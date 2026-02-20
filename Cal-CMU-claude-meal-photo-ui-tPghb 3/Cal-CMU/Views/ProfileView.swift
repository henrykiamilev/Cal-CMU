import SwiftUI

struct ProfileView: View {
    @Environment(MealStore.self) private var store
    @State private var showGoalEditor = false
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeader
                    dailyGoalsCard
                    personalInfoCard
                    settingsCard
                    aboutButton
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showGoalEditor) {
                GoalSettingView()
            }
            .alert("Cal-CMU", isPresented: $showAbout) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Version 1.0\nYour AI-powered meal tracking companion.\nBuilt with SwiftUI.")
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.5), .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)

                Text(String(store.userName.prefix(1)).uppercased())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text(store.userName)
                .font(.system(size: 22, weight: .bold, design: .rounded))

            // Stats row
            HStack(spacing: 24) {
                statItem(value: "\(store.streakDays)", label: "Day Streak")
                statDivider
                statItem(value: "\(store.meals.count)", label: "Total Meals")
                statDivider
                statItem(value: "\(store.nutritionScore)", label: "Score")
            }
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color(.systemGray4))
            .frame(width: 1, height: 32)
    }

    // MARK: - Daily Goals

    private var dailyGoalsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily Goals")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
                Button {
                    showGoalEditor = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.green)
                }
            }

            goalRow(icon: "flame.fill", color: .orange, label: "Calories", value: "\(store.dailyCalorieGoal) cal")
            Divider()
            goalRow(icon: "circle.hexagongrid.fill", color: .blue, label: "Protein", value: "\(Int(store.dailyProteinGoal))g")
            Divider()
            goalRow(icon: "bolt.fill", color: .orange, label: "Carbs", value: "\(Int(store.dailyCarbsGoal))g")
            Divider()
            goalRow(icon: "drop.triangle.fill", color: .pink, label: "Fat", value: "\(Int(store.dailyFatGoal))g")
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private func goalRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Personal Info

    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Personal Info")
                .font(.system(size: 17, weight: .semibold, design: .rounded))

            infoRow(icon: "person.fill", color: .indigo, label: "Age", value: "\(store.userAge) years")
            Divider()
            infoRow(icon: "scalemass.fill", color: .green, label: "Weight", value: "\(Int(store.userWeight)) lbs")
            Divider()
            infoRow(icon: "ruler.fill", color: .purple, label: "Height", value: heightString)
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private func infoRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var heightString: String {
        let feet = Int(store.userHeight) / 12
        let inches = Int(store.userHeight) % 12
        return "\(feet)'\(inches)\""
    }

    // MARK: - Settings

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.system(size: 17, weight: .semibold, design: .rounded))

            HStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                    .frame(width: 28, height: 28)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("Notifications")
                    .font(.system(size: 15, weight: .medium, design: .rounded))

                Spacer()

                Toggle("", isOn: Bindable(store).showNotifications)
                    .tint(.green)
                    .labelsHidden()
            }

            Divider()

            HStack {
                Image(systemName: "moon.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.indigo)
                    .frame(width: 28, height: 28)
                    .background(Color.indigo.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("Dark Mode")
                    .font(.system(size: 15, weight: .medium, design: .rounded))

                Spacer()

                Toggle("", isOn: Bindable(store).useDarkMode)
                    .tint(.green)
                    .labelsHidden()
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - About

    private var aboutButton: some View {
        Button {
            showAbout = true
        } label: {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .frame(width: 28, height: 28)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("About")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                Text("v1.0")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(.systemGray3))
            }
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }

}

#Preview {
    ProfileView()
        .environment(MealStore())
}
