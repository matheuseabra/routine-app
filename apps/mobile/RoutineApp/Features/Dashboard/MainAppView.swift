import SwiftData
import SwiftUI

struct MainAppView: View {
    let userName: String
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \RoutineTask.createdAt) private var tasks: [RoutineTask]
    @Query(sort: \RoutineCheckIn.completedAt, order: .reverse) private var checkIns: [RoutineCheckIn]

    @State private var selectedTab: AppTab
    @State private var isTaskEditorPresented = false
    @State private var taskToEdit: RoutineTask?
    @State private var taskToDelete: RoutineTask?
    @State private var isDeleteConfirmationPresented = false
    @State private var isSearchPresented = false
    @State private var deleteHapticTrigger = 0

    init(userName: String = "", arguments: [String] = ProcessInfo.processInfo.arguments) {
        self.userName = userName
        if let tabIndex = arguments.firstIndex(of: "-tab"),
           arguments.indices.contains(tabIndex + 1),
           let requestedTab = AppTab(rawValue: arguments[tabIndex + 1].capitalized) {
            _selectedTab = State(initialValue: requestedTab)
        } else {
            _selectedTab = State(initialValue: .home)
        }
    }

    var body: some View {
        Group {
            switch selectedTab {
            case .home, .add:
                taskListView
            case .habits:
                HabitsView(
                    tasks: tasks,
                    onToggleTask: toggleTask,
                    onEditTask: editTask,
                    onDeleteTask: confirmDeleteTask
                )
            case .profile:
                ProfileView(
                    userName: userName,
                    tasks: tasks,
                    checkIns: checkIns
                )
            case .insights:
                InsightsView(checkIns: checkIns)
            }
        }
        .id(selectedTab)
        .transition(reduceMotion ? .identity : .opacity)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.14), value: selectedTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            RoutineNavigationBar(
                selectedTab: $selectedTab,
                onAdd: presentNewTask
            )
        }
        .background(RoutineColors.background.ignoresSafeArea())
        .task {
            DemoDataSeeder.seedIfRequested(
                arguments: ProcessInfo.processInfo.arguments,
                modelContext: modelContext
            )
        }
        .sheet(isPresented: $isTaskEditorPresented, onDismiss: { taskToEdit = nil }) {
            AddTaskSheet(initialTitle: taskToEdit?.title ?? "", isEditing: taskToEdit != nil) { title in
                if let taskToEdit {
                    taskToEdit.title = title
                } else {
                    modelContext.insert(RoutineTask(title: title))
                }
                try? modelContext.save()
            }
            .presentationBackground(RoutineColors.surface)
        }
        .confirmationDialog(
            "Delete task?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete task", role: .destructive, action: deleteTask)
            Button("Cancel", role: .cancel) { taskToDelete = nil }
        } message: {
            Text("\(taskToDelete?.title ?? "This task") will be removed from your routine.")
        }
        .sensoryFeedback(.warning, trigger: deleteHapticTrigger)
    }

    private var taskListView: some View {
        HomeView(
            tasks: tasks,
            onToggleTask: toggleTask,
            onEditTask: editTask,
            onDeleteTask: confirmDeleteTask,
            isSearchPresented: $isSearchPresented
        )
    }

    private func presentNewTask() {
        taskToEdit = nil
        isTaskEditorPresented = true
    }

    private func editTask(_ task: RoutineTask) {
        taskToEdit = task
        isTaskEditorPresented = true
    }

    private func confirmDeleteTask(_ task: RoutineTask) {
        taskToDelete = task
        isDeleteConfirmationPresented = true
    }

    private func deleteTask() {
        guard let taskToDelete else { return }
        deleteHapticTrigger += 1
        for checkIn in checkIns where checkIn.taskID == taskToDelete.id {
            modelContext.delete(checkIn)
        }
        modelContext.delete(taskToDelete)
        try? modelContext.save()
        self.taskToDelete = nil
    }

    private func toggleTask(_ task: RoutineTask) {
        if task.isCompleted {
            task.isCompleted = false
            if let checkIn = checkIns.first(where: { $0.taskID == task.id }) {
                modelContext.delete(checkIn)
            }
        } else {
            task.isCompleted = true
            modelContext.insert(RoutineCheckIn(taskID: task.id))
        }
        try? modelContext.save()
    }
}
