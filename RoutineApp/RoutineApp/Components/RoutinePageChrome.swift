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
        HStack(alignment: .top, spacing: RoutineSpacing.md) {
            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(title)
                    .routineTitleStyle()
            }
            Spacer(minLength: RoutineSpacing.sm)
            trailing
                .padding(.top, RoutineSpacing.xxs)
        }
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
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        RoutineCard {
            VStack(alignment: .leading, spacing: RoutineSpacing.md) {
                RoutineIcon(icon, color: RoutineColors.primaryText)
                    .frame(width: 26, height: 26)
                    .frame(width: 52, height: 52)
                    .background(RoutineColors.track, in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: RoutineSpacing.xs) {
                    Text(title)
                        .font(RoutineTypography.compactTitle)
                        .foregroundStyle(RoutineColors.primaryText)
                    Text(message)
                        .routineSubtitleStyle()
                        .fixedSize(horizontal: false, vertical: true)
                }

                RoutinePrimaryButton(title: actionTitle, action: action)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
