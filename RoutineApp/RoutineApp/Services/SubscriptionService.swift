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
    func purchase(planID: String) async throws -> Bool
    func restore() async throws
    func hasActiveEntitlement() async -> Bool
}

enum SubscriptionError: LocalizedError {
    case revenueCatNotConfigured
    case noCurrentOffering
    case packageNotFound

    var errorDescription: String? {
        switch self {
        case .revenueCatNotConfigured:
            "RevenueCat is not configured. Add REVENUECAT_API_KEY to Config/Local.xcconfig."
        case .noCurrentOffering:
            "RevenueCat has no current Offering configured."
        case .packageNotFound:
            "The selected RevenueCat Package is no longer available."
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
    func plans() async throws -> [SubscriptionPlan] {
        guard AppConfig.revenueCatAPIKey != nil else {
            return Self.demoPlans
        }

        let offering = try await currentOffering()
        return offering.availablePackages.map(Self.plan(from:))
    }

    func purchase(planID: String) async throws -> Bool {
        try requireConfiguration()

        let offering = try await currentOffering()
        guard let package = offering.availablePackages.first(where: { $0.identifier == planID }) else {
            throw SubscriptionError.packageNotFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.purchase(package: package) { _, customerInfo, error, userCancelled in
                if userCancelled {
                    continuation.resume(returning: false)
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let isActive = customerInfo?.entitlements
                    .all[AppConfig.revenueCatEntitlementID]?
                    .isActive == true

                continuation.resume(returning: isActive)
            }
        }
    }

    func restore() async throws {
        try requireConfiguration()

        _ = try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.restorePurchases { customerInfo, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let customerInfo {
                    continuation.resume(returning: customerInfo)
                } else {
                    continuation.resume(throwing: SubscriptionError.revenueCatNotConfigured)
                }
            }
        } as CustomerInfo
    }

    func hasActiveEntitlement() async -> Bool {
        guard AppConfig.revenueCatAPIKey != nil else { return false }

        return await withCheckedContinuation { continuation in
            Purchases.shared.getCustomerInfo { customerInfo, _ in
                let isActive = customerInfo?.entitlements
                    .all[AppConfig.revenueCatEntitlementID]?
                    .isActive == true
                continuation.resume(returning: isActive)
            }
        }
    }

    static let demoPlans = [
        SubscriptionPlan(id: "$rc_weekly", displayName: "Weekly", displayPrice: "$9.99", period: "week", hasTrial: true),
        SubscriptionPlan(id: "$rc_annual", displayName: "Yearly", displayPrice: "$59.99", period: "year", hasTrial: true)
    ]

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
        guard AppConfig.revenueCatAPIKey != nil else {
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
