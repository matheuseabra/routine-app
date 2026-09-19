import SwiftUI

struct AuthenticationView: View {
    @Environment(AppServices.self) private var services
    @State private var isLoading = false
    @State private var errorMessage: String?

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
                            title: isLoading ? "Signing in..." : "Continue with Apple",
                            assetImage: "apple",
                            style: .filled
                        ) {
                            signIn(using: .apple)
                        }
                        .disabled(isLoading)

                        RoutineSecondaryButton(
                            title: "Continue with Google",
                            assetImage: "google"
                        ) {
                            signIn(using: .google)
                        }
                        .disabled(isLoading)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(RoutineTypography.smallRegular)
                            .foregroundStyle(RoutineColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.top, RoutineSpacing.md)
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

    private enum Provider {
        case apple
        case google
    }

    private func signIn(using provider: Provider) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                switch provider {
                case .apple:
                    _ = try await services.auth.signInWithApple()
                case .google:
                    _ = try await services.auth.signInWithGoogle()
                }

                services.analytics.track("authentication_succeeded", properties: [
                    "provider": provider == .apple ? "apple" : "google"
                ])
                isLoading = false
                onContinue()
            } catch {
                isLoading = false
                errorMessage = "Sign in could not be completed. Please try again."
            }
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
        .environment(AppServices())
}
