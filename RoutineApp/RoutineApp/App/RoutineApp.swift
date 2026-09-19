import CoreText
import SwiftUI

@main
struct RoutineApp: App {
    init() {
        Self.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            RoutineRootView()
                .environment(\.font, RoutineTypography.body)
        }
    }

    private static func registerFonts() {
        ["Geist-Regular", "Geist-Medium", "Geist-Bold"].forEach { fontName in
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
}
