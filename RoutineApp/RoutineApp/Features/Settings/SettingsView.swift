import SwiftUI

struct SettingsView: View {
    private let rows = [
        (RoutineIconName.bell, "Notifications"),
        (RoutineIconName.sliders, "Preferences"),
        (RoutineIconName.creditCard, "Billing"),
        (RoutineIconName.question, "Help & Support"),
        (RoutineIconName.fileText, "Terms of Service"),
        (RoutineIconName.shieldCheck, "Privacy Policy"),
        (RoutineIconName.trash, "Delete Account")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .routineTitleStyle()
                    .font(RoutineTypography.settingsTitle)
                    .padding(.top, RoutineSpacing.xl)
                    .padding(.bottom, RoutineSpacing.lg)
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                        RoutineSettingRow(
                            icon: row.0,
                            title: row.1,
                            textFont: RoutineTypography.settingsRow
                        ) {}
                        if index < rows.count - 1 {
                            Divider()
                                .overlay(RoutineColors.border)
                                .padding(.leading, 40)
                        }
                    }
                }
                .padding(.horizontal, RoutineSpacing.md)
                .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
    }
}

#Preview("Settings") {
    SettingsView()
}
