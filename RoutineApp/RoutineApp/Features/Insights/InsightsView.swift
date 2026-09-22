import Charts
import SwiftUI

private enum InsightRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    var id: Self { self }
    var dayCount: Int { self == .week ? 7 : 30 }
}

private struct InsightPoint: Identifiable {
    let id: Date
    let date: Date
    let value: Double
}

struct InsightsView: View {
    let checkIns: [RoutineCheckIn]
    let onOpenHabits: () -> Void
    @State private var selectedRange: InsightRange = .week
    @State private var rangeHapticTrigger = 0

    init(checkIns: [RoutineCheckIn] = [], onOpenHabits: @escaping () -> Void = {}) {
        self.checkIns = checkIns
        self.onOpenHabits = onOpenHabits
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RoutinePageHeader(
                    title: "Insights",
                    subtitle: "A clear view of the progress you’re making."
                )
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, RoutineSpacing.xl)

                if checkIns.isEmpty {
                    RoutineEmptyState(
                        icon: .chartLineUp,
                        title: "Your progress starts with a check-in",
                        message: "Complete a task to see your activity and consistency here.",
                        actionTitle: "View your habits",
                        action: onOpenHabits
                    )
                } else {
                    RoutineSectionHeader(title: "Overview")
                        .padding(.bottom, RoutineSpacing.sm)
                    rangePicker
                        .padding(.bottom, RoutineSpacing.lg)
                    metrics
                        .padding(.bottom, RoutineSpacing.lg)
                    trendCard
                }
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.huge)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
    }

    private var filteredCheckIns: [RoutineCheckIn] {
        let start = Calendar.current.date(
            byAdding: .day,
            value: -(selectedRange.dayCount - 1),
            to: Calendar.current.startOfDay(for: .now)
        ) ?? .distantPast
        return checkIns.filter { $0.completedAt >= start }
    }

    private var summary: InsightSummary {
        InsightSummary.make(checkIns: checkIns)
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
            }
        }
        .padding(RoutineSpacing.xxs)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .sensoryFeedback(.selection, trigger: rangeHapticTrigger)
    }

    private var metrics: some View {
        HStack(spacing: RoutineSpacing.sm) {
            metric(value: "\(summary.currentStreak)", label: "day streak")
            metric(value: "\(rangeConsistency)%", label: "consistency")
            metric(value: "\(filteredCheckIns.count)", label: "tasks done")
        }
    }

    private func metric(value: String, label: String) -> some View {
        RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(value).font(RoutineTypography.metric)
                Text(label)
                    .font(RoutineTypography.small)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .foregroundStyle(RoutineColors.secondaryText)
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
                    Text("Check-ins over the selected period")
                        .font(RoutineTypography.small)
                        .foregroundStyle(RoutineColors.secondaryText)
                }

                Chart(points) { point in
                    BarMark(
                        x: .value("Day", point.date),
                        y: .value("Check-ins", point.value)
                    )
                    .foregroundStyle(RoutineColors.primaryText)
                    .cornerRadius(3)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: selectedRange == .week ? 7 : 6)) { _ in
                        AxisValueLabel(format: .dateTime.day())
                            .font(RoutineTypography.chartLabel)
                    }
                }
                .frame(height: 180)
            }
        }
    }

    private var points: [InsightPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredCheckIns) {
            calendar.startOfDay(for: $0.completedAt)
        }

        return grouped
            .map { InsightPoint(id: $0.key, date: $0.key, value: Double($0.value.count)) }
            .sorted { $0.date < $1.date }
    }

    private var rangeConsistency: Int {
        let activeDays = Set(filteredCheckIns.map { Calendar.current.startOfDay(for: $0.completedAt) }).count
        return Int((Double(activeDays) / Double(selectedRange.dayCount) * 100).rounded())
    }
}

#Preview("Insights") {
    InsightsView()
}
