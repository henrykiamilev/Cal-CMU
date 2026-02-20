import SwiftUI

struct ProfileView: View {
    @Environment(MealStore.self) private var store
    @Environment(AuthManager.self) private var auth
    @State private var showGoalEditor = false
    @State private var showProfileEditor = false
    @State private var showAbout = false
    @State private var showSignOutConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeader
                    dailyGoalsCard
                    personalInfoCard
                    settingsCard
                    aboutButton
                    signOutButton
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
            .sheet(isPresented: $showProfileEditor) {
                ProfileEditView()
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

            if store.useWeekendPlan {
                HStack {
                    Text(store.activePlanLabel)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                    Spacer()
                }
            }

            goalRow(icon: "flame.fill", color: .orange, label: "Calories", value: "\(store.activeCalorieGoal) cal")
            Divider()
            goalRow(icon: "circle.hexagongrid.fill", color: .blue, label: "Protein", value: "\(Int(store.activeProteinGoal))g")
            Divider()
            goalRow(icon: "bolt.fill", color: .orange, label: "Carbs", value: "\(Int(store.activeCarbsGoal))g")
            Divider()
            goalRow(icon: "drop.triangle.fill", color: .pink, label: "Fat", value: "\(Int(store.activeFatGoal))g")

            if let target = store.targetWeight {
                Divider()
                let displayTarget = store.displayWeightInt(target)
                goalRow(icon: "scalemass.fill", color: .green, label: "Weight Goal", value: "\(displayTarget) \(store.weightUnit) (\(store.weightGoalType))")
                if store.weightGoalType != "maintain" {
                    goalRow(icon: "clock.fill", color: .green, label: "Pace", value: store.weightGoalPaceLabel)
                }
            }
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
            HStack {
                Text("Personal Info")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
                Button {
                    showProfileEditor = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.green)
                }
            }

            infoRow(icon: "person.fill", color: .indigo, label: "Name", value: store.userName.isEmpty ? "Not set" : store.userName)
            Divider()
            infoRow(icon: "birthday.cake.fill", color: .orange, label: "Age", value: "\(store.userAge) years")
            Divider()
            infoRow(icon: "scalemass.fill", color: .green, label: "Weight", value: store.formattedWeight)
            Divider()
            infoRow(icon: "ruler.fill", color: .purple, label: "Height", value: store.formattedHeight)
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
        store.formattedHeight
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

            Divider()

            HStack {
                Image(systemName: "ruler")
                    .font(.system(size: 14))
                    .foregroundStyle(.teal)
                    .frame(width: 28, height: 28)
                    .background(Color.teal.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("Units")
                    .font(.system(size: 15, weight: .medium, design: .rounded))

                Spacer()

                Picker("", selection: Bindable(store).unitSystem) {
                    Text("Imperial").tag("imperial")
                    Text("Metric").tag("metric")
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
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

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                    .frame(width: 28, height: 28)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("Sign Out")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)

                Spacer()

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
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                Task { await auth.signOut(mealStore: store) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onChange(of: store.showNotifications) { _, _ in
            Task { await store.saveSettings() }
        }
        .onChange(of: store.useDarkMode) { _, _ in
            Task { await store.saveSettings() }
        }
        .onChange(of: store.unitSystem) { _, _ in
            Task { await store.saveProfile() }
        }
    }

}

#Preview {
    ProfileView()
        .environment(MealStore())
        .environment(AuthManager())
}

// MARK: - Profile Edit View

struct ProfileEditView: View {
    @Environment(MealStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var age: Double = 22
    @State private var weight: Double = 165  // in display units
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 0
    @State private var heightCm: Double = 170
    @State private var hasInitialized = false

    private var isMetric: Bool { store.isMetric }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Name
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.indigo)
                                .frame(width: 28, height: 28)
                                .background(Color.indigo.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 7))

                            Text("Name")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }

                        TextField("Your name", text: $name)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(18)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

                    // Age
                    profileSlider(
                        title: "Age",
                        icon: "birthday.cake.fill",
                        color: .orange,
                        value: $age,
                        range: 13...100,
                        step: 1,
                        unit: "years"
                    )

                    // Weight
                    profileSlider(
                        title: "Weight",
                        icon: "scalemass.fill",
                        color: .green,
                        value: $weight,
                        range: isMetric ? 35...180 : 80...400,
                        step: 1,
                        unit: store.weightUnit
                    )

                    // Height
                    if isMetric {
                        metricHeightEditor
                    } else {
                        imperialHeightEditor
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                }
            }
            .onAppear {
                if !hasInitialized {
                    name = store.userName
                    age = Double(store.userAge)
                    weight = store.displayWeight(store.userWeight)
                    let totalInches = Int(store.userHeight)
                    heightFeet = totalInches / 12
                    heightInches = totalInches % 12
                    heightCm = store.displayHeight(store.userHeight)
                    hasInitialized = true
                }
            }
        }
    }

    // MARK: - Imperial Height

    private var imperialHeightEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "ruler.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.purple)
                    .frame(width: 28, height: 28)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("Height")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                Text("\(heightFeet)'\(heightInches)\"")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)
                    .contentTransition(.numericText())
            }

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Feet")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(3...8, id: \.self) { ft in
                            Text("\(ft)").tag(ft)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("Inches")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Picker("Inches", selection: $heightInches) {
                        ForEach(0...11, id: \.self) { inch in
                            Text("\(inch)").tag(inch)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Metric Height

    private var metricHeightEditor: some View {
        profileSlider(
            title: "Height",
            icon: "ruler.fill",
            color: .purple,
            value: $heightCm,
            range: 100...250,
            step: 1,
            unit: "cm"
        )
    }

    // MARK: - Slider

    private func profileSlider(
        title: String, icon: String, color: Color,
        value: Binding<Double>, range: ClosedRange<Double>,
        step: Double, unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                Text("\(Int(value.wrappedValue)) \(unit)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }

            Slider(value: value, in: range, step: step)
                .tint(color)

            HStack {
                Text("\(Int(range.lowerBound))")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("\(Int(range.upperBound))")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func saveProfile() {
        store.userName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        store.userAge = Int(age)
        // Convert display units back to imperial for storage
        store.userWeight = store.weightFromDisplay(weight)
        if isMetric {
            store.userHeight = store.heightFromDisplay(heightCm)
        } else {
            store.userHeight = Double(heightFeet * 12 + heightInches)
        }
        Task { await store.saveProfile() }
    }
}
