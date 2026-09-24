import CoreText
import SwiftData
import SwiftUI

@main
struct RoutineApp: App {
    @State private var services = AppServices()
    private let modelContainer: ModelContainer

    init() {
        Self.registerFonts()
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

    private static func registerFonts() {
        ["Geist-Regular", "Geist-Medium", "Geist-Bold"].forEach { fontName in
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
}
