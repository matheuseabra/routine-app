import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case habits = "Habits"
    case add = "Add"
    case insights = "Insights"
    case profile = "Profile"

    var id: Self { self }

    var icon: RoutineIconName {
        switch self {
        case .home: .house
        case .habits: .chartBar
        case .add: .plus
        case .insights: .chartLineUp
        case .profile: .user
        }
    }
}

enum Plan: String, CaseIterable {
    case weekly
    case yearly

    var displayName: String {
        rawValue.capitalized
    }

    var price: String {
        switch self {
        case .weekly: "$9.99 / week"
        case .yearly: "$59.99 / year"
        }
    }
}

struct RoutineTask: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

extension RoutineTask {
    static let previewTasks = [
        RoutineTask(title: "Morning walk", isCompleted: true),
        RoutineTask(title: "Drink water", isCompleted: true),
        RoutineTask(title: "Read for 20 minutes", isCompleted: false),
        RoutineTask(title: "Plan tomorrow", isCompleted: false)
    ]
}
