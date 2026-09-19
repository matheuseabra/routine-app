import SwiftUI

struct AuthenticationView: View {
    let onContinue: () -> Void

    var body: some View {
        RoutineScreenLayout {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    RoutineIcon(.cloudCheck, weight: .regular)
                        .frame(width: 66, height: 66)
                        .accessibilityHidden(true)
                        .padding(.bottom, RoutineSpacing.xl)
                    Text("Save your progress.")
                        .routineTitleStyle()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, RoutineSpacing.sm)
                    Text("Create an account to sync your data\nacross all your devices.")
                        .routineSubtitleStyle()
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.bottom, RoutineSpacing.xl)
                    VStack(spacing: RoutineSpacing.sm) {
                        RoutineSecondaryButton(
                            title: "Continue with Apple",
                            assetImage: "apple",
                            style: .filled,
                            action: onContinue
                        )
                        RoutineSecondaryButton(title: "Continue with Google", assetImage: "google", action: onContinue)
                    }
                }
                Spacer()
            }
        } bottom: {
            footer
        .font(RoutineTypography.smallRegular)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    private var footer: some View {
        Text("By continuing, you agree to our ")
            .foregroundStyle(RoutineColors.tertiaryText)
        + Text("Terms of Service").underline().font(RoutineTypography.small).foregroundStyle(RoutineColors.secondaryText)
        + Text(" and ").foregroundStyle(RoutineColors.tertiaryText)
        + Text("Privacy Policy").underline().font(RoutineTypography.small).foregroundStyle(RoutineColors.secondaryText)
    }
}

#Preview("Auth") {
    AuthenticationView {}
}
