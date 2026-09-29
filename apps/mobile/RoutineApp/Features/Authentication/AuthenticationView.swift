import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @Environment(AppServices.self) private var services
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appleNonce: String?

    let onContinue: () -> Void

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center, minimumBottomSafeArea: 32) {
            VStack(spacing: 0) {
                Spacer(minLength: RoutineSpacing.lg)

                RoutineFunnelContextHeader(
                    icon: "icloud.and.arrow.up",
                    title: "Save your progress."
                )
                .padding(.bottom, RoutineSpacing.sm)

                Text("Keep your routine and progress in sync across devices.")
                    .font(RoutineTypography.funnelSubtitle)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.xl)

                VStack(spacing: RoutineSpacing.sm) {
                    SignInWithAppleButton(.continue) { request in
                        let nonce = AppleSignInNonce.make()
                        appleNonce = nonce
                        request.nonce = nonce
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        handleAppleResult(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(isLoading)

                    RoutineSecondaryButton(
                        title: "Continue with Google",
                        assetImage: "google"
                    ) {
                        signInWithGoogle()
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

    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) {
        guard !isLoading else { return }
        guard case let .success(authorization) = result else {
            if case let .failure(error) = result,
               (error as? ASAuthorizationError)?.code != .canceled {
                errorMessage = "Sign in could not be completed. Please try again."
            }
            return
        }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8),
              let requestNonce = appleNonce else {
            errorMessage = "Sign in could not be completed. Please try again."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let identity = AppleIdentity(
                    token: token,
                    nonce: requestNonce,
                    profile: .init(
                        name: .init(
                            firstName: credential.fullName?.givenName,
                            lastName: credential.fullName?.familyName
                        ),
                        email: credential.email
                    )
                )
                _ = try await services.auth.signInWithApple(identity)
                services.analytics.track("authentication_succeeded", properties: ["provider": "apple"])
                isLoading = false
                appleNonce = nil
                onContinue()
            } catch {
                isLoading = false
                appleNonce = nil
                errorMessage = "Sign in could not be completed. Please try again."
            }
        }
    }

    private func signInWithGoogle() {
        guard !isLoading else { return }
        Task {
            do {
                _ = try await services.auth.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
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
