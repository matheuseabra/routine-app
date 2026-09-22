import SwiftUI

struct RoutinePageHeader<Trailing: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let trailing: Trailing

    init(
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .top, spacing: RoutineSpacing.md) {
            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(title)
                    .routineTitleStyle()
                Text(subtitle)
                    .routineSubtitleStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: RoutineSpacing.sm)
            trailing
                .padding(.top, RoutineSpacing.xxs)
        }
    }
}

extension RoutinePageHeader where Trailing == EmptyView {
    init(title: String, subtitle: String) {
        self.init(title: title, subtitle: subtitle) {
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
