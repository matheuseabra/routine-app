import SwiftUI

struct HabitsView: View {
    let onAddTask: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RoutinePageHeader(
                    title: "Habits",
                    subtitle: "Build habits that fit your real life."
                )
                .padding(.top, RoutineSpacing.lg)
                .padding(.bottom, RoutineSpacing.xl)

                RoutineCard {
                    VStack(alignment: .leading, spacing: RoutineSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(RoutineColors.primaryText)
                            RoutineIcon(.listChecks, weight: .regular, color: RoutineColors.inverseText)
                                .frame(width: 26, height: 26)
                        }
                        .frame(width: 52, height: 52)

                        VStack(alignment: .leading, spacing: RoutineSpacing.xs) {
                            Text("Your routine starts here")
                                .font(RoutineTypography.compactTitle)
                            Text("Create a small daily task, repeat it, and let consistency do the heavy lifting.")
                                .routineSubtitleStyle()
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        RoutinePrimaryButton(title: "Add a task", action: onAddTask)
                    }
                }

                RoutineSectionHeader(title: "A simple rhythm")
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.sm)

                VStack(spacing: RoutineSpacing.xs) {
                    rhythmRow(icon: .target, title: "Choose one thing", subtitle: "Start with a task you can repeat.")
                    rhythmRow(icon: .arrowsClockwise, title: "Return to it daily", subtitle: "Small actions become a routine over time.")
                    rhythmRow(icon: .chartLineUp, title: "Notice your progress", subtitle: "Insights will follow as you build momentum.")
                }
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.huge)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
    }

    private func rhythmRow(icon: RoutineIconName, title: String, subtitle: String) -> some View {
        HStack(spacing: RoutineSpacing.md) {
            RoutineIcon(icon, weight: .regular)
                .frame(width: 22, height: 22)
            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(title)
                    .font(RoutineTypography.timelineTitle)
                Text(subtitle)
                    .font(RoutineTypography.small)
                    .foregroundStyle(RoutineColors.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, RoutineSpacing.md)
        .frame(minHeight: 64)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Habits") {
    HabitsView {}
}
