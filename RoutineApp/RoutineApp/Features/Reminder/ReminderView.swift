import SwiftUI

struct ReminderView: View {
    let onContinue: () -> Void
    private let permissionService: any ReminderPermissionRequesting

    init(
        permissionService: any ReminderPermissionRequesting = ReminderPermissionService(),
        onContinue: @escaping () -> Void
    ) {
        self.permissionService = permissionService
        self.onContinue = onContinue
    }

    var body: some View {
        RoutineScreenLayout {
            VStack(spacing: 0) {
                Spacer()
                RoutineIcon(.bell)
                    .frame(width: 68, height: 68)
                    .padding(.bottom, RoutineSpacing.xl)
                    .accessibilityHidden(true)
                Text("Never miss a moment.")
                    .routineTitleStyle()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.md)
                Text("Enable gentle reminders to stay consistent and keep your momentum going.")
                    .routineSubtitleStyle()
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, RoutineSpacing.sm)
                    .padding(.bottom, RoutineSpacing.lg)
                Text("We’ll only send helpful habit reminders.")
                    .font(RoutineTypography.small)
                    .foregroundStyle(RoutineColors.tertiaryText)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        } bottom: {
            VStack(spacing: RoutineSpacing.sm) {
                RoutinePrimaryButton(title: "Enable reminders") {
                    Task {
                        _ = await permissionService.requestAuthorization()
                        onContinue()
                    }
                }
                Button("Not now", action: onContinue)
                    .font(RoutineTypography.button)
                    .foregroundStyle(RoutineColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .accessibilityLabel("Not now")
            }
        }
    }
}

#Preview("Reminder") {
    ReminderView {}
}
