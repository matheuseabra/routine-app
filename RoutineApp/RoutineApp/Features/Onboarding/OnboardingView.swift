import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center, minimumBottomSafeArea: 32) {
            VStack(spacing: RoutineSpacing.xxl) {
                brandLockup
                introduction
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } bottom: {
            RoutinePrimaryButton(title: "Get started", action: onContinue, visualStyle: .funnel)
        }
    }

    private var brandLockup: some View {
        VStack(spacing: RoutineSpacing.xs) {
            RoutineLogo(size: .medium)
                .scaleEffect(0.74)
                .frame(width: 50, height: 50)
            Text(AppConfig.displayName)
                .font(RoutineTypography.funnelHeadline)
                .foregroundStyle(RoutineColors.primaryText)
        }
        .accessibilityElement(children: .combine)
    }

    private var introduction: some View {
        VStack(spacing: 34) {
            Text("Build better habits\nthat actually stick.")
                .font(RoutineTypography.funnelWelcome)
                .foregroundStyle(RoutineColors.primaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Build better habits that actually stick.")

            Text("A simple plan built around your goals,\nyour routine, and your real life.")
                .font(RoutineTypography.funnelSubtitle)
                .foregroundStyle(RoutineColors.funnelSecondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, RoutineSpacing.lg)
    }

}

#Preview("Onboarding") {
    OnboardingView {}
}
