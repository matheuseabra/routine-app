import SwiftUI

struct QuizView: View {
    @Binding var name: String
    @Binding var answers: [String?]
    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var questionIndex: Int
    @State private var swipeHaptic = 0

    init(
        name: Binding<String>,
        answers: Binding<[String?]>,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        _name = name
        _answers = answers
        self.onBack = onBack
        self.onContinue = onContinue
        let requestedStep = arguments.firstIndex(of: "-quiz-question")
            .flatMap { arguments.indices.contains($0 + 1) ? Int(arguments[$0 + 1]) : nil } ?? 1
        _questionIndex = State(initialValue: min(max(requestedStep, 1), 5) - 1)
    }

    private let questions = [
        QuizQuestion(
            prompt: "What would you most like to improve?",
            subtitle: "Choose the outcome that matters most to you right now.",
            options: [
                QuizOption(title: "Stay more consistent", icon: "repeat"),
                QuizOption(title: "Get more done", icon: "checkmark.circle"),
                QuizOption(title: "Feel more focused", icon: "scope"),
                QuizOption(title: "Build healthier habits", icon: "heart"),
                QuizOption(title: "Create a better daily routine", icon: "calendar")
            ]
        ),
        QuizQuestion(
            prompt: "What usually gets in the way?",
            subtitle: "We’ll use this to make your plan easier to stick with.",
            options: [
                QuizOption(title: "I struggle with consistency", icon: "arrow.clockwise"),
                QuizOption(title: "I lose motivation", icon: "flame"),
                QuizOption(title: "I don’t know where to start", icon: "questionmark.circle"),
                QuizOption(title: "I don’t have enough time", icon: "clock"),
                QuizOption(title: "I try to do too much at once", icon: "list.bullet.rectangle")
            ]
        ),
        QuizQuestion(
            prompt: "How consistent do you feel right now?",
            subtitle: "Your starting point helps us shape the\nright plan.",
            options: [
                QuizOption(title: "Just starting", icon: "leaf"),
                QuizOption(title: "Starting again", icon: "arrow.counterclockwise"),
                QuizOption(title: "Somewhat consistent", icon: "chart.line.uptrend.xyaxis"),
                QuizOption(title: "Very consistent", icon: "checkmark.seal")
            ]
        ),
        QuizQuestion(
            prompt: "How much time can you realistically commit?",
            subtitle: "Consistency matters more than intensity.",
            options: [
                QuizOption(title: "5 minutes a day", icon: "timer"),
                QuizOption(title: "10–15 minutes", icon: "clock"),
                QuizOption(title: "20–30 minutes", icon: "clock.fill"),
                QuizOption(title: "My schedule changes often", icon: "calendar.badge.clock")
            ]
        ),
        QuizQuestion(prompt: "What should we call you?", options: [])
    ]

    var body: some View {
        RoutineScreenLayout(minimumBottomSafeArea: 32) {
            VStack(alignment: .leading, spacing: 0) {
                quizHeader
                    .padding(.top, RoutineSpacing.huge)
                    .padding(.bottom, RoutineSpacing.lg)

                Group {
                    if questionIndex == 4 {
                        nameQuestion
                    } else {
                        choiceQuestion
                    }
                }
                .id(questionIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer(minLength: 0)
            }
            .animation(.easeInOut(duration: 0.2), value: questionIndex)
        } bottom: {
            RoutinePrimaryButton(
                title: questionIndex == 4 ? "Create my plan" : "Continue",
                action: continueTapped,
                visualStyle: .funnel,
                isEnabled: canAdvance
            )
        }
        .contentShape(Rectangle())
        .highPriorityGesture(swipeGesture)
        .sensoryFeedback(.impact(weight: .light), trigger: swipeHaptic)
    }

    private var currentQuestion: QuizQuestion { questions[questionIndex] }
    private var canAdvance: Bool {
        if questionIndex == questions.count - 1 {
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        guard answers.indices.contains(questionIndex), let answer = answers[questionIndex] else { return false }
        return currentQuestion.options.contains { $0.title == answer }
    }

    private var quizHeader: some View {
        HStack(spacing: RoutineSpacing.lg) {
            Button(action: backTapped) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RoutineColors.primaryText)
                    .frame(width: 34, height: 24, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            RoutineProgressBar(progress: Double(questionIndex + 1) / 5, height: 3)
                .accessibilityElement()
                .accessibilityLabel("Quiz progress")
                .accessibilityValue("Question \(questionIndex + 1) of 5")
        }
    }

    private var choiceQuestion: some View {
        VStack(alignment: .leading, spacing: 0) {
            questionHeading
            optionList
        }
    }

    private var questionHeading: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.md) {
            Text(currentQuestion.prompt)
                .font(RoutineTypography.funnelTitle)
                .foregroundStyle(RoutineColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = currentQuestion.subtitle {
                Text(subtitle)
                    .font(RoutineTypography.funnelSubtitle)
                    .foregroundStyle(RoutineColors.funnelSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(subtitle.replacingOccurrences(of: "\n", with: " "))
                    .padding(.bottom, questionIndex == 2 ? RoutineSpacing.md + RoutineSpacing.xxs : RoutineSpacing.lg)
            } else {
                Color.clear.frame(height: RoutineSpacing.md)
            }
        }
        .padding(.bottom, RoutineSpacing.xs)
    }

    private var optionList: some View {
        VStack(spacing: RoutineSpacing.xs) {
            ForEach(currentQuestion.options) { option in
                optionButton(option)
            }
        }
    }

    private func optionButton(_ option: QuizOption) -> some View {
        let isSelected = answers[questionIndex] == option.title
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                answers[questionIndex] = option.title
            }
        } label: {
            HStack(spacing: RoutineSpacing.md) {
                Image(systemName: option.icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(isSelected ? RoutineColors.primaryText : RoutineColors.secondaryText)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                Text(option.title)
                    .font(RoutineTypography.funnelBodyMedium)
                    .foregroundStyle(RoutineColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
            .padding(.horizontal, RoutineSpacing.md)
            .background(isSelected ? RoutineColors.funnelSelection : RoutineColors.surface, in: RoundedRectangle(cornerRadius: 11))
            .shadow(color: RoutineColors.primaryText.opacity(0.07), radius: 4, x: 0, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: answers[questionIndex])
        .accessibilityLabel(option.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var nameQuestion: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.lg) {
            Text(currentQuestion.prompt)
                .font(RoutineTypography.funnelTitle)
                .foregroundStyle(RoutineColors.primaryText)

            TextField("Your name", text: $name)
                .font(RoutineTypography.funnelBody)
                .textInputAutocapitalization(.words)
                .submitLabel(.continue)
                .padding(.horizontal, RoutineSpacing.md)
                .frame(height: 52)
                .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 11))
                .overlay {
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(RoutineColors.border.opacity(0.85), lineWidth: 0.8)
                }
                .onSubmit(continueTapped)
                .accessibilityLabel("Your name")
        }
    }

    private func continueTapped() {
        guard canAdvance else { return }
        if questionIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                questionIndex += 1
            }
        } else {
            onContinue()
        }
    }

    private func backTapped() {
        if questionIndex > 0 {
            withAnimation(.easeInOut(duration: 0.2)) {
                questionIndex -= 1
            }
        } else {
            onBack()
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height),
                      abs(value.translation.width) > 50 else { return }
                swipeHaptic += 1
                if value.translation.width < 0, questionIndex < questions.count - 1, canAdvance {
                    withAnimation(.easeInOut(duration: 0.2)) { questionIndex += 1 }
                } else if value.translation.width > 0, questionIndex > 0 {
                    withAnimation(.easeInOut(duration: 0.2)) { questionIndex -= 1 }
                } else if value.translation.width > 0 {
                    onBack()
                }
            }
    }
}

private struct QuizQuestion {
    let prompt: String
    let subtitle: String?
    let options: [QuizOption]

    init(prompt: String, subtitle: String? = nil, options: [QuizOption] = []) {
        self.prompt = prompt
        self.subtitle = subtitle
        self.options = options
    }
}

private struct QuizOption: Identifiable {
    let title: String
    let icon: String

    var id: String { title }
}

#Preview("Quiz") {
    @Previewable @State var name = "Matheus"
    @Previewable @State var answers: [String?] = [nil, nil, "Starting again", "10–15 minutes", nil]
    QuizView(name: $name, answers: $answers, onBack: {}, onContinue: {})
}
