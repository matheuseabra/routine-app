import SwiftUI

struct RoutinePlanContext {
    let name: String
    private let answers: [String?]

    init(name: String, answers: [String?]) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.answers = answers
    }

    var guidanceTitle: String {
        name.isEmpty ? "Here’s where to\nstart." : "\(name), here’s where to\nstart."
    }

    var readyTitle: String {
        name.isEmpty ? "Your plan is ready." : "\(name), your plan is ready."
    }

    var goalAnswer: String { answer(at: 0, fallback: "Stay more consistent") }
    var timeAnswer: String { answer(at: 3, fallback: "10–15 minutes") }
    var consistencyAnswer: String { answer(at: 2, fallback: "Starting again") }

    var goalPhrase: String {
        switch goalAnswer {
        case "Stay more consistent": "build stronger consistency"
        case "Get more done": "get more done"
        case "Feel more focused": "feel more focused"
        case "Build healthier habits": "build healthier habits"
        case "Create a better daily routine": "create a better daily routine"
        default: goalAnswer.lowercased()
        }
    }

    var diagnosis: String {
        "You want to \(goalPhrase),\nbut \(barrierPhrase).\nHere are a few key insights to help."
    }

    var readySubtitle: String {
        "Built around your goal to \(goalPhrase)."
    }

    private var barrierPhrase: String {
        switch answer(at: 1, fallback: "I struggle with consistency") {
        case "I lose motivation": "you lose motivation"
        case "I don’t know where to start": "you’re not sure where to start"
        case "I don’t have enough time": "time is hard to find"
        case "I try to do too much at once": "you take on too much at once"
        default: "you struggle to keep your momentum"
        }
    }

    private func answer(at index: Int, fallback: String) -> String {
        guard answers.indices.contains(index), let answer = answers[index], !answer.isEmpty else {
            return fallback
        }
        return answer
    }
}

struct RoutineFunnelBrandHeader: View {
    var body: some View {
        HStack(spacing: RoutineSpacing.xs) {
            RoutineLogo(size: .small)
            Text(AppConfig.displayName)
                .font(RoutineTypography.funnelBody)
                .foregroundStyle(RoutineColors.primaryText)
        }
        .accessibilityElement(children: .combine)
        .frame(height: 30, alignment: .leading)
    }
}

struct RoutineFunnelContextHeader: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: RoutineSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(RoutineColors.primaryText)
                .accessibilityHidden(true)

            Text(title)
                .font(RoutineTypography.funnelTitle)
                .foregroundStyle(RoutineColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(title.replacingOccurrences(of: "\n", with: " "))

            Text(subtitle)
                .font(RoutineTypography.funnelSubtitle)
                .foregroundStyle(RoutineColors.funnelSecondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
