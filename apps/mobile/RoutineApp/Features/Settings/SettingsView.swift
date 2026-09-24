import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(AppServices.self) private var services
    @State private var statusMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RoutinePageHeader(title: "Settings")
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
}
