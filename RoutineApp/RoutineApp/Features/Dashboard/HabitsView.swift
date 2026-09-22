import SwiftUI

struct HabitsView: View {
    let tasks: [RoutineTask]
    let onToggleTask: (RoutineTask) -> Void
    let onAddTask: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RoutinePageHeader(title: "Habits")
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, RoutineSpacing.xl)

                if tasks.isEmpty {
                    RoutineEmptyState(
                        icon: .listChecks,
                        title: "Make room for a new habit",
                        message: "Choose something small enough to repeat. You can always add more later.",
                        actionTitle: "Add a task",
                        action: onAddTask
                    )
                } else {
                    RoutineSectionHeader(title: "Your routine")
                        .padding(.bottom, RoutineSpacing.sm)

                    VStack(spacing: 0) {
                        ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                            RoutineTaskRow(task: task) { onToggleTask(task) }
                            if index < tasks.count - 1 {
                                Divider().overlay(RoutineColors.border)
                            }
                        }
                    }
                    .padding(.horizontal, RoutineSpacing.md)
                    .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))

                    RoutinePrimaryButton(title: "Add another task", action: onAddTask)
                        .padding(.top, RoutineSpacing.lg)
                }
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.huge)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
    }
}

#Preview("Habits") {
    HabitsView(tasks: [], onToggleTask: { _ in }, onAddTask: {})
}
