import SwiftUI

struct PaywallView: View {
    @State private var selectedPlan: Plan = .weekly
    let onContinue: () -> Void

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center) {
            VStack(spacing: 0) {
                HStack(spacing: RoutineSpacing.xs) {
                    RoutineLogo(size: .small)
                        .frame(width: 34, height: 34)
                    Text("Routine Pro")
                        .font(RoutineTypography.appName)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Routine Pro")
                .frame(height: 48)
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, RoutineSpacing.md)
                Text("Invest in better habits.")
                    .routineTitleStyle()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.xs)
                Text("Unlock your full potential with Routine Pro.")
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
                Text("No commitment, cancel anytime")
                    .routineSubtitleStyle()
                    .multilineTextAlignment(.center)
                    .padding(.vertical, RoutineSpacing.xs)
                RoutinePrimaryButton(title: "Start free trial", action: onContinue)
            }
            .padding(.top, RoutineSpacing.xl)
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
            ForEach([Plan.weekly, Plan.yearly], id: \.self) { plan in
                RoutinePricingCard(plan: plan, isSelected: selectedPlan == plan) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPlan = plan
                    }
                }
            }
        }
    }
}

#Preview("Paywall") {
    PaywallView {}
}
