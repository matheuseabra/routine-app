import SwiftUI

struct PaywallView: View {
    @Environment(AppServices.self) private var services

    @State private var plans = StarterDemoData.subscriptionPlans
    @State private var selectedPlanID = StarterDemoData.subscriptionPlans.first(where: { $0.period == "year" })?.id
    @State private var isPurchasing = false
    @State private var isLoadingPlans = true
    @State private var isSubscriptionReady = false
    @State private var errorMessage: String?
    @State private var planSelectionHapticTrigger = 0

    let onContinue: () -> Void
    var onClose: (() -> Void)? = nil

    var body: some View {
        RoutineScreenLayout(
            scrolls: true,
            contentAlignment: .center,
            minimumBottomSafeArea: 32
        ) {
            VStack(alignment: .center, spacing: 0) {
                RoutineFunnelBrandHeader(name: "Routine+")
                    .padding(.bottom, RoutineSpacing.md)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .topTrailing) {
                        if let onClose {
                            Button(action: onClose) {
                                RoutineIcon(.x)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Close")
                        }
                    }

                Text("Make progress,\none day at a time.")
                    .font(RoutineTypography.funnelTitle)
                    .foregroundStyle(RoutineColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Make progress, one day at a time.")
                    .padding(.bottom, RoutineSpacing.md)

                benefits
                    .frame(maxWidth: 340)
                    .frame(maxWidth: .infinity, alignment: .center)

                testimonial
                    .padding(.top, RoutineSpacing.lg)
            }
            .frame(maxWidth: .infinity)
        } bottom: {
            VStack(spacing: 0) {
                pricingCards
                    .padding(.bottom, RoutineSpacing.sm)

                if let errorMessage {
                    Text(errorMessage)
                        .font(RoutineTypography.funnelCaption)
                        .foregroundStyle(RoutineColors.funnelSecondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, RoutineSpacing.sm)
                }

                RoutinePrimaryButton(title: purchaseButtonTitle, action: {
                    purchaseSelectedPlan()
                }, visualStyle: .funnel)
                .accessibilityIdentifier("paywall-purchase")
                .padding(.bottom, RoutineSpacing.xxs)
                .disabled(isPurchasing || isLoadingPlans || selectedPlanID == nil || !isSubscriptionReady)
                .accessibilityHint(isSubscriptionReady ? "Starts the selected subscription." : "Live purchases are unavailable in this build.")

                Text("Cancel anytime in the App Store.")
                    .font(RoutineTypography.funnelCaption)
                    .foregroundStyle(RoutineColors.tertiaryText)
                    .padding(.vertical, RoutineSpacing.xs)

                legalLinks
            }
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
        VStack(alignment: .leading, spacing: RoutineSpacing.md) {
            benefitRow(
                icon: .target,
                title: "A routine shaped around your goals",
                subtitle: "Start with a plan built around your focus and available time."
            )
            benefitRow(
                icon: .check,
                title: "Small steps each day",
                subtitle: "Turn your routine into tasks you can check off as you go."
            )
            benefitRow(
                icon: .chartLineUp,
                title: "See your progress over time",
                subtitle: "Track activity, streaks, and consistency in one place."
            )
        }
    }

    private var testimonial: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.sm) {
            Text("“Routine helped me start small and stay consistent, one day at a time.”")
                .font(RoutineTypography.funnelCaption)
                .foregroundStyle(RoutineColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: RoutineSpacing.sm) {
                Image("routine-user")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                Text("Alex")
                    .font(RoutineTypography.funnelCaption.weight(.semibold))
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
            }
        }
        .padding(RoutineSpacing.md)
        .frame(maxWidth: 340, alignment: .leading)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 12))
    }

    private func benefitRow(icon: RoutineIconName, title: String, subtitle: String) -> some View {
        HStack(spacing: RoutineSpacing.md) {
            RoutineIcon(icon, pointSize: 17)
                .frame(width: 40, height: 40)
                .background(RoutineColors.track, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(title)
                    .font(RoutineTypography.funnelBodyMedium)
                    .foregroundStyle(RoutineColors.primaryText)
                Text(subtitle)
                    .font(RoutineTypography.funnelCaption)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
    }

    private var pricingCards: some View {
        VStack(spacing: RoutineSpacing.sm) {
            ForEach(orderedPlans) { plan in
                planRow(plan)
            }
        }
    }

    private var legalLinks: some View {
        HStack(spacing: RoutineSpacing.xs) {
            Link("Terms", destination: AppConfig.termsURL)
                .accessibilityIdentifier("paywall-terms-link")
            footerSeparator
            Link("Privacy", destination: AppConfig.privacyURL)
                .accessibilityIdentifier("paywall-privacy-link")
            footerSeparator
            Button("Restore", action: restorePurchases)
                .disabled(!isSubscriptionReady || isPurchasing)
                .accessibilityIdentifier("paywall-restore-button")
        }
        .font(RoutineTypography.funnelCaption)
        .foregroundStyle(RoutineColors.secondaryText)
        .tint(RoutineColors.secondaryText)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var footerSeparator: some View {
        Text("·")
            .foregroundStyle(RoutineColors.tertiaryText)
            .accessibilityHidden(true)
    }

    private var orderedPlans: [SubscriptionPlan] {
        plans.sorted { planRank($0) < planRank($1) }
    }

    private func planRank(_ plan: SubscriptionPlan) -> Int {
        if isYearlyPlan(plan) { return 0 }
        if isWeeklyPlan(plan) { return 1 }
        return 2
    }

    private func planRow(_ plan: SubscriptionPlan) -> some View {
        let isSelected = selectedPlanID == plan.id
        let isYearly = isYearlyPlan(plan)
        let isWeekly = isWeeklyPlan(plan)
        let cadenceName = isYearly ? "Yearly" : (isWeekly ? "Weekly" : plan.displayName)
        let billingInterval = isYearly ? "/year" : (isWeekly ? "/week" : "/\(plan.period)")
        return Button {
            guard selectedPlanID != plan.id else { return }
            planSelectionHapticTrigger += 1
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlanID = plan.id
            }
        } label: {
            HStack(spacing: RoutineSpacing.sm) {
                RoutineRadioButton(isSelected: isSelected)

                Text(cadenceName)
                    .font(RoutineTypography.funnelBodyMedium)
                    .foregroundStyle(RoutineColors.primaryText)

                Spacer(minLength: RoutineSpacing.sm)

                VStack(alignment: .trailing, spacing: RoutineSpacing.xxs) {
                    Text("\(plan.displayPrice)\(billingInterval)")
                        .font(RoutineTypography.funnelBodyMedium.weight(.semibold))
                        .foregroundStyle(RoutineColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, RoutineSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
            .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 11))
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(isSelected ? RoutineColors.primaryText : RoutineColors.border, lineWidth: isSelected ? 1.2 : 0.8)
            }
            .overlay(alignment: .topTrailing) {
                if isYearly {
                    Text("Best value")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(RoutineColors.inverseText)
                        .padding(.horizontal, RoutineSpacing.xs)
                        .padding(.vertical, RoutineSpacing.xxs)
                        .background(RoutineColors.primaryText, in: Capsule())
                        .offset(x: -RoutineSpacing.md, y: -7)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: planSelectionHapticTrigger)
        .accessibilityLabel("\(cadenceName), \(plan.displayPrice)\(billingInterval)\(isYearly ? ", Best value" : "")")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityIdentifier("paywall-plan-\(plan.period)")
    }

    private func isYearlyPlan(_ plan: SubscriptionPlan) -> Bool {
        let cadence = "\(plan.displayName) \(plan.period)"
        return cadence.localizedCaseInsensitiveContains("year")
            || cadence.localizedCaseInsensitiveContains("annual")
    }

    private func isWeeklyPlan(_ plan: SubscriptionPlan) -> Bool {
        "\(plan.displayName) \(plan.period)".localizedCaseInsensitiveContains("week")
    }

    private func preferredPlan(in plans: [SubscriptionPlan]) -> SubscriptionPlan? {
        plans.first { isYearlyPlan($0) }
    }

    private func purchaseSelectedPlan() {
        guard isSubscriptionReady, let selectedPlanID else { return }
        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                let outcome = try await services.subscriptions.purchase(planID: selectedPlanID)
                isPurchasing = false
                if outcome == .purchased {
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
        let selectedPlanHasTrial = plans.first(where: { $0.id == selectedPlanID })?.hasTrial == true
        return selectedPlanHasTrial ? "Start your free trial" : "Continue with Routine"
    }
}

#Preview("Paywall") {
    PaywallView {}
        .environment(AppServices())
}
