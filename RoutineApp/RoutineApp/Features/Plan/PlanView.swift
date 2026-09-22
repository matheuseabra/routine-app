import SwiftUI

struct PlanView: View {
    let context: RoutinePlanContext
    let onContinue: () -> Void

    init(name: String, answers: [String?], onContinue: @escaping () -> Void) {
        context = RoutinePlanContext(name: name, answers: answers)
        self.onContinue = onContinue
    }

    var body: some View {
        RoutineScreenLayout(contentAlignment: .center, minimumBottomSafeArea: 32) {
            VStack(spacing: 0) {
                Spacer(minLength: RoutineSpacing.lg)

                RoutineFunnelContextHeader(
                    icon: "target",
                    title: context.guidanceTitle,
                    subtitle: context.diagnosis
                )
                .padding(.bottom, RoutineSpacing.xxl + RoutineSpacing.xxs)

                VStack(spacing: RoutineSpacing.sm) {
                    ForEach(insights, id: \.title) { insight in
                        insightRow(insight)
                    }
                }

                Spacer(minLength: RoutineSpacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } bottom: {
            RoutinePrimaryButton(title: "See my plan", action: onContinue, visualStyle: .funnel)
        }
    }

    private let insights = [
        RoutinePlanInsight(icon: "leaf", title: "Start smaller", subtitle: "Tiny steps create real progress."),
        RoutinePlanInsight(icon: "calendar", title: "Focus on repeatable actions", subtitle: "Routines beat motivation."),
        RoutinePlanInsight(icon: "arrow.up.right", title: "Build momentum first", subtitle: "Progress fuels consistency.")
    ]

    private func insightRow(_ insight: RoutinePlanInsight) -> some View {
        HStack(alignment: .top, spacing: RoutineSpacing.sm) {
            Image(systemName: insight.icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(RoutineColors.primaryText)
                .accessibilityHidden(true)
                .padding(.top, RoutineSpacing.xxs)

            VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                Text(insight.title)
                    .font(RoutineTypography.funnelBodyMedium)
                    .foregroundStyle(RoutineColors.primaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(insight.subtitle)
                    .font(RoutineTypography.funnelCaption)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, RoutineSpacing.md)
        .padding(.vertical, RoutineSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(RoutineColors.border.opacity(0.55), lineWidth: 0.7)
        }
    }
}

private struct RoutinePlanInsight {
    let icon: String
    let title: String
    let subtitle: String
}

#Preview("Personal plan guidance") {
    PlanView(
        name: "Matheus",
        answers: ["Stay more consistent", "I struggle with consistency", "Starting again", "10–15 minutes", nil],
        onContinue: {}
    )
}
