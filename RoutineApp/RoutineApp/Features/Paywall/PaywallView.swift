import SwiftUI

struct PaywallView: View {
    @Environment(AppServices.self) private var services

    @State private var plans = StarterDemoData.subscriptionPlans
    @State private var selectedPlanID = StarterDemoData.subscriptionPlans.first(where: { $0.period == "year" })?.id
    @State private var isPurchasing = false
    @State private var isLoadingPlans = true
    @State private var isSubscriptionReady = false
    @State private var errorMessage: String?

    let onContinue: () -> Void

    var body: some View {
        RoutineScreenLayout(contentAlignment: .topLeading, minimumBottomSafeArea: 32) {
            VStack(alignment: .leading, spacing: 0) {
                RoutineFunnelBrandHeader()
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.md)

                Text("Build stronger consistency\nwith your personal plan.")
                    .font(RoutineTypography.funnelTitle)
                    .foregroundStyle(RoutineColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Build stronger consistency with your personal plan.")
                    .padding(.bottom, RoutineSpacing.xxs)

                Text("Unlock the full Routine experience and\ncreate lasting change.")
                    .font(RoutineTypography.funnelSubtitle)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, RoutineSpacing.lg)

                benefits
            }
        } bottom: {
            VStack(spacing: 0) {
                pricingCards
                    .padding(.bottom, RoutineSpacing.xl)

                if let errorMessage {
                    Text(errorMessage)
                        .font(RoutineTypography.funnelCaption)
                        .foregroundStyle(RoutineColors.funnelSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, RoutineSpacing.sm)
                }

                RoutinePrimaryButton(title: purchaseButtonTitle, action: {
                    purchaseSelectedPlan()
                }, visualStyle: .funnel)
                .padding(.bottom, RoutineSpacing.xxs)
                .disabled(isPurchasing || isLoadingPlans || selectedPlanID == nil || !isSubscriptionReady)
                .accessibilityHint(isSubscriptionReady ? "Starts the selected subscription." : "Live purchases are unavailable in this build.")

                Text("No commitment. Cancel anytime.")
                    .font(RoutineTypography.funnelCaption)
                    .foregroundStyle(RoutineColors.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .contextMenu {
                        Button("Restore purchases", systemImage: "arrow.clockwise") {
                            restorePurchases()
                        }
                        .disabled(!isSubscriptionReady || isPurchasing)
                    }
            }
            .padding(.top, RoutineSpacing.md)
        }
        .task {
            defer { isLoadingPlans = false }

            do {
                let loadedPlans = try await services.subscriptions.plans()
                guard !loadedPlans.isEmpty else {
                    errorMessage = "No live subscription plans are available right now."
                    return
                }
                plans = loadedPlans
                if !loadedPlans.contains(where: { $0.id == selectedPlanID }) {
                    selectedPlanID = preferredPlan(in: loadedPlans)?.id ?? loadedPlans.first?.id
                }
                isSubscriptionReady = true
            } catch {
                errorMessage = "Live purchases are unavailable. Demo pricing is shown."
            }
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.sm) {
            benefitRow(icon: "person", title: "Your personal plan", subtitle: "Tailored to your goals and routine.")
            benefitRow(icon: "chart.bar", title: "Progress insights", subtitle: "See your progress over time.")
            benefitRow(icon: "bell", title: "Smart reminders", subtitle: "Stay on track, automatically.")
        }
    }

    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: RoutineSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(RoutineColors.funnelSecondaryText)
                .frame(width: 24, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(RoutineTypography.funnelBody)
                    .foregroundStyle(RoutineColors.primaryText)
                Text(subtitle)
                    .font(RoutineTypography.funnelCaption)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
    }

    private var pricingCards: some View {
        VStack(spacing: RoutineSpacing.sm) {
            ForEach(orderedPlans) { plan in
                planRow(plan)
            }
        }
    }

    private var orderedPlans: [SubscriptionPlan] {
        plans.sorted { planRank($0) < planRank($1) }
    }

    private func planRank(_ plan: SubscriptionPlan) -> Int {
        if plan.period.localizedCaseInsensitiveContains("week") { return 0 }
        if plan.period.localizedCaseInsensitiveContains("year") { return 1 }
        return 2
    }

    private func planRow(_ plan: SubscriptionPlan) -> some View {
        let isSelected = selectedPlanID == plan.id
        let isYearly = planRank(plan) == 1
        let cadenceName = planRank(plan) == 0 ? "Weekly" : (isYearly ? "Yearly" : plan.displayName)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlanID = plan.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: RoutineSpacing.xs) {
                    Text("\(plan.displayPrice)/\(plan.period)")
                        .font(RoutineTypography.funnelBody)
                        .foregroundStyle(RoutineColors.primaryText)
                    Spacer(minLength: RoutineSpacing.xs)
                    if isYearly {
                        Text("Best value")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(RoutineColors.inverseText)
                            .padding(.horizontal, RoutineSpacing.xs)
                            .padding(.vertical, RoutineSpacing.xxs)
                            .background(RoutineColors.primaryText, in: Capsule())
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(RoutineColors.tertiaryText)
                }
                Text("\(cadenceName) plan")
                    .font(RoutineTypography.funnelCaption)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
            }
            .padding(.horizontal, RoutineSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 11))
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(isSelected ? RoutineColors.primaryText : RoutineColors.border, lineWidth: isSelected ? 1.2 : 0.8)
            }
            .contentShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(cadenceName), \(plan.priceDescription)\(isYearly ? ", Best value" : "")")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private func preferredPlan(in plans: [SubscriptionPlan]) -> SubscriptionPlan? {
        plans.first { planRank($0) == 1 || $0.displayName.localizedCaseInsensitiveContains("year") }
    }

    private func purchaseSelectedPlan() {
        guard isSubscriptionReady, let selectedPlanID else { return }
        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                let purchased = try await services.subscriptions.purchase(planID: selectedPlanID)
                isPurchasing = false
                if purchased {
                    services.analytics.track("subscription_purchased", properties: ["product_id": selectedPlanID])
                    onContinue()
                }
            } catch {
                isPurchasing = false
                errorMessage = error is SubscriptionError
                    ? error.localizedDescription
                    : "Purchase could not be completed. Please try again."
            }
        }
    }

    private func restorePurchases() {
        guard isSubscriptionReady, !isPurchasing else { return }
        isPurchasing = true
        errorMessage = nil

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
            isPurchasing = false
        }
    }

    private var purchaseButtonTitle: String {
        if isPurchasing { return "Processing..." }
        if isLoadingPlans { return "Loading plans..." }
        return "Start my free trial"
    }
}

#Preview("Paywall") {
    PaywallView {}
        .environment(AppServices())
}
