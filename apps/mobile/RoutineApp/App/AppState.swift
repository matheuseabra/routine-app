import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    private enum Keys {
        static let hasCompletedOnboarding = "routine.hasCompletedOnboarding"
        static let userName = "routine.userName"
    }

    private let defaults: UserDefaults

    private(set) var hasCompletedOnboarding: Bool {
        didSet {
            defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }

    private(set) var userName: String {
        didSet { defaults.set(userName, forKey: Keys.userName) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        userName = defaults.string(forKey: Keys.userName) ?? ""
    }

    func completeOnboarding(userName: String? = nil) {
        if let userName {
            let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedName.isEmpty { self.userName = trimmedName }
        }
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}
