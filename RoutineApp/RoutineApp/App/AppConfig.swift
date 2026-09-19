import Foundation

enum AppConfig {
    static var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Routine"
    }

    static let termsURL = URL(string: "https://example.com/terms")!
    static let privacyURL = URL(string: "https://example.com/privacy")!
    static let supportURL = URL(string: "https://example.com/support")!

    enum StoreKit {
        static let weeklyProductID = "routine.weekly"
        static let yearlyProductID = "routine.yearly"
        static let productIDs = [weeklyProductID, yearlyProductID]
    }
}
