import SwiftUI

struct AuthenticationView: View {
    @Environment(AppServices.self) private var services
    @State private var isLoading = false
    @State private var errorMessage: String?

    let onContinue: () -> Void

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center, minimumBottomSafeArea: 32) {
            VStack(spacing: 0) {
                Spacer(minLength: RoutineSpacing.lg)

                RoutineFunnelContextHeader(
                    icon: "icloud.and.arrow.up",
                    title: "Save your progress.",
                    subtitle: "Create an account to sync your data across all your devices."
                )
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
                        .font(RoutineTypography.funnelCaption)
                        .foregroundStyle(RoutineColors.funnelSecondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, RoutineSpacing.md)
                }

                Spacer(minLength: RoutineSpacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } bottom: {
            footer
                .font(RoutineTypography.funnelCaption)
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
                if error is AuthProviderError {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = "Sign in could not be completed. Please try again."
                }
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
