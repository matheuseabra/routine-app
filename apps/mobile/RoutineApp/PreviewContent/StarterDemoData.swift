import Foundation

enum StarterDemoData {
    static let subscriptionPlans = [
        SubscriptionPlan(
            id: "$rc_weekly",
            displayName: "Weekly",
            displayPrice: "$9.99",
            period: "week",
            hasTrial: true
        ),
        SubscriptionPlan(
            id: "$rc_annual",
            displayName: "Yearly",
            displayPrice: "$59.99",
            period: "year",
            hasTrial: true
        )
    ]
}
