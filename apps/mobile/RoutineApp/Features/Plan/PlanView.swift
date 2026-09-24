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
                    title: context.guidanceTitle
                )
                .padding(.bottom, RoutineSpacing.xxl + RoutineSpacing.xxs)

                RoutineNumberedTimeline(steps: insights)

                Spacer(minLength: RoutineSpacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } bottom: {
            RoutinePrimaryButton(title: "See my plan", action: onContinue, visualStyle: .funnel)
        }
    }

    private let insights = [
        RoutineNumberedTimelineStep(title: "Start smaller", subtitle: "Tiny steps create real progress."),
        RoutineNumberedTimelineStep(title: "Focus on repeatable actions", subtitle: "Routines beat motivation."),
        RoutineNumberedTimelineStep(title: "Build momentum first", subtitle: "Progress fuels consistency.")
    ]
}

#Preview("Personal plan guidance") {
    PlanView(
        name: "Matheus",
        answers: ["Stay more consistent", "I struggle with consistency", "Starting again", "10–15 minutes", nil],
        onContinue: {}
    )
}
