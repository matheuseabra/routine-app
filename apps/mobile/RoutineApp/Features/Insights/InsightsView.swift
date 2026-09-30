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
    let onOpenDashboard: () -> Void
    @State private var selectedRange: InsightRange = .week
    @State private var rangeHapticTrigger = 0

    init(checkIns: [RoutineCheckIn] = [], onOpenDashboard: @escaping () -> Void = {}) {
        self.checkIns = checkIns
        self.onOpenDashboard = onOpenDashboard
    }

    var body: some View {
        VStack(spacing: 0) {
            RoutinePageHeader(title: "Insights")
                .padding(.horizontal, RoutineSpacing.lg)
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, checkIns.isEmpty ? 0 : RoutineSpacing.xl)

            if checkIns.isEmpty {
                RoutineEmptyState(
                    icon: .chartLineUp,
                    title: "Your first check-in starts here",
                    message: "Complete a task to see your activity and consistency here.",
                    actionTitle: "View your dashboard",
                    action: onOpenDashboard
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        RoutineSectionHeader(title: "Your activity")
                            .padding(.bottom, RoutineSpacing.sm)
                        rangePicker
                            .padding(.bottom, RoutineSpacing.lg)
                        metrics
                            .padding(.bottom, RoutineSpacing.lg)
                        trendCard
                    }
                    .padding(.horizontal, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.huge)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoutineColors.background)
    }

    private var rangeStart: Date {
        Calendar.current.date(
            byAdding: .day,
            value: -(selectedRange.dayCount - 1),
            to: Calendar.current.startOfDay(for: .now)
        ) ?? .distantPast
    }

    private var filteredCheckIns: [RoutineCheckIn] {
        checkIns.filter { $0.completedAt >= rangeStart }
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
            metric(value: "\(activeDayCount)", label: "days active")
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
                    Text("Daily progress")
                        .font(RoutineTypography.timelineTitle)
                    Text("Tasks completed each day")
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
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine()
                        AxisValueLabel()
                            .font(RoutineTypography.chartLabel)
                    }
                }
                .chartXScale(domain: chartDateRange)
                .chartYScale(domain: 0...max(3, points.map(\.value).max() ?? 0))
                .frame(height: 180)
            }
        }
    }

    private var points: [InsightPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredCheckIns) {
            calendar.startOfDay(for: $0.completedAt)
        }

        return (0..<selectedRange.dayCount).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: rangeStart) else { return nil }
            return InsightPoint(id: day, date: day, value: Double(grouped[day]?.count ?? 0))
        }
    }

    private var activeDayCount: Int {
        Set(filteredCheckIns.map { Calendar.current.startOfDay(for: $0.completedAt) }).count
    }

    private var chartDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let lower = calendar.date(byAdding: .day, value: -1, to: rangeStart) ?? rangeStart
        let upper = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now)) ?? .now
        return lower...upper
    }
}

#Preview("Insights") {
    InsightsView()
}
