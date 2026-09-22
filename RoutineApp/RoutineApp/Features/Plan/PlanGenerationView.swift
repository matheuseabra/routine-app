import SwiftUI

struct PlanGenerationView: View {
    let context: RoutinePlanContext
    let onComplete: () -> Void
    @State private var progress = 67.0

    init(name: String, answers: [String?], onComplete: @escaping () -> Void) {
        context = RoutinePlanContext(name: name, answers: answers)
        self.onComplete = onComplete
    }

    var body: some View {
        RoutineScreenLayout(
            scrolls: true,
            contentAlignment: .center,
            minimumBottomSafeArea: 32
        ) {
            VStack(alignment: .center, spacing: 0) {
                RoutineFunnelContextHeader(
                    icon: "sparkles",
                    title: "Creating your personal plan...",
                    subtitle: "We’ll tailor it around your goals, time, and routine."
                )
                .padding(.bottom, RoutineSpacing.xl)

                progressRing
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, RoutineSpacing.xl)
                progressSteps
                    .padding(.bottom, RoutineSpacing.xl)
                answerChips
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, RoutineSpacing.xs)
            }
            .frame(maxWidth: .infinity)
        } bottom: {
            EmptyView()
        }
        .task {
            await animatePlanProgress()
        }
    }

    private func animatePlanProgress() async {
        for percentage in 68...100 {
            guard !Task.isCancelled else { return }
            progress = Double(percentage)
            do {
                try await Task.sleep(for: .milliseconds(85))
            } catch {
                return
            }
        }
        do {
            try await Task.sleep(for: .milliseconds(450))
        } catch {
            return
        }
        guard !Task.isCancelled else { return }
        onComplete()
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(RoutineColors.track, lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress / 100)
                .stroke(RoutineColors.primaryText, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.085), value: progress)
            Text("\(Int(progress))%")
                .font(RoutineTypography.funnelHeadline)
                .foregroundStyle(RoutineColors.primaryText)
                .accessibilityHidden(true)
        }
        .frame(width: 112, height: 112)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("plan-generation-progress")
        .accessibilityLabel("Building your plan")
        .accessibilityValue("\(Int(progress)) percent")
    }

    private var progressSteps: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.xs) {
            progressRow("Analyzing your goal", complete: true)
            progressRow("Understanding your routine", complete: true)
            progressRow("Finding your starting point", complete: true)
            progressRow("Building your plan", complete: progress == 100)
        }
        .frame(maxWidth: 280, alignment: .leading)
        .frame(maxWidth: .infinity)
    }

    private func progressRow(_ title: String, complete: Bool) -> some View {
        HStack(spacing: RoutineSpacing.md) {
            if complete {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RoutineColors.primaryText)
                    .frame(width: 14)
            } else {
                Circle()
                    .stroke(RoutineColors.border, lineWidth: 1)
                    .frame(width: 14, height: 14)
            }
            Text(title)
                .font(RoutineTypography.funnelCaption)
                .foregroundStyle(complete ? RoutineColors.primaryText : RoutineColors.funnelSecondaryText)
        }
    }

    private var answerChips: some View {
        VStack(spacing: RoutineSpacing.xs) {
            HStack(spacing: RoutineSpacing.xs) {
                chip(context.goalAnswer)
                chip(context.timeAnswer)
            }
            chip(context.consistencyAnswer)
        }
    }

    private func chip(_ title: String) -> some View {
        Text(title)
            .font(RoutineTypography.funnelCaption)
            .foregroundStyle(RoutineColors.secondaryText)
            .padding(.horizontal, RoutineSpacing.sm)
            .padding(.vertical, RoutineSpacing.xs)
            .background(RoutineColors.funnelSelection, in: Capsule())
    }
}

#Preview("Plan generation") {
    PlanGenerationView(
        name: "Matheus",
        answers: ["Stay more consistent", "I struggle with consistency", "Starting again", "10–15 minutes", nil],
        onComplete: {}
    )
}
