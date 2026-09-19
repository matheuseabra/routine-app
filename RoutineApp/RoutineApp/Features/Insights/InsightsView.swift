import Charts
import SwiftUI

private enum InsightRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"

    var id: Self { self }
}

private struct InsightPoint: Identifiable {
    let id: String
    let label: String
    let value: Double

    init(label: String, value: Double) {
        id = label
        self.label = label
        self.value = value
    }
}

struct InsightsView: View {
    @State private var selectedRange: InsightRange = .week
    @State private var rangeHapticTrigger = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.xl)
                RoutineSectionHeader(title: "OVERVIEW")
                    .padding(.bottom, RoutineSpacing.sm)
                rangePicker
                    .padding(.bottom, RoutineSpacing.lg)
                metrics
                    .padding(.bottom, RoutineSpacing.lg)
                trendCard
                    .padding(.bottom, RoutineSpacing.md)
                dailyCompletionCard
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.huge)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
    }

    private var header: some View {
        RoutinePageHeader(
            title: "Insights",
            subtitle: "A clear view of the progress you’re making."
        )
    }

    private var rangePicker: some View {
        HStack(spacing: RoutineSpacing.xxs) {
            ForEach(InsightRange.allCases) { range in
                Button {
                    rangeHapticTrigger += 1
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selectedRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(RoutineTypography.button)
                        .foregroundStyle(selectedRange == range ? RoutineColors.inverseText : RoutineColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            selectedRange == range ? RoutineColors.primaryText : Color.clear,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(range.rawValue)
                .accessibilityValue(selectedRange == range ? "Selected" : "Not selected")
            }
        }
        .padding(RoutineSpacing.xxs)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .sensoryFeedback(.selection, trigger: rangeHapticTrigger)
        .accessibilityElement(children: .contain)
    }

    private var metrics: some View {
        HStack(spacing: RoutineSpacing.sm) {
            metric(value: selectedRange == .week ? "6" : "18", label: "day streak")
            metric(value: selectedRange == .week ? "78%" : "84%", label: "consistency")
            metric(value: selectedRange == .week ? "24" : "96", label: "tasks done")
        }
    }

    private func metric(value: String, label: String) -> some View {
        RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(value)
                    .font(RoutineTypography.metric)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(RoutineTypography.small)
                    .foregroundStyle(RoutineColors.secondaryText)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var trendCard: some View {
        RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.md) {
                VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                    Text("Completion trend")
                        .font(RoutineTypography.timelineTitle)
                    Text("Tasks completed over the selected period")
                        .font(RoutineTypography.small)
                        .foregroundStyle(RoutineColors.secondaryText)
                }
                Chart(trendPoints) { point in
                    LineMark(
                        x: .value("Period", point.label),
                        y: .value("Tasks", point.value)
                    )
                    .foregroundStyle(RoutineColors.primaryText)
                    .lineStyle(StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("Period", point.label),
                        y: .value("Tasks", point.value)
                    )
                    .foregroundStyle(RoutineColors.primaryText)
                    .symbolSize(22)
                }
                .chartYScale(domain: 0...(selectedRange == .week ? 8 : 60))
                .chartXAxis {
                    AxisMarks(values: trendLabels) { _ in
                        AxisValueLabel().font(RoutineTypography.chartLabel)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(RoutineColors.border)
                        AxisValueLabel().font(RoutineTypography.chartLabel)
                    }
                }
                .frame(height: 140)
                .accessibilityLabel("Completion trend chart")
                .accessibilityValue("\(selectedRange.rawValue) view")
            }
        }
    }

    private var dailyCompletionCard: some View {
        RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.md) {
                VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                    Text("Consistency by day")
                        .font(RoutineTypography.timelineTitle)
                    Text("Your strongest days this period")
                        .font(RoutineTypography.small)
                        .foregroundStyle(RoutineColors.secondaryText)
                }
                Chart(dailyPoints) { point in
                    BarMark(
                        x: .value("Day", point.label),
                        y: .value("Completion", point.value)
                    )
                    .foregroundStyle(RoutineColors.primaryText)
                    .cornerRadius(3)
                }
                .chartYScale(domain: 0...1)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 0.5, 1]) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(RoutineColors.border)
                        AxisValueLabel().font(RoutineTypography.chartLabel)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel().font(RoutineTypography.chartLabel)
                    }
                }
                .frame(height: 120)
                .accessibilityLabel("Consistency by day chart")
            }
        }
    }

    private var trendPoints: [InsightPoint] {
        if selectedRange == .week {
            let labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let values: [Double] = [2, 3, 2.5, 4, 5, 5.5, 6]
            return zip(labels, values).map { InsightPoint(label: $0.0, value: $0.1) }
        }
        let labels: [String] = ["W1", "W2", "W3", "W4", "W5", "W6"]
        let values: [Double] = [9, 18, 24, 33, 42, 52]
        return zip(labels, values).map { InsightPoint(label: $0.0, value: $0.1) }
    }

    private var dailyPoints: [InsightPoint] {
        if selectedRange == .week {
            let labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let values: [Double] = [0.7, 0.85, 0.55, 0.8, 0.95, 0.9, 0.75]
            return zip(labels, values).map { InsightPoint(label: $0.0, value: $0.1) }
        }
        let labels: [String] = ["W1", "W2", "W3", "W4", "W5", "W6"]
        let values: [Double] = [0.68, 0.74, 0.82, 0.78, 0.88, 0.84]
        return zip(labels, values).map { InsightPoint(label: $0.0, value: $0.1) }
    }

    private var trendLabels: [String] { trendPoints.map(\.label) }
}

#Preview("Insights") {
    InsightsView()
}
