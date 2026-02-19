import SwiftUI

struct MealCardView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            // Meal image or placeholder
            Group {
                if let image = meal.image {
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
                            .font(.system(size: 20))
                            .foregroundStyle(meal.mealType.color.opacity(0.5))
                    }
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    // Meal type badge
                    HStack(spacing: 3) {
                        Image(systemName: meal.mealType.icon)
                            .font(.system(size: 9))
                        Text(meal.mealType.rawValue)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(meal.mealType.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(meal.mealType.color.opacity(0.1))
                    .clipShape(Capsule())

                    Label("\(meal.calories) cal", systemImage: "flame.fill")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Text(meal.timeString)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Macro mini pills
            VStack(alignment: .trailing, spacing: 4) {
                macroPill("P", value: Int(meal.protein), color: .blue)
                macroPill("C", value: Int(meal.carbs), color: .orange)
                macroPill("F", value: Int(meal.fat), color: .pink)
            }
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func macroPill(_ letter: String, value: Int, color: Color) -> some View {
        HStack(spacing: 2) {
            Text(letter)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text("\(value)g")
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.08))
        .clipShape(Capsule())
    }
}

#Preview {
    MealCardView(meal: Meal.sampleMeals[0])
        .padding()
        .background(Color(.systemGroupedBackground))
}
