import SwiftUI

struct LogView: View {
    @Environment(MealStore.self) private var store
    let onAddMeal: (MealType) -> Void
    let onMealTap: (Meal) -> Void

    @State private var selectedDate = Date()
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Date selector
                    dateHeader

                    // Daily summary bar
                    dailySummary

                    // Meal categories
                    ForEach(MealType.allCases) { type in
                        mealCategorySection(type)
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Food Log")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDatePicker) {
                datePickerSheet
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack {
            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                showDatePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                    Text(dateLabel)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.primary)
            }

            Spacer()

            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
        }
    }

    private var dateLabel: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: selectedDate)
        }
    }

    // MARK: - Daily Summary

    private var dailySummary: some View {
        HStack(spacing: 0) {
            summaryItem(value: "\(store.totalCaloriesToday)", label: "Calories", color: .green)
            divider
            summaryItem(value: "\(Int(store.totalProteinToday))g", label: "Protein", color: .blue)
            divider
            summaryItem(value: "\(Int(store.totalCarbsToday))g", label: "Carbs", color: .orange)
            divider
            summaryItem(value: "\(Int(store.totalFatToday))g", label: "Fat", color: .pink)
        }
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private func summaryItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(.systemGray4))
            .frame(width: 1, height: 30)
    }

    // MARK: - Meal Category Section

    private func mealCategorySection(_ type: MealType) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Category header
            HStack(spacing: 10) {
                Image(systemName: type.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(type.color)
                    .frame(width: 32, height: 32)
                    .background(type.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(type.rawValue)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))

                Spacer()

                let cals = store.caloriesForType(type)
                if cals > 0 {
                    Text("\(cals) cal")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            // Meals for this category
            let meals = store.mealsForType(type)
            if meals.isEmpty {
                Button {
                    onAddMeal(type)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(type.color)
                        Text("Add \(type.rawValue)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                ForEach(meals) { meal in
                    logMealRow(meal, type: type)
                }

                // Add more button
                Button {
                    onAddMeal(type)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Add More")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(type.color)
                    .padding(.vertical, 8)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private func logMealRow(_ meal: Meal, type: MealType) -> some View {
        Button {
            onMealTap(meal)
        } label: {
            HStack(spacing: 12) {
                // Meal image or placeholder
                Group {
                    if let image = meal.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            LinearGradient(
                                colors: type.gradient.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Image(systemName: "fork.knife")
                                .font(.system(size: 14))
                                .foregroundStyle(type.color.opacity(0.6))
                        }
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(meal.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(meal.timeString)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(meal.calories) cal")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("P:\(Int(meal.protein))g")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(.systemGray3))
            }
            .padding(10)
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Date Picker Sheet

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(.green)
            .padding()
            .navigationTitle("Choose Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    LogView(onAddMeal: { _ in }, onMealTap: { _ in })
        .environment(MealStore())
}
