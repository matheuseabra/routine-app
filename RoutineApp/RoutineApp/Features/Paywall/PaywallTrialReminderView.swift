import SwiftUI

struct PaywallTrialReminderView: View {
    let onContinue: () -> Void

    private let steps = [
        RoutineNumberedTimelineStep(
            title: "Today: Instant access",
            subtitle: "With free 7-day trial"
        ),
        RoutineNumberedTimelineStep(
            title: "Day 5: Trial reminder",
            subtitle: "We notify you about your trial end via email"
        ),
        RoutineNumberedTimelineStep(
            title: "Day 7: Full membership",
            subtitle: "Your account is charged, cancel anytime in the 24h before"
        )
    ]

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center) {
            VStack(spacing: 0) {
                RoutineIcon(.clock, weight: .regular)
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
                    .padding(.top, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.md)
                Text("Your trial timeline.")
                    .routineTitleStyle()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.xs)
                Text("Your 7-day free trial, step by step.")
                    .routineSubtitleStyle()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                RoutineNumberedTimeline(steps: steps)
                    .padding(.top, RoutineSpacing.xxl)
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
