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
                .font(RoutineTypography.appName)
                .foregroundStyle(RoutineColors.primaryText)
        }
        .accessibilityElement(children: .combine)
        .frame(maxWidth: .infinity, minHeight: 30, alignment: .center)
    }
}

struct RoutineFunnelContextHeader: View {
    let icon: String
    let title: String
    var successBadgeIcon: String? = nil

    var body: some View {
        VStack(spacing: RoutineSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(RoutineColors.primaryText)
                .overlay(alignment: .bottomTrailing) {
                    if let successBadgeIcon {
                        Image(systemName: successBadgeIcon)
                            .font(.system(size: 10, weight: .bold))
                            .padding(3)
                            .background(RoutineColors.background, in: Circle())
                            .offset(x: 4, y: 3)
                    }
                }
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)

            Text(title)
                .font(RoutineTypography.funnelTitle)
                .foregroundStyle(RoutineColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(title.replacingOccurrences(of: "\n", with: " "))
        }
        .frame(maxWidth: .infinity)
    }
}
