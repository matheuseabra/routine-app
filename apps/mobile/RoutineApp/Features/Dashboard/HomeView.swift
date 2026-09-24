import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    let tasks: [RoutineTask]
    let onToggleTask: (RoutineTask) -> Void
    let onAddTask: () -> Void
    @State private var searchHapticTrigger = 0
    @State private var isSearchPresented = false

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
                    if !activeTasks.isEmpty {
                        RoutineSectionHeader(title: "Your tasks")
                            .padding(.bottom, RoutineSpacing.sm)
                        taskList
                    }
                }
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.huge)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
        .sheet(isPresented: $isSearchPresented) {
            TaskSearchSheet(tasks: tasks)
                .presentationBackground(RoutineColors.surface)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        RoutinePageHeader(
            title: "Today"
        ) {
            Button {
                searchHapticTrigger += 1
                isSearchPresented = true
            } label: {
                RoutineIcon(.magnifyingGlass)
                    .frame(width: 21, height: 21)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: searchHapticTrigger)
            .accessibilityLabel("Search tasks")
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

    private var activeTasks: [RoutineTask] {
        tasks.filter { !$0.isCompleted }
    }

    private var taskList: some View {
        VStack(spacing: 0) {
            ForEach(Array(activeTasks.enumerated()), id: \.element.id) { index, task in
                RoutineTaskRow(task: task) {
                    onToggleTask(task)
                }
                if index < activeTasks.count - 1 {
                    Divider().overlay(RoutineColors.border)
                }
            }
        }
        .padding(.horizontal, RoutineSpacing.md)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct TaskSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    let tasks: [RoutineTask]
    @State private var query = ""

    private var filteredTasks: [RoutineTask] {
        guard !query.isEmpty else { return tasks }
        return tasks.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filteredTasks) { task in
                HStack(spacing: RoutineSpacing.md) {
                    RoutineIcon(task.isCompleted ? .check : .clipboardText)
                        .frame(width: 22, height: 22)
                    Text(task.title)
                        .font(RoutineTypography.body)
                        .foregroundStyle(RoutineColors.primaryText)
                }
                .listRowBackground(RoutineColors.surface)
            }
            .overlay {
                if filteredTasks.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .scrollContentBackground(.hidden)
            .background(RoutineColors.surface)
            .searchable(text: $query, prompt: "Search tasks")
            .navigationTitle("Search tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(RoutineColors.primaryText)
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
