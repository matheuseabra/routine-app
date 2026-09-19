import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @Binding var tasks: [RoutineTask]
    @State private var removingTaskIDs: Set<UUID> = []
    @State private var insightsHapticTrigger = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.xl)
                RoutineSectionHeader(title: "TODAY'S PLAN")
                    .padding(.bottom, RoutineSpacing.sm)
                if visibleTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
    }

    private var header: some View {
        RoutinePageHeader(
            title: "Today",
            subtitle: "A simple plan for your day."
        ) {
            Button {
                insightsHapticTrigger += 1
                withAnimation(.easeInOut(duration: 0.18)) {
                    selectedTab = .insights
                }
            } label: {
                RoutineIcon(.magnifyingGlass, weight: .bold)
                    .frame(width: 21, height: 21)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: insightsHapticTrigger)
            .accessibilityLabel("Insights")
        }
    }

    private var emptyState: some View {
        VStack(spacing: RoutineSpacing.md) {
            ZStack {
                Circle()
                    .fill(RoutineColors.track)
                RoutineIcon(.clipboardText, color: RoutineColors.secondaryText)
                    .frame(width: 30, height: 30)
            }
            .frame(width: 64, height: 64)
            Text("Nothing planned yet")
                .font(RoutineTypography.compactTitle)
                .multilineTextAlignment(.center)
            Text("Add a task to start building your routine.")
                .routineSubtitleStyle()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RoutineSpacing.xxl)
        .padding(.horizontal, RoutineSpacing.lg)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private var taskList: some View {
        VStack(spacing: 0) {
            ForEach(Array(visibleTasks.enumerated()), id: \.element.id) { index, task in
                RoutineTaskRow(task: task) {
                    toggleTask(task)
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
                if index < visibleTasks.count - 1 {
                    Divider().overlay(RoutineColors.border)
                }
            }
        }
        .padding(.horizontal, RoutineSpacing.md)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var visibleTasks: [RoutineTask] {
        tasks.filter { !removingTaskIDs.contains($0.id) }
    }

    private func toggleTask(_ task: RoutineTask) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if task.isCompleted {
            withAnimation(.easeInOut(duration: 0.2)) {
                tasks[taskIndex].isCompleted = false
            }
            return
        }

        _ = withAnimation(.easeOut(duration: 0.24)) {
            removingTaskIDs.insert(task.id)
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(240))
            withAnimation(.easeInOut(duration: 0.2)) {
                tasks.removeAll { $0.id == task.id }
                removingTaskIDs.remove(task.id)
            }
        }
    }
}

#Preview("Home") {
    @Previewable @State var tab: AppTab = .home
    @Previewable @State var tasks: [RoutineTask] = []
    HomeView(selectedTab: $tab, tasks: $tasks)
}
