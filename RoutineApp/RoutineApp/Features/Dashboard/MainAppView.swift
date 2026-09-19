import SwiftData
import SwiftUI

struct MainAppView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RoutineTask.createdAt) private var tasks: [RoutineTask]
    @Query(sort: \RoutineCheckIn.completedAt, order: .reverse) private var checkIns: [RoutineCheckIn]

    @State private var selectedTab: AppTab
    @State private var isAddTaskPresented = false

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
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
            case .home:
                HomeView(selectedTab: $selectedTab, tasks: tasks, onToggleTask: toggleTask)
            case .profile:
                ProfileView(tasks: tasks, checkIns: checkIns)
            case .habits:
                HabitsView {
                    isAddTaskPresented = true
                }
            case .insights:
                InsightsView(checkIns: checkIns)
            case .add:
                HomeView(selectedTab: $selectedTab, tasks: tasks, onToggleTask: toggleTask)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            RoutineNavigationBar(selectedTab: $selectedTab) {
                isAddTaskPresented = true
            }
        }
        .background(RoutineColors.background.ignoresSafeArea())
        .sheet(isPresented: $isAddTaskPresented) {
            AddTaskSheet { title in
                modelContext.insert(RoutineTask(title: title))
                try? modelContext.save()
            }
            .presentationBackground(RoutineColors.surface)
        }
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
