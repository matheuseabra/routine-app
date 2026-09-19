import Foundation
import StoreKit

struct SubscriptionPlan: Identifiable, Equatable {
    let id: String
    let displayName: String
    let displayPrice: String
    let period: String
    let hasTrial: Bool

    var priceDescription: String {
        "\(displayPrice) / \(period)"
    }
}

protocol SubscriptionProviding {
    func plans() async throws -> [SubscriptionPlan]
    func purchase(planID: String) async throws -> Bool
    func restore() async throws
    func hasActiveEntitlement() async -> Bool
}

struct StoreKitSubscriptionProvider: SubscriptionProviding {
    private let productIDs: [String]

    init(productIDs: [String] = AppConfig.StoreKit.productIDs) {
        self.productIDs = productIDs
    }

    func plans() async throws -> [SubscriptionPlan] {
        let products = try await Product.products(for: productIDs)
        guard !products.isEmpty else {
            return Self.demoPlans
        }

        return products.compactMap { product in
            guard let subscription = product.subscription else { return nil }
            return SubscriptionPlan(
                id: product.id,
                displayName: product.displayName,
                displayPrice: product.displayPrice,
                period: Self.periodDescription(subscription.subscriptionPeriod),
                hasTrial: subscription.introductoryOffer?.paymentMode == .freeTrial
            )
        }
        .sorted { $0.displayPrice < $1.displayPrice }
    }

    func purchase(planID: String) async throws -> Bool {
        guard let product = try await Product.products(for: [planID]).first else { return false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else { return false }
            await transaction.finish()
            return true
        case .pending, .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async throws {
        try await AppStore.sync()
    }

    func hasActiveEntitlement() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               productIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }

    static let demoPlans = [
        SubscriptionPlan(id: "routine.weekly", displayName: "Weekly", displayPrice: "$9.99", period: "week", hasTrial: true),
        SubscriptionPlan(id: "routine.yearly", displayName: "Yearly", displayPrice: "$59.99", period: "year", hasTrial: true)
    ]

    private static func periodDescription(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day: return period.value == 1 ? "day" : "\(period.value) days"
        case .week: return period.value == 1 ? "week" : "\(period.value) weeks"
        case .month: return period.value == 1 ? "month" : "\(period.value) months"
        case .year: return period.value == 1 ? "year" : "\(period.value) years"
        @unknown default: return "period"
        }
    }
}
