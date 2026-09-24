import SwiftData
import SwiftUI

@main
struct RoutineApp: App {
    @State private var services = AppServices()
    private let modelContainer: ModelContainer

    init() {
        RevenueCatBootstrap.configureIfNeeded()

        let isDemoMode = ProcessInfo.processInfo.arguments.contains("-demo-data")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isDemoMode)
        do {
            modelContainer = try ModelContainer(
                for: RoutineTask.self,
                RoutineHabit.self,
                RoutineCheckIn.self,
                configurations: configuration
            )
        } catch {
            fatalError("Unable to create the Routine model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RoutineRootView()
                .environment(services)
                .environment(\.font, RoutineTypography.body)
        }
        .modelContainer(modelContainer)
    }

}
