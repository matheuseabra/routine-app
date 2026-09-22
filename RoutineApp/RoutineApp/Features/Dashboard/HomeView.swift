import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    let tasks: [RoutineTask]
    let onToggleTask: (RoutineTask) -> Void
    let onAddTask: () -> Void
    @State private var insightsHapticTrigger = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.xl)
                if tasks.isEmpty {
                    emptyState
                } else {
                    progressCard
                        .padding(.bottom, RoutineSpacing.xl)
                    RoutineSectionHeader(title: "Your tasks")
                        .padding(.bottom, RoutineSpacing.sm)
                    taskList
                }
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.huge)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
    }

    private var header: some View {
        RoutinePageHeader(
            title: "Today",
            subtitle: "Keep your routine moving."
        ) {
            Button {
                insightsHapticTrigger += 1
                withAnimation(.easeInOut(duration: 0.18)) {
                    selectedTab = .insights
                }
            } label: {
                RoutineIcon(.chartLineUp)
                    .frame(width: 21, height: 21)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: insightsHapticTrigger)
            .accessibilityLabel("Insights")
        }
    }

    private var emptyState: some View {
        RoutineEmptyState(
            icon: .clipboardText,
            title: "Start with one small step",
            message: "Add a task you can complete today. You can build from there.",
            actionTitle: "Add your first task",
            action: onAddTask
        )
    }

    private var progressCard: some View {
        let completed = tasks.filter(\.isCompleted).count
        return RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.sm) {
                HStack(alignment: .firstTextBaseline) {
                    Text(completed == tasks.count ? "All done for now" : "One step at a time")
                        .font(RoutineTypography.timelineTitle)
                    Spacer()
                    Text("\(completed) of \(tasks.count)")
                        .font(RoutineTypography.small)
                        .foregroundStyle(RoutineColors.secondaryText)
                }
                RoutineProgressBar(progress: Double(completed) / Double(tasks.count))
                Text(completed == tasks.count
                     ? "You followed through. Add another task whenever you’re ready."
                     : "Your next task is \(tasks.first(where: { !$0.isCompleted })?.title ?? "ready when you are").")
                    .font(RoutineTypography.smallRegular)
                    .foregroundStyle(RoutineColors.secondaryText)
            }
        }
    }

    private var taskList: some View {
        VStack(spacing: 0) {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                RoutineTaskRow(task: task) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onToggleTask(task)
                    }
                }
                if index < tasks.count - 1 {
                    Divider().overlay(RoutineColors.border)
                }
            }
        }
        .padding(.horizontal, RoutineSpacing.md)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Home") {
    @Previewable @State var tab: AppTab = .home
    HomeView(
        selectedTab: $tab,
        tasks: [RoutineTask(title: "Morning walk")],
        onToggleTask: { _ in },
        onAddTask: {}
    )
}
