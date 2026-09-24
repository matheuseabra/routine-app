import SwiftUI

struct HomeView: View {
    let tasks: [RoutineTask]
    let onToggleTask: (RoutineTask) -> Void
    let onEditTask: (RoutineTask) -> Void
    let onDeleteTask: (RoutineTask) -> Void
    @Binding var isSearchPresented: Bool
    @State private var searchHapticTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, RoutineSpacing.lg)
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, tasks.isEmpty ? 0 : RoutineSpacing.xl)

            if tasks.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    taskList
                    .padding(.horizontal, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.huge)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoutineColors.background)
        .sheet(isPresented: $isSearchPresented) {
            TaskSearchSheet(tasks: tasks)
                .presentationBackground(RoutineColors.surface)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.md) {
            HStack {
                RoutineLogo(size: .small)
                Spacer()
                Button {
                    searchHapticTrigger += 1
                    isSearchPresented = true
                } label: {
                    RoutineIcon(.magnifyingGlass)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: searchHapticTrigger)
                .accessibilityLabel("Search tasks")
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(alignment: .center, spacing: RoutineSpacing.md) {
            RoutineIcon(.clipboardText, color: RoutineColors.secondaryText, pointSize: 34)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)

            Text("Start with one small step")
                .font(RoutineTypography.bodyMedium)
                .foregroundStyle(RoutineColors.primaryText)
                .multilineTextAlignment(.center)

            Text("Small steps make a routine easier to keep.")
                .font(RoutineTypography.secondary)
                .foregroundStyle(RoutineColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var taskList: some View {
        VStack(spacing: 0) {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                RoutineTaskRow(
                    task: task,
                    onEdit: { onEditTask(task) },
                    onDelete: { onDeleteTask(task) }
                ) { onToggleTask(task) }
                if index < tasks.count - 1 {
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
        guard hasQuery else { return [] }
        return tasks.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private var hasQuery: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                if !hasQuery {
                    ContentUnavailableView(
                        "Find a task",
                        systemImage: "magnifyingglass",
                        description: Text("Type a task name to find it.")
                    )
                } else if filteredTasks.isEmpty {
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
    @Previewable @State var isSearchPresented = false
    HomeView(
        tasks: [RoutineTask(title: "Morning walk")],
        onToggleTask: { _ in },
        onEditTask: { _ in },
        onDeleteTask: { _ in },
        isSearchPresented: $isSearchPresented
    )
}
