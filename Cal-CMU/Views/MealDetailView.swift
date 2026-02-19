import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    let capturedImage: UIImage?
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Meal photo
                    mealPhotoSection

                    // Calorie summary
                    calorieSummarySection

                    // Macronutrient rings
                    macroRingsSection

                    // Detailed nutrients
                    nutrientListSection

                    // Save button
                    saveButton

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Meal Analysis")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
        }
    }

    // MARK: - Meal Photo

    private var mealPhotoSection: some View {
        Group {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "fork.knife")
                        .font(.system(size: 48))
                        .foregroundStyle(.green.opacity(0.4))
                }
                .frame(height: 240)
            }
        }
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Calorie Summary

    private var calorieSummarySection: some View {
        VStack(spacing: 6) {
            Text(meal.name)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.system(size: 16))
                Text("\(meal.calories) calories")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.2), value: appeared)
    }

    // MARK: - Macro Rings

    private var macroRingsSection: some View {
        HStack(spacing: 20) {
            macroRing(
                label: "Protein",
                value: meal.protein,
                color: .blue,
                icon: "p"
            )
            macroRing(
                label: "Carbs",
                value: meal.carbs,
                color: .orange,
                icon: "c"
            )
            macroRing(
                label: "Fat",
                value: meal.fat,
                color: .pink,
                icon: "f"
            )
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.3), value: appeared)
    }

    private func macroRing(label: String, value: Double, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                    .frame(width: 70, height: 70)

                Circle()
                    .trim(from: 0, to: appeared ? min(value / 100, 1.0) : 0)
                    .stroke(color.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: appeared)

                Text("\(Int(value))g")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }

            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Nutrient List

    private var nutrientListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Nutrients")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .padding(.bottom, 12)

            nutrientRow(name: "Fiber", value: "\(Int(meal.fiber))g", icon: "leaf.fill", color: .green)
            Divider().padding(.vertical, 8)
            nutrientRow(name: "Sugar", value: "\(Int(meal.sugar))g", icon: "cube.fill", color: .purple)
            Divider().padding(.vertical, 8)
            nutrientRow(name: "Sodium", value: "\(Int(meal.sodium))mg", icon: "drop.fill", color: .cyan)
            Divider().padding(.vertical, 8)
            nutrientRow(name: "Protein", value: "\(Int(meal.protein))g", icon: "circle.hexagongrid.fill", color: .blue)
            Divider().padding(.vertical, 8)
            nutrientRow(name: "Carbohydrates", value: "\(Int(meal.carbs))g", icon: "bolt.fill", color: .orange)
            Divider().padding(.vertical, 8)
            nutrientRow(name: "Total Fat", value: "\(Int(meal.fat))g", icon: "drop.triangle.fill", color: .pink)
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.4), value: appeared)
    }

    private func nutrientRow(name: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(name)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            onSave()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                Text("Save Meal")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.green.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.5), value: appeared)
    }
}

#Preview {
    MealDetailView(
        meal: Meal.sampleMeals[0],
        capturedImage: nil,
        onSave: {}
    )
}
