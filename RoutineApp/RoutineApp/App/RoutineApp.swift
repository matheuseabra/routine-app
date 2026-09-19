import CoreText
import SwiftData
import SwiftUI

@main
struct RoutineApp: App {
    @State private var services = AppServices()

    init() {
        Self.registerFonts()
        RevenueCatBootstrap.configureIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RoutineRootView()
                .environment(services)
                .environment(\.font, RoutineTypography.body)
        }
        .modelContainer(for: [RoutineTask.self, RoutineHabit.self, RoutineCheckIn.self])
    }

    private static func registerFonts() {
        ["Geist-Regular", "Geist-Medium", "Geist-Bold"].forEach { fontName in
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
}
