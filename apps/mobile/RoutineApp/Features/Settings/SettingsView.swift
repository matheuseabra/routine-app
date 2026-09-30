import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(AppServices.self) private var services
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router
    @State private var statusMessage: String?
    @State private var isResetConfirmationPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RoutinePageHeader(title: "Settings") {
                    Button("Done") { dismiss() }
                        .font(RoutineTypography.secondary)
                        .foregroundStyle(RoutineColors.primaryText)
                        .frame(minWidth: 44, minHeight: 44)
                }
                    .padding(.top, RoutineSpacing.xl)
                    .padding(.bottom, RoutineSpacing.lg)

                VStack(spacing: 0) {
                    setting(.bell, "Notification settings") {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            openURL(settingsURL)
                        }
                    }
                    divider
                    setting(.creditCard, "Restore purchases") {
                        Task {
                            do {
                                let restored = try await services.subscriptions.restore()
                                statusMessage = restored
                                    ? "Subscription restored."
                                    : "No active subscription was found."
                            } catch {
                                statusMessage = "Purchases could not be restored."
                            }
                        }
                    }
                    divider
                    setting(.question, "Help & Support") {
                        openURL(AppConfig.supportURL)
                    }
                    divider
                    setting(.fileText, "Terms of Service") {
                        openURL(AppConfig.termsURL)
                    }
                    divider
                    setting(.shieldCheck, "Privacy Policy") {
                        openURL(AppConfig.privacyURL)
                    }
                    divider
                    setting(.trash, "Delete Account") {
                        statusMessage = "Account deletion is unavailable in this build. Contact support for help."
                    }
                }
                .padding(.horizontal, RoutineSpacing.md)
                .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))

                RoutineSectionHeader(title: "Developer")
                    .padding(.top, RoutineSpacing.xl)
                    .padding(.bottom, RoutineSpacing.sm)

                VStack(spacing: 0) {
                    setting(.arrowsClockwise, "Reset onboarding") {
                        isResetConfirmationPresented = true
                    }
                }
                .padding(.horizontal, RoutineSpacing.md)
                .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))

                if let statusMessage {
                    RoutineCard {
                        VStack(alignment: .leading, spacing: RoutineSpacing.sm) {
                            Text(statusMessage)
                                .font(RoutineTypography.secondary)
                                .foregroundStyle(RoutineColors.primaryText)
                            if statusMessage.contains("deletion") {
                                Button("Contact support") { openURL(AppConfig.supportURL) }
                                    .font(RoutineTypography.small)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, RoutineSpacing.md)
                }
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
        .confirmationDialog(
            "Reset onboarding?",
            isPresented: $isResetConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Reset onboarding", role: .destructive) {
                appState.resetOnboarding()
                router.resetOnboarding()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears your saved name and restarts the welcome flow.")
        }
    }

    private var divider: some View {
        Divider()
            .overlay(RoutineColors.border)
            .padding(.leading, 40)
    }

    private func setting(
        _ icon: RoutineIconName,
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        RoutineSettingRow(
            icon: icon,
            title: title,
            textFont: RoutineTypography.settingsRow,
            action: action
        )
    }
}

#Preview("Settings") {
    SettingsView()
        .environment(AppServices())
        .environment(AppState())
        .environment(AppRouter())
}
