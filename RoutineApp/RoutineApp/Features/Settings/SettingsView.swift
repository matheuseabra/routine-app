import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(AppServices.self) private var services
    @State private var statusMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .routineTitleStyle()
                    .font(RoutineTypography.settingsTitle)
                    .padding(.top, RoutineSpacing.xl)
                    .padding(.bottom, RoutineSpacing.lg)

                VStack(spacing: 0) {
                    setting(.bell, "Notifications") {}
                    divider
                    setting(.sliders, "Preferences") {}
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
                        statusMessage = "Connect your production account provider to implement deletion."
                    }
                }
                .padding(.horizontal, RoutineSpacing.md)
                .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))

                if let statusMessage {
                    Text(statusMessage)
                        .font(RoutineTypography.smallRegular)
                        .foregroundStyle(RoutineColors.secondaryText)
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
