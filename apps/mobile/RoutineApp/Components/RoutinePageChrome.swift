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
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 320)
        .padding(.horizontal, RoutineSpacing.lg)
        .frame(maxWidth: .infinity)
    }
}
