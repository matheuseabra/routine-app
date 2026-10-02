#if DEBUG
import Testing
@testable import RoutineApp

@MainActor
struct E2ESubscriptionTests {
    @Test func testProviderStartsWithoutAnEntitlement() async throws {
        let provider = E2ESubscriptionProvider()
        #expect(await provider.hasActiveEntitlement() == false)
        #expect(try await provider.restore() == false)
        #expect(try await provider.plans() == StarterDemoData.subscriptionPlans)
    }

    @Test func simulatedPurchaseActivatesTheEntitlement() async throws {
        let provider = E2ESubscriptionProvider()
        let outcome = try await provider.purchase(planID: "$rc_annual")
        #expect(outcome == .purchased)
        #expect(await provider.hasActiveEntitlement())
        #expect(try await provider.restore())
    }

    @Test func unknownPlanCannotActivateTheEntitlement() async throws {
        let provider = E2ESubscriptionProvider()
        await #expect(throws: SubscriptionError.packageNotFound) {
            try await provider.purchase(planID: "unknown-plan")
        }
        #expect(await provider.hasActiveEntitlement() == false)
    }
}
#endif
