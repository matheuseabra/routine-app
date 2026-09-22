import Foundation
import RevenueCat

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
    func purchase(planID: String) async throws -> PurchaseOutcome
    func restore() async throws -> Bool
    func hasActiveEntitlement() async -> Bool
}

enum PurchaseOutcome: Equatable {
    case purchased
    case cancelled
}

enum PurchaseOutcomeResolver {
    static func resolve(
        userCancelled: Bool,
        purchaseError: Error? = nil,
        expectedEntitlementID: String,
        activeEntitlementIDs: [String]
    ) throws -> PurchaseOutcome {
        if userCancelled { return .cancelled }
        if let purchaseError { throw purchaseError }
        guard activeEntitlementIDs.contains(expectedEntitlementID) else {
            throw SubscriptionError.entitlementNotActivated(
                expected: expectedEntitlementID,
                active: activeEntitlementIDs.sorted()
            )
        }

        return .purchased
    }
}

enum SubscriptionError: LocalizedError, Equatable {
    case revenueCatNotConfigured
    case noCurrentOffering
    case packageNotFound
    case entitlementNotActivated(expected: String, active: [String])

    var errorDescription: String? {
        switch self {
        case .revenueCatNotConfigured:
            #if DEBUG
            return "RevenueCat is not configured. Add the Debug SDK key to Config/Local.xcconfig. For Test Store, use a test_ SDK key."
            #else
            return "Subscriptions are not available right now. Please try again later."
            #endif
        case .noCurrentOffering:
            return "RevenueCat has no current Offering configured."
        case .packageNotFound:
            return "The selected RevenueCat Package is no longer available."
        case let .entitlementNotActivated(expected, active):
            #if DEBUG
            let activeList = active.isEmpty ? "none" : active.joined(separator: ", ")
            return "The purchase completed, but RevenueCat did not activate entitlement '\(expected)' (active: \(activeList)). Check that this product is attached to that exact entitlement ID in RevenueCat and matches REVENUECAT_ENTITLEMENT_ID in Config/Local.xcconfig."
            #else
            return "Your purchase completed, but your subscription could not be activated. Restore purchases or contact support."
            #endif
        }
    }
}

enum RevenueCatBootstrap {
    static func configureIfNeeded() {
        guard let apiKey = AppConfig.revenueCatAPIKey else { return }

        #if DEBUG
        Purchases.logLevel = .debug
        #endif

        Purchases.configure(withAPIKey: apiKey)
    }
}

struct RevenueCatSubscriptionProvider: SubscriptionProviding {
    private let apiKey: String?

    init(apiKey: String? = AppConfig.revenueCatAPIKey) {
        self.apiKey = apiKey
    }

    func plans() async throws -> [SubscriptionPlan] {
        let offering = try await currentOffering()
        return offering.availablePackages.map(Self.plan(from:))
    }

    func purchase(planID: String) async throws -> PurchaseOutcome {
        try requireConfiguration()

        let offering = try await currentOffering()
        guard let package = offering.availablePackages.first(where: { $0.identifier == planID }) else {
            throw SubscriptionError.packageNotFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.purchase(package: package) { _, customerInfo, error, userCancelled in
                let activeEntitlementIDs = customerInfo?.entitlements.all
                    .filter { $0.value.isActive }
                    .map(\.key)
                    .sorted() ?? []

                #if DEBUG
                if userCancelled {
                    print("[RevenueCat] Purchase cancelled for package \(planID).")
                } else if let error {
                    let code = (error as NSError).code
                    print("[RevenueCat] Purchase failed for package \(planID) with error code \(code).")
                } else {
                    print("[RevenueCat] Purchase result for package \(planID); expected entitlement '\(AppConfig.revenueCatEntitlementID)', active entitlements: \(activeEntitlementIDs).")
                }
                #endif

                do {
                    let outcome = try PurchaseOutcomeResolver.resolve(
                        userCancelled: userCancelled,
                        purchaseError: error,
                        expectedEntitlementID: AppConfig.revenueCatEntitlementID,
                        activeEntitlementIDs: activeEntitlementIDs
                    )
                    continuation.resume(returning: outcome)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func restore() async throws -> Bool {
        try requireConfiguration()

        let customerInfo: CustomerInfo = try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.restorePurchases { customerInfo, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let customerInfo {
                    continuation.resume(returning: customerInfo)
                } else {
                    continuation.resume(throwing: SubscriptionError.revenueCatNotConfigured)
                }
            }
        }

        return customerInfo.entitlements
            .all[AppConfig.revenueCatEntitlementID]?
            .isActive == true
    }

    func hasActiveEntitlement() async -> Bool {
        guard apiKey != nil else { return false }

        return await withCheckedContinuation { continuation in
            Purchases.shared.getCustomerInfo { customerInfo, _ in
                let isActive = customerInfo?.entitlements
                    .all[AppConfig.revenueCatEntitlementID]?
                    .isActive == true
                continuation.resume(returning: isActive)
            }
        }
    }

    private func currentOffering() async throws -> Offering {
        try requireConfiguration()

        return try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.getOfferings { offerings, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let offering = offerings?.current {
                    continuation.resume(returning: offering)
                } else {
                    continuation.resume(throwing: SubscriptionError.noCurrentOffering)
                }
            }
        }
    }

    private func requireConfiguration() throws {
        guard apiKey != nil else {
            throw SubscriptionError.revenueCatNotConfigured
        }
    }

    private static func plan(from package: Package) -> SubscriptionPlan {
        let product = package.storeProduct
        return SubscriptionPlan(
            id: package.identifier,
            displayName: product.localizedTitle.isEmpty
                ? displayName(for: package)
                : product.localizedTitle,
            displayPrice: product.localizedPriceString,
            period: periodDescription(product.subscriptionPeriod),
            hasTrial: product.introductoryDiscount?.paymentMode == .freeTrial
        )
    }

    private static func displayName(for package: Package) -> String {
        switch package.packageType {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .twoMonth: "2 Months"
        case .threeMonth: "3 Months"
        case .sixMonth: "6 Months"
        case .annual: "Yearly"
        case .lifetime: "Lifetime"
        default: "Premium"
        }
    }

    private static func periodDescription(_ period: RevenueCat.SubscriptionPeriod?) -> String {
        guard let period else { return "purchase" }

        let unit: String
        switch period.unit {
        case .day: unit = "day"
        case .week: unit = "week"
        case .month: unit = "month"
        case .year: unit = "year"
        @unknown default: unit = "period"
        }

        return period.value == 1 ? unit : "\(period.value) \(unit)s"
    }
}
