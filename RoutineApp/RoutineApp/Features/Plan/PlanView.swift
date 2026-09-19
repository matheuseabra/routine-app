import Charts
import SwiftUI

struct PlanView: View {
    let onContinue: () -> Void

    private let withRoutine = [2.0, 2.8, 3.4, 4.1, 4.8, 5.5, 6.1]
    private let withoutRoutine = [1.0, 1.8, 1.4, 2.4, 2.1, 3.1, 3.6]
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        RoutineScreenLayout {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)
                Text("A clearer path\nto your goals.")
                    .routineTitleStyle()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.sm)
                Text("Our users report they get 3x more done using Routine.")
                    .routineSubtitleStyle()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, RoutineSpacing.lg)
                chartCard
                Spacer(minLength: 0)
            }
        } bottom: {
            RoutinePrimaryButton(title: "Continue", action: onContinue)
        }
    }

    private var chartCard: some View {
        RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.md) {
                Text("Tasks completed over time")
                    .font(RoutineTypography.timelineTitle)
                Chart {
                    ForEach(Array(zip(days, withoutRoutine)), id: \.0) { day, value in
                        LineMark(
                            x: .value("Time", day),
                            y: .value("Tasks", value),
                            series: .value("Series", "Without Routine")
                        )
                            .foregroundStyle(RoutineColors.tertiaryText)
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                            .interpolationMethod(.catmullRom)
                    }
                    ForEach(Array(zip(days, withRoutine)), id: \.0) { day, value in
                        LineMark(
                            x: .value("Time", day),
                            y: .value("Tasks", value),
                            series: .value("Series", "With Routine")
                        )
                            .foregroundStyle(RoutineColors.primaryText)
                            .lineStyle(StrokeStyle(lineWidth: 2.2, lineCap: .round))
                            .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: 0...8)
                .chartXAxisLabel("time", alignment: .trailing)
                .chartYAxisLabel("tasks", position: .top)
                .chartXAxis {
                    AxisMarks(values: days) { _ in
                        AxisValueLabel().font(RoutineTypography.chartLabel)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 2, 4, 6, 8]) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(RoutineColors.border)
                        AxisValueLabel().font(RoutineTypography.chartLabel)
                    }
                }
                .frame(height: 220)
                legend
            }
        }
    }

    private var legend: some View {
        HStack(spacing: RoutineSpacing.lg) {
            legendItem(title: "Without Routine", color: RoutineColors.tertiaryText)
            legendItem(title: "With Routine", color: RoutineColors.primaryText)
        }
        .font(RoutineTypography.small)
    }

    private func legendItem(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title).lineLimit(1)
        }
    }
}

#Preview("Plan") {
    PlanView {}
}
