import SwiftUI

struct MainAppView: View {
    @State private var selectedTab: AppTab
    @State private var tasks: [RoutineTask] = []
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
                HomeView(selectedTab: $selectedTab, tasks: $tasks)
            case .profile:
                ProfileView(tasks: tasks)
            case .habits:
                HabitsView {
                    isAddTaskPresented = true
                }
            case .insights:
                InsightsView()
            case .add:
                HomeView(selectedTab: $selectedTab, tasks: $tasks)
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
                tasks.append(RoutineTask(title: title, isCompleted: false))
            }
            .presentationBackground(RoutineColors.surface)
        }
    }

}
