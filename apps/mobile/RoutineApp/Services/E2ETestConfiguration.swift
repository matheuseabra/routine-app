import Foundation

// Test behavior is compiled out of Release builds and requires an explicit launch flag.
enum E2ETestConfiguration {
    static var isEnabled: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("-e2e")
        #else
        false
        #endif
    }

    static var defaults: UserDefaults {
        guard isEnabled else { return .standard }
        let suiteName = "routine.e2e"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

#if DEBUG
@MainActor
final class E2ESubscriptionProvider: SubscriptionProviding {
    private var isActive = false

    func plans() async throws -> [SubscriptionPlan] {
        StarterDemoData.subscriptionPlans
    }

    func purchase(planID: String) async throws -> PurchaseOutcome {
        guard StarterDemoData.subscriptionPlans.contains(where: { $0.id == planID }) else {
            throw SubscriptionError.packageNotFound
        }
        isActive = true
        return .purchased
    }

    func restore() async throws -> Bool { isActive }
    func hasActiveEntitlement() async -> Bool { isActive }
}
#endif
