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
                RoutineHeroIcon(.bell)
                    .padding(.bottom, RoutineSpacing.xl)
                    .accessibilityHidden(true)
                Text("Never miss a moment.")
                    .routineTitleStyle()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, RoutineSpacing.md)
                Text("Get a gentle reminder to help you follow through each day.")
                    .routineSubtitleStyle()
                    .multilineTextAlignment(.center)
                Spacer()
            }
        } bottom: {
            VStack(spacing: RoutineSpacing.sm) {
                RoutinePrimaryButton(title: "Allow notifications") {
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
