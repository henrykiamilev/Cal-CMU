import SwiftUI

struct WeeklyChartView: View {
    let data: [(day: String, calories: Int)]
    let goal: Int

    @State private var animateChart = false
    @State private var selectedBar: Int?

    private var maxValue: Int {
        max(data.map(\.calories).max() ?? 1, goal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Weekly Calories")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
                if let selected = selectedBar, selected < data.count {
                    Text("\(data[selected].day): \(data[selected].calories) cal")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }
            }

            // Chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 6) {
                        // Bar
                        ZStack(alignment: .bottom) {
                            // Goal line indicator
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray5))
                                .frame(height: 120)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(barColor(for: item.calories))
                                .frame(height: animateChart ? barHeight(item.calories) : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.08),
                                    value: animateChart
                                )
                        }
                        .frame(height: 120)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.2)) {
                                selectedBar = selectedBar == index ? nil : index
                            }
                        }
                        .scaleEffect(selectedBar == index ? 1.08 : 1.0)
                        .animation(.spring(response: 0.2), value: selectedBar)

                        // Day label
                        Text(item.day)
                            .font(.system(size: 11, weight: index == currentDayIndex ? .bold : .medium, design: .rounded))
                            .foregroundStyle(index == currentDayIndex ? .green : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Goal line label
            HStack {
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(height: 1)
                    .frame(maxWidth: 40)

                Text("Goal: \(goal) cal")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)

                Spacer()
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .onAppear { animateChart = true }
    }

    private func barHeight(_ calories: Int) -> CGFloat {
        guard maxValue > 0, calories > 0 else { return 4 }
        return max(CGFloat(calories) / CGFloat(maxValue) * 120, 4)
    }

    private func barColor(for calories: Int) -> LinearGradient {
        if calories == 0 {
            return LinearGradient(colors: [Color(.systemGray5)], startPoint: .bottom, endPoint: .top)
        } else if calories > goal {
            return LinearGradient(colors: [.red.opacity(0.6), .red], startPoint: .bottom, endPoint: .top)
        } else {
            return LinearGradient(colors: [.green.opacity(0.6), .green], startPoint: .bottom, endPoint: .top)
        }
    }

    private var currentDayIndex: Int {
        let weekday = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        return weekday
    }
}

#Preview {
    WeeklyChartView(
        data: [("M", 1650), ("T", 1820), ("W", 2100), ("T", 1950), ("F", 1780), ("S", 0), ("S", 0)],
        goal: 2000
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
