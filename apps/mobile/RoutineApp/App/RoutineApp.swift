import SwiftData
import SwiftUI

@main
struct RoutineApp: App {
    @State private var services = AppServices()
    private let modelContainer: ModelContainer

    init() {
        if !E2ETestConfiguration.isEnabled {
            RevenueCatBootstrap.configureIfNeeded()
        }

        let arguments = ProcessInfo.processInfo.arguments
        let usesTemporaryStore = E2ETestConfiguration.isEnabled || arguments.contains("-demo-data") || arguments.contains("-empty-data")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: usesTemporaryStore)
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
