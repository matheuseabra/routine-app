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
            title: "Choose a plan",
            subtitle: "Pick the billing period that works for you."
        ),
        RoutineTimelineStep(
            icon: .clock,
            title: "Review the price",
            subtitle: "See the amount before you confirm."
        ),
        RoutineTimelineStep(
            icon: .check,
            title: "Stay in control",
            subtitle: "Manage or cancel in your App Store account."
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
        userName.isEmpty
            ? "Choose what fits you."
            : "\(userName), choose what fits."
    }
}

#Preview("Paywall 2") {
    PaywallTrialReminderView {}
}
