import SwiftUI

struct PaywallView: View {
    @Environment(AppServices.self) private var services

    @State private var plans = StarterDemoData.subscriptionPlans
    @State private var selectedPlanID = StarterDemoData.subscriptionPlans.first?.id
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    let onContinue: () -> Void

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center) {
            VStack(spacing: 0) {
                HStack(spacing: RoutineSpacing.xs) {
                    RoutineLogo(size: .small)
                        .frame(width: 34, height: 34)
                    Text("\(AppConfig.displayName) Pro")
                        .font(RoutineTypography.appName)
                }
                .accessibilityElement(children: .combine)
                .frame(height: 48)
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, RoutineSpacing.md)

                Text("Invest in better habits.")
                    .routineTitleStyle()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.xs)

                Text("Unlock the full experience with \(AppConfig.displayName) Pro.")
                    .routineSubtitleStyle()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.xxl)

                benefits
            }
            .padding(.top, RoutineSpacing.xxl)
        } bottom: {
            VStack(spacing: RoutineSpacing.xs) {
                pricingCards

                if let errorMessage {
                    Text(errorMessage)
                        .font(RoutineTypography.smallRegular)
                        .foregroundStyle(RoutineColors.secondaryText)
                        .multilineTextAlignment(.center)
                }

                Text("No commitment, cancel anytime")
                    .routineSubtitleStyle()
                    .multilineTextAlignment(.center)
                    .padding(.vertical, RoutineSpacing.xs)

                RoutinePrimaryButton(title: isPurchasing ? "Processing..." : "Start free trial") {
                    purchaseSelectedPlan()
                }
                .disabled(isPurchasing || selectedPlanID == nil)

                Button("Restore purchases") {
                    Task {
                        do {
                            if try await services.subscriptions.restore() {
                                onContinue()
                            } else {
                                errorMessage = "No active subscription was found to restore."
                            }
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .font(RoutineTypography.small)
                .foregroundStyle(RoutineColors.secondaryText)
            }
            .padding(.top, RoutineSpacing.xl)
        }
        .task {
            do {
                let loadedPlans = try await services.subscriptions.plans()
                guard !loadedPlans.isEmpty else { return }
                plans = loadedPlans
                if !loadedPlans.contains(where: { $0.id == selectedPlanID }) {
                    selectedPlanID = loadedPlans.first?.id
                }
            } catch {
                errorMessage = "Plans could not be refreshed. Demo pricing is shown."
            }
        }
    }

    private var benefits: some View {
        RoutineTimeline(steps: [
            RoutineTimelineStep(
                icon: .check,
                title: "Unlimited habits",
                subtitle: "Track everything that matters."
            ),
            RoutineTimelineStep(
                icon: .chartLineUp,
                title: "Advanced insights",
                subtitle: "See detailed progress and trends."
            ),
            RoutineTimelineStep(
                icon: .bell,
                title: "Custom reminders",
                subtitle: "Never miss a day."
            )
        ])
        .frame(maxWidth: 360, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var pricingCards: some View {
        VStack(spacing: RoutineSpacing.xs) {
            ForEach(plans) { plan in
                RoutinePricingCard(plan: plan, isSelected: selectedPlanID == plan.id) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPlanID = plan.id
                    }
                }
            }
        }
    }

    private func purchaseSelectedPlan() {
        guard let selectedPlanID else { return }

        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                let purchased = try await services.subscriptions.purchase(planID: selectedPlanID)
                isPurchasing = false

                if purchased {
                    services.analytics.track("subscription_purchased", properties: [
                        "product_id": selectedPlanID
                    ])
                    onContinue()
                }
            } catch {
                isPurchasing = false
                errorMessage = "Purchase could not be completed. Please try again."
            }
        }
    }
}

#Preview("Paywall") {
    PaywallView {}
        .environment(AppServices())
}
