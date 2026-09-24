import Foundation
import SwiftData

enum DemoDataSeeder {
    static func seedIfRequested(
        arguments: [String],
        modelContext: ModelContext,
        calendar: Calendar = .current
    ) {
        guard arguments.contains("-demo-data") else { return }

        do {
            try removeExistingData(from: modelContext)

            let startOfToday = calendar.startOfDay(for: .now)
            let tasks = makeTasks(calendar: calendar, startOfToday: startOfToday)
            tasks.forEach(modelContext.insert)

            let completedTaskCounts = [3, 2, 3, 1, 2, 2, 1]
            for (dayOffset, taskCount) in completedTaskCounts.enumerated() {
                guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: startOfToday) else {
                    continue
                }

                for task in tasks.prefix(taskCount) {
                    let completedAt = calendar.date(byAdding: .hour, value: 9, to: day) ?? day
                    modelContext.insert(RoutineCheckIn(taskID: task.id, completedAt: completedAt))
                }
            }

            try modelContext.save()
        } catch {
            assertionFailure("Unable to seed demo data: \(error)")
        }
    }

    private static func makeTasks(calendar: Calendar, startOfToday: Date) -> [RoutineTask] {
        let taskDefinitions = [
            ("Morning walk", -3, true),
            ("Read 10 pages", -2, true),
            ("Drink 2L of water", -1, true),
            ("Stretch before bed", 0, false)
        ]

        return taskDefinitions.map { title, hourOffset, isCompleted in
            let createdAt = calendar.date(byAdding: .hour, value: hourOffset, to: startOfToday) ?? startOfToday
            return RoutineTask(title: title, createdAt: createdAt, isCompleted: isCompleted)
        }
    }

    private static func removeExistingData(from modelContext: ModelContext) throws {
        try modelContext.fetch(FetchDescriptor<RoutineCheckIn>()).forEach(modelContext.delete)
        try modelContext.fetch(FetchDescriptor<RoutineTask>()).forEach(modelContext.delete)
        try modelContext.fetch(FetchDescriptor<RoutineHabit>()).forEach(modelContext.delete)
    }
}
