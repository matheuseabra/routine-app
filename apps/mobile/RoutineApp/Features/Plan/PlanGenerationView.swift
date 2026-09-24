import SwiftUI

struct PlanGenerationView: View {
    let onComplete: () -> Void
    @State private var progress = 0.0

    init(onComplete: @escaping () -> Void) {
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
                    title: "Creating your personal plan..."
                )
                .padding(.bottom, RoutineSpacing.xl)

                progressRing
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, RoutineSpacing.xl)
                progressSteps
                    .padding(.bottom, RoutineSpacing.xl)
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
        do {
            try await Task.sleep(for: .milliseconds(220))
        } catch {
            return
        }
        for percentage in 1...100 {
            guard !Task.isCancelled else { return }
            let stepDuration = progressStepDuration(for: percentage)
            withAnimation(.linear(duration: Double(stepDuration) / 1_000)) {
                progress = Double(percentage)
            }
            do {
                try await Task.sleep(for: .milliseconds(stepDuration))
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

    private func progressStepDuration(for percentage: Int) -> Int {
        switch percentage {
        case ...45: 35
        case 46..<60: 80 - percentage
        default: 20
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(RoutineColors.track, lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress / 100)
                .stroke(RoutineColors.primaryText, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
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
            progressRow("Analyzing your goal", complete: progress >= 25)
            progressRow("Understanding your routine", complete: progress >= 50)
            progressRow("Finding your starting point", complete: progress >= 75)
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

}

#Preview("Plan generation") {
    PlanGenerationView(onComplete: {})
}
