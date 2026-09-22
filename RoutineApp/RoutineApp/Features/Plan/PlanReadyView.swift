import Charts
import SwiftUI

struct PlanReadyView: View {
    let context: RoutinePlanContext
    let onContinue: () -> Void

    init(name: String, answers: [String?], onContinue: @escaping () -> Void) {
        context = RoutinePlanContext(name: name, answers: answers)
        self.onContinue = onContinue
    }

    var body: some View {
        RoutineScreenLayout(contentAlignment: .topLeading, minimumBottomSafeArea: 32) {
            VStack(alignment: .leading, spacing: 0) {
                RoutineFunnelBrandHeader()
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.lg)

                Text(context.readyTitle)
                    .font(RoutineTypography.funnelTitle)
                    .foregroundStyle(RoutineColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, RoutineSpacing.md)

                Text(context.readySubtitle)
                    .font(RoutineTypography.funnelSubtitle)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, RoutineSpacing.lg)

                startingRoutine
                    .padding(.bottom, RoutineSpacing.md)
                progressChart
            }
        } bottom: {
            RoutinePrimaryButton(title: "Continue", action: onContinue, visualStyle: .funnel)
        }
    }

    private var startingRoutine: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.xs) {
            Text("Your starting routine")
                .font(RoutineTypography.funnelSubtitle)
                .foregroundStyle(RoutineColors.primaryText)
                .padding(.bottom, RoutineSpacing.xxs)
            routineRow(icon: "sun.max", title: "Morning reset", duration: "2 min")
            routineRow(icon: "scope", title: "Focus block", duration: "10 min")
            routineRow(icon: "moon", title: "Evening review", duration: "3 min")
        }
        .padding(RoutineSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 12))
    }

    private func routineRow(icon: String, title: String, duration: String) -> some View {
        HStack(spacing: RoutineSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(RoutineColors.funnelSecondaryText)
                .frame(width: 16)
            Text(title)
                .font(RoutineTypography.funnelBody)
                .foregroundStyle(RoutineColors.primaryText)
            Spacer()
            Text(duration)
                .font(RoutineTypography.funnelSubtitle)
                .foregroundStyle(RoutineColors.secondaryText)
        }
        .frame(height: 34)
    }

    private var progressChart: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.xs) {
            Text("Your progress over time")
                .font(RoutineTypography.funnelSubtitle)
                .foregroundStyle(RoutineColors.primaryText)

            Chart {
                ForEach(progressDays, id: \.self) { day in
                    LineMark(
                        x: .value("Day", day),
                        y: .value("Progress", withoutRoutineValues[day]),
                        series: .value("Routine", "Without Routine")
                    )
                    .foregroundStyle(RoutineColors.tertiaryText)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 3]))
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", day),
                        y: .value("Progress", withRoutineValues[day]),
                        series: .value("Routine", "With Routine")
                    )
                    .foregroundStyle(RoutineColors.primaryText)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...7)
            .chartXScale(domain: 0...6)
            .chartPlotStyle { plot in
                plot.clipped()
            }
            .frame(height: 96)

            HStack(spacing: RoutineSpacing.lg) {
                progressLegendItem("Without Routine", color: RoutineColors.tertiaryText)
                progressLegendItem("With Routine", color: RoutineColors.primaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func progressLegendItem(_ title: String, color: Color) -> some View {
        HStack(spacing: RoutineSpacing.xs) {
            Capsule()
                .fill(color)
                .frame(width: 16, height: 2)
            Text(title)
                .font(RoutineTypography.funnelCaption)
                .foregroundStyle(RoutineColors.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }

    private let progressDays = Array(0...6)
    private let withoutRoutineValues: [Double] = [1.0, 1.2, 1.4, 1.7, 2.0, 2.3, 2.6]
    private let withRoutineValues: [Double] = [1.1, 1.7, 2.5, 3.5, 4.6, 5.7, 6.7]
}

#Preview("Plan ready") {
    PlanReadyView(
        name: "Matheus",
        answers: ["Stay more consistent", "I struggle with consistency", "Starting again", "10–15 minutes", nil],
        onContinue: {}
    )
}
