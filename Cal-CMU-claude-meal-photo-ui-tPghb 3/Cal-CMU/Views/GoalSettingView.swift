import SwiftUI

struct GoalSettingView: View {
    @Environment(MealStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    // Weekday
    @State private var calories: Double = 2000
    @State private var protein: Double = 150
    @State private var carbs: Double = 250
    @State private var fat: Double = 65

    // Weekend
    @State private var useWeekendPlan: Bool = false
    @State private var wkndCalories: Double = 2200
    @State private var wkndProtein: Double = 130
    @State private var wkndCarbs: Double = 280
    @State private var wkndFat: Double = 75

    // Weight goal
    @State private var weightGoalType: String = "maintain"
    @State private var targetWeight: Double = 165 // always in display units
    @State private var hasTarget: Bool = false
    @State private var weightPace: Double = 1.0   // display-unit per timeframe
    @State private var weightTimeframe: String = "weekly"

    @State private var hasInitialized = false
    @State private var selectedTab = 0

    private var isMetric: Bool { store.isMetric }
    private var wUnit: String { store.weightUnit }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    planTypePicker

                    if selectedTab == 0 {
                        weekdayGoals
                    } else {
                        weekendGoals
                    }

                    calorieBreakdown(
                        cals: selectedTab == 0 ? calories : wkndCalories,
                        prot: selectedTab == 0 ? protein : wkndProtein,
                        carb: selectedTab == 0 ? carbs : wkndCarbs,
                        f: selectedTab == 0 ? fat : wkndFat
                    )

                    weightGoalSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoals()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                }
            }
            .onAppear {
                if !hasInitialized {
                    calories = Double(store.dailyCalorieGoal)
                    protein = store.dailyProteinGoal
                    carbs = store.dailyCarbsGoal
                    fat = store.dailyFatGoal
                    useWeekendPlan = store.useWeekendPlan
                    wkndCalories = Double(store.weekendCalorieGoal)
                    wkndProtein = store.weekendProteinGoal
                    wkndCarbs = store.weekendCarbsGoal
                    wkndFat = store.weekendFatGoal
                    weightGoalType = store.weightGoalType
                    hasTarget = store.targetWeight != nil
                    // Convert stored imperial value to display units
                    let storedTarget = store.targetWeight ?? store.userWeight
                    targetWeight = store.displayWeight(storedTarget)
                    // Pace: stored in lbs, convert to display
                    weightPace = isMetric ? store.weightGoalPace * 0.453592 : store.weightGoalPace
                    weightTimeframe = store.weightGoalTimeframe
                    hasInitialized = true
                }
            }
        }
    }

    // MARK: - Plan Type Picker

    private var planTypePicker: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                    .frame(width: 28, height: 28)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("Separate Weekend Plan")
                    .font(.system(size: 15, weight: .medium, design: .rounded))

                Spacer()

                Toggle("", isOn: $useWeekendPlan.animation(.spring(response: 0.3)))
                    .tint(.green)
                    .labelsHidden()
            }

            if useWeekendPlan {
                Picker("Plan", selection: $selectedTab) {
                    Text("Weekday").tag(0)
                    Text("Weekend").tag(1)
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Weekday Goals

    private var weekdayGoals: some View {
        VStack(spacing: 20) {
            goalSlider(title: "Calories", icon: "flame.fill", color: .orange, value: $calories, range: 1200...4000, step: 50, unit: "cal")
            goalSlider(title: "Protein", icon: "circle.hexagongrid.fill", color: .blue, value: $protein, range: 50...300, step: 5, unit: "g")
            goalSlider(title: "Carbs", icon: "bolt.fill", color: .orange, value: $carbs, range: 100...500, step: 10, unit: "g")
            goalSlider(title: "Fat", icon: "drop.triangle.fill", color: .pink, value: $fat, range: 30...150, step: 5, unit: "g")
        }
    }

    // MARK: - Weekend Goals

    private var weekendGoals: some View {
        VStack(spacing: 20) {
            goalSlider(title: "Calories", icon: "flame.fill", color: .orange, value: $wkndCalories, range: 1200...4000, step: 50, unit: "cal")
            goalSlider(title: "Protein", icon: "circle.hexagongrid.fill", color: .blue, value: $wkndProtein, range: 50...300, step: 5, unit: "g")
            goalSlider(title: "Carbs", icon: "bolt.fill", color: .orange, value: $wkndCarbs, range: 100...500, step: 10, unit: "g")
            goalSlider(title: "Fat", icon: "drop.triangle.fill", color: .pink, value: $wkndFat, range: 30...150, step: 5, unit: "g")
        }
    }

    // MARK: - Weight Goal

    private var weightGoalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "scalemass.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                    .frame(width: 28, height: 28)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text("Weight Goal")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                Toggle("", isOn: $hasTarget.animation(.spring(response: 0.3)))
                    .tint(.green)
                    .labelsHidden()
            }

            if hasTarget {
                // Goal type
                Picker("Goal Type", selection: $weightGoalType) {
                    Text("Lose").tag("lose")
                    Text("Maintain").tag("maintain")
                    Text("Gain").tag("gain")
                }
                .pickerStyle(.segmented)

                // Target weight slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Target")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(targetWeight)) \(wUnit)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                            .contentTransition(.numericText())
                    }

                    Slider(value: $targetWeight, in: store.weightSliderRange, step: 1)
                        .tint(.green)

                    HStack {
                        let currentDisplay = store.displayWeight(store.userWeight)
                        Text("Current: \(Int(currentDisplay)) \(wUnit)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                        Spacer()
                        let diff = targetWeight - currentDisplay
                        Text(diff >= 0 ? "+\(Int(diff)) \(wUnit)" : "\(Int(diff)) \(wUnit)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(diff == 0 ? Color.secondary : (diff > 0 ? Color.green : Color.orange))
                    }
                }

                // Timeframe picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timeframe")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Picker("Timeframe", selection: $weightTimeframe) {
                        Text("Per Week").tag("weekly")
                        Text("Per Month").tag("monthly")
                    }
                    .pickerStyle(.segmented)
                }

                // Pace slider
                if weightGoalType != "maintain" {
                    let paceRange = paceRangeForDisplay
                    let paceStep = isMetric ? 0.1 : 0.5
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Pace")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            Spacer()
                            let timeLabel = weightTimeframe == "weekly" ? "week" : "month"
                            Text("\(String(format: isMetric ? "%.1f" : "%.1f", weightPace)) \(wUnit)/\(timeLabel)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                                .contentTransition(.numericText())
                        }

                        Slider(value: $weightPace, in: paceRange, step: paceStep)
                            .tint(.green)

                        // Estimated time to goal
                        let currentDisplay = store.displayWeight(store.userWeight)
                        let totalToLose = abs(targetWeight - currentDisplay)
                        if weightPace > 0 && totalToLose > 0 {
                            let multiplier: Double = weightTimeframe == "weekly" ? 1.0 : (1.0 / 4.33)
                            let weeksNeeded = totalToLose / (weightPace * multiplier)
                            let months = Int(weeksNeeded / 4.33)
                            let weeks = Int(weeksNeeded) % 4
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.green)
                                let estimate = months > 0 ? "\(months)mo \(weeks)wk" : "\(Int(weeksNeeded))wk"
                                Text("Estimated: \(estimate)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private var paceRangeForDisplay: ClosedRange<Double> {
        if weightTimeframe == "weekly" {
            return isMetric ? 0.2...1.5 : 0.5...3.0
        }
        return isMetric ? 0.5...6.0 : 1.0...12.0
    }

    // MARK: - Reusable Slider

    private func goalSlider(
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

    // MARK: - Calorie Breakdown

    private func calorieBreakdown(cals: Double, prot: Double, carb: Double, f: Double) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calorie Breakdown")
                .font(.system(size: 15, weight: .semibold, design: .rounded))

            let proteinCals = prot * 4
            let carbsCals = carb * 4
            let fatCals = f * 9
            let total = proteinCals + carbsCals + fatCals

            HStack(spacing: 16) {
                breakdownItem("Protein", cals: Int(proteinCals), pct: total > 0 ? proteinCals / total * 100 : 0, color: .blue)
                breakdownItem("Carbs", cals: Int(carbsCals), pct: total > 0 ? carbsCals / total * 100 : 0, color: .orange)
                breakdownItem("Fat", cals: Int(fatCals), pct: total > 0 ? fatCals / total * 100 : 0, color: .pink)
            }

            if abs(total - cals) > 100 {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.yellow)
                    Text("Macro total (\(Int(total)) cal) differs from calorie goal (\(Int(cals)) cal)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func breakdownItem(_ label: String, cals: Int, pct: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(pct))%")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Text("\(cals) cal")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Save

    private func saveGoals() {
        store.dailyCalorieGoal = Int(calories)
        store.dailyProteinGoal = protein
        store.dailyCarbsGoal = carbs
        store.dailyFatGoal = fat
        store.useWeekendPlan = useWeekendPlan
        store.weekendCalorieGoal = Int(wkndCalories)
        store.weekendProteinGoal = wkndProtein
        store.weekendCarbsGoal = wkndCarbs
        store.weekendFatGoal = wkndFat
        store.weightGoalType = hasTarget ? weightGoalType : "maintain"
        // Convert display units back to imperial for storage
        store.targetWeight = hasTarget ? store.weightFromDisplay(targetWeight) : nil
        store.weightGoalPace = isMetric ? weightPace / 0.453592 : weightPace
        store.weightGoalTimeframe = weightTimeframe
        Task { await store.saveGoals() }
    }
}

#Preview {
    GoalSettingView()
        .environment(MealStore())
}
