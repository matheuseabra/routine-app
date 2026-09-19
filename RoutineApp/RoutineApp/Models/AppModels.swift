import Foundation
import SwiftData

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

@Model
final class RoutineTask: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = .now,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}

@Model
final class RoutineHabit: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = .now,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.isArchived = isArchived
    }
}

@Model
final class RoutineCheckIn: Identifiable {
    @Attribute(.unique) var id: UUID
    var taskID: UUID
    var completedAt: Date

    init(
        id: UUID = UUID(),
        taskID: UUID,
        completedAt: Date = .now
    ) {
        self.id = id
        self.taskID = taskID
        self.completedAt = completedAt
    }
}

struct InsightSummary {
    let currentStreak: Int
    let consistency: Int
    let completedCount: Int

    static func make(checkIns: [RoutineCheckIn], calendar: Calendar = .current) -> InsightSummary {
        let days = Set(checkIns.map { calendar.startOfDay(for: $0.completedAt) })
        let sortedDays = days.sorted(by: >)

        var streak = 0
        var cursor = calendar.startOfDay(for: .now)
        if !days.contains(cursor), let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) {
            cursor = yesterday
        }

        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        let lastSevenStart = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .distantPast
        let activeDays = sortedDays.filter { $0 >= lastSevenStart }.count
        let consistency = Int((Double(activeDays) / 7.0 * 100.0).rounded())

        return InsightSummary(
            currentStreak: streak,
            consistency: consistency,
            completedCount: checkIns.count
        )
    }
}
