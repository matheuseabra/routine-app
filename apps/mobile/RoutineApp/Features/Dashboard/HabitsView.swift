import SwiftUI

struct HabitsView: View {
    let tasks: [RoutineTask]
    let onToggleTask: (RoutineTask) -> Void
    let onEditTask: (RoutineTask) -> Void
    let onDeleteTask: (RoutineTask) -> Void

    var body: some View {
        VStack(spacing: 0) {
            RoutinePageHeader(title: "Habits")
                .padding(.horizontal, RoutineSpacing.lg)
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, tasks.isEmpty ? 0 : RoutineSpacing.xl)

            if tasks.isEmpty {
                RoutineEmptyState(
                    icon: .listChecks,
                    title: "Build your first habit",
                    message: "Start small and keep showing up."
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        progressCard
                            .padding(.bottom, RoutineSpacing.xxl)
                        RoutineTaskList(
                            tasks: tasks,
                            onToggleTask: onToggleTask,
                            onEditTask: onEditTask,
                            onDeleteTask: onDeleteTask
                        )
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

    private var progressCard: some View {
        let completed = tasks.filter(\.isCompleted).count
        return RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.md) {
                HStack(alignment: .firstTextBaseline) {
                    Text(completed == tasks.count ? "All done today" : "One step at a time")
                        .font(RoutineTypography.timelineTitle)
                    Spacer()
                    Text("\(completed) of \(tasks.count)")
                        .font(RoutineTypography.small)
                        .foregroundStyle(RoutineColors.secondaryText)
                }
                RoutineProgressBar(progress: Double(completed) / Double(tasks.count))
                Text(completed == tasks.count
                     ? "You showed up for your routine."
                     : "Up next: \(tasks.first(where: { !$0.isCompleted })?.title ?? "your next task")")
                    .font(RoutineTypography.smallRegular)
                    .foregroundStyle(RoutineColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview("Habits") {
    HabitsView(tasks: [], onToggleTask: { _ in }, onEditTask: { _ in }, onDeleteTask: { _ in })
}
