import SwiftUI

struct PaywallTrialReminderView: View {
    let onContinue: () -> Void

    private let steps = [
        RoutineTimelineStep(
            icon: .calendarCheck,
            title: "Today: Instant access",
            subtitle: "With free 7-day trial"
        ),
        RoutineTimelineStep(
            icon: .bell,
            title: "Day 5: Trial reminder",
            subtitle: "We notify you about your trial end via email"
        ),
        RoutineTimelineStep(
            icon: .check,
            title: "Day 7: Full membership",
            subtitle: "Your account is charged, cancel anytime in the 24h before"
        )
    ]

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center) {
            VStack(spacing: 0) {
                RoutineHeroIcon(.clock)
                    .padding(.top, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.md)
                Text("Your 7-day free trial.")
                    .routineTitleStyle()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.xs)
                RoutineTimeline(steps: steps)
                    .padding(.top, RoutineSpacing.xl)
                    .padding(.bottom, RoutineSpacing.md)
            }
            .padding(.top, RoutineSpacing.lg)
        } bottom: {
            RoutinePrimaryButton(title: "Continue", action: onContinue)
        }
    }
}

#Preview("Paywall 2") {
    PaywallTrialReminderView {}
}
