import Foundation

enum AppConfig {
    static var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Routine"
    }

    static let termsURL = URL(string: "https://example.com/terms")!
    static let privacyURL = URL(string: "https://example.com/privacy")!
    static let supportURL = URL(string: "https://example.com/support")!

    static var authenticationEnabled: Bool {
        if let value = Bundle.main.object(forInfoDictionaryKey: "AUTH_ENABLED") as? NSNumber {
            return value.boolValue
        }

        guard let value = Bundle.main.object(forInfoDictionaryKey: "AUTH_ENABLED") as? String else {
            return false
        }

        return ["YES", "TRUE", "1"].contains(value.uppercased())
    }

    static var revenueCatAPIKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String else {
            return nil
        }

        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static var revenueCatEntitlementID: String {
        let configured = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_ENTITLEMENT_ID") as? String
        let trimmed = configured?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "pro" : trimmed
    }
}
