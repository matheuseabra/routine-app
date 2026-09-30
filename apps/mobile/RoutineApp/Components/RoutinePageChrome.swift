import SwiftUI

struct RoutinePageHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder let trailing: Trailing

    init(
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center, spacing: RoutineSpacing.md) {
            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(title)
                    .routineTitleStyle()
            }
            Spacer(minLength: RoutineSpacing.sm)
            trailing
        }
        .frame(minHeight: 44)
    }
}

extension RoutinePageHeader where Trailing == EmptyView {
    init(title: String) {
        self.init(title: title) {
            EmptyView()
        }
    }
}

struct RoutineSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(RoutineTypography.sectionTitle)
            .foregroundStyle(RoutineColors.primaryText)
    }
}

struct RoutineEmptyState: View {
    let icon: RoutineIconName
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: RoutineSpacing.md) {
            RoutineIcon(icon, color: RoutineColors.secondaryText, pointSize: 34)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)

            Text(title)
                .font(RoutineTypography.bodyMedium)
                .foregroundStyle(RoutineColors.primaryText)

            Text(message)
                .font(RoutineTypography.secondary)
                .foregroundStyle(RoutineColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: RoutineSpacing.xs) {
                        Text(actionTitle)
                            .font(RoutineTypography.small)
                        RoutineIcon(.caretRight)
                            .frame(width: 14, height: 14)
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(RoutineColors.primaryText)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 320)
        .padding(.horizontal, RoutineSpacing.lg)
        .frame(maxWidth: .infinity)
    }
}
