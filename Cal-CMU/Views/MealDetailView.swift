import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    let capturedImage: UIImage?
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    mealPhotoSection
                    calorieSummarySection
                    macroRingsSection
                    nutrientListSection
                    saveButton
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
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

    // MARK: - Photo

    private var mealPhotoSection: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        LinearGradient(
                            colors: meal.mealType.gradient.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Image(systemName: "fork.knife")
                            .font(.system(size: 48))
                            .foregroundStyle(meal.mealType.color.opacity(0.3))
                    }
                }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)

            // Meal type badge overlay
            HStack(spacing: 6) {
                Image(systemName: meal.mealType.icon)
                    .font(.system(size: 11))
                Text(meal.mealType.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(16)
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
        VStack(spacing: 8) {
            Text(meal.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.system(size: 18))
                Text("\(meal.calories)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("calories")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.2), value: appeared)
    }

    // MARK: - Macro Rings

    private var macroRingsSection: some View {
        HStack(spacing: 16) {
            macroRing(label: "Protein", value: meal.protein, color: .blue)
            macroRing(label: "Carbs", value: meal.carbs, color: .orange)
            macroRing(label: "Fat", value: meal.fat, color: .pink)
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.3), value: appeared)
    }

    private func macroRing(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.12), lineWidth: 10)
                    .frame(width: 76, height: 76)

                Circle()
                    .trim(from: 0, to: appeared ? min(value / 100, 1.0) : 0)
                    .stroke(color.gradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 76, height: 76)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: appeared)
                    .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)

                Text("\(Int(value))g")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }

            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Nutrients

    private var nutrientListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Detailed Nutrients")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .padding(.bottom, 14)

            nutrientRow(name: "Protein", value: "\(Int(meal.protein))g", icon: "circle.hexagongrid.fill", color: .blue)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Carbohydrates", value: "\(Int(meal.carbs))g", icon: "bolt.fill", color: .orange)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Total Fat", value: "\(Int(meal.fat))g", icon: "drop.triangle.fill", color: .pink)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Fiber", value: "\(Int(meal.fiber))g", icon: "leaf.fill", color: .green)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Sugar", value: "\(Int(meal.sugar))g", icon: "cube.fill", color: .purple)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Sodium", value: "\(Int(meal.sodium))mg", icon: "drop.fill", color: .cyan)

            // Vitamins
            Text("Vitamins")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .padding(.top, 16)
                .padding(.bottom, 6)

            nutrientRow(name: "Vitamin A", value: "\(Int(meal.vitaminA)) mcg", icon: "eye.fill", color: .orange)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin C", value: "\(Int(meal.vitaminC)) mg", icon: "pills.fill", color: .yellow)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin D", value: String(format: "%.1f mcg", meal.vitaminD), icon: "sun.max.fill", color: .orange)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin B6", value: String(format: "%.1f mg", meal.vitaminB6), icon: "bolt.heart.fill", color: .teal)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin B12", value: String(format: "%.1f mcg", meal.vitaminB12), icon: "heart.fill", color: .red)

            // Minerals
            Text("Minerals")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .padding(.top, 16)
                .padding(.bottom, 6)

            nutrientRow(name: "Potassium", value: "\(Int(meal.potassium)) mg", icon: "battery.75percent", color: .brown)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Iron", value: String(format: "%.1f mg", meal.iron), icon: "cross.vial.fill", color: .red)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Calcium", value: "\(Int(meal.calcium)) mg", icon: "bone.fill", color: .gray)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Magnesium", value: "\(Int(meal.magnesium)) mg", icon: "sparkles", color: .indigo)
            Divider().padding(.vertical, 10)
            nutrientRow(name: "Zinc", value: String(format: "%.1f mg", meal.zinc), icon: "shield.fill", color: .mint)
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.4), value: appeared)
    }

    private func nutrientRow(name: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(name)
                .font(.system(size: 15, weight: .medium, design: .rounded))

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Save

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
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.65, blue: 0.35)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .green.opacity(0.35), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
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
