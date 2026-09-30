import SwiftUI

struct PaywallTrialReminderView: View {
    let userName: String
    let onContinue: () -> Void

    init(userName: String = "", onContinue: @escaping () -> Void) {
        self.userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.onContinue = onContinue
    }

    private let steps = [
        RoutineTimelineStep(
            icon: .calendarCheck,
            title: "Today",
            subtitle: "Unlock unlimited access to all Routine features."
        ),
        RoutineTimelineStep(
            icon: .clock,
            title: "Day 5",
            subtitle: "We'll remind you with a notification that your trial is ending."
        ),
        RoutineTimelineStep(
            icon: .check,
            title: "Day 7",
            subtitle: "Your subscription will start on day 7. Cancel anytime before."
        )
    ]

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center) {
            VStack(spacing: 0) {
                RoutineHeroIcon(.clock)
                    .padding(.top, RoutineSpacing.xl)
                    .padding(.bottom, RoutineSpacing.lg)
                Text(headline)
                    .font(RoutineTypography.funnelTitle)
                    .foregroundStyle(RoutineColors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .padding(.bottom, RoutineSpacing.md)
                Text("Review your options and price before you subscribe.")
                    .routineSubtitleStyle()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.md)
                RoutineTimeline(steps: steps)
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.lg)
            }
            .padding(.top, RoutineSpacing.lg)
        } bottom: {
            RoutinePrimaryButton(title: "Continue", action: onContinue)
        }
    }

    private var headline: String {
        userName.isEmpty ? "7 Day Free Trial" : "\(userName), 7 Day Free Trial"
    }
}

#Preview("Paywall 2") {
    PaywallTrialReminderView {}
}
