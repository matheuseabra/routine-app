import SwiftUI

struct QuizView: View {
    @Binding var name: String
    @Binding var answers: [String?]
    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var questionIndex = 0
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
        let requestedIndex = arguments.firstIndex(of: "-quiz-question")
            .flatMap { arguments.indices.contains($0 + 1) ? Int(arguments[$0 + 1]) : nil } ?? 1
        _questionIndex = State(initialValue: min(max(requestedIndex - 1, 0), 4))
    }

    private let questions = [
        QuizQuestion(
            prompt: "What should we\ncall you?",
            subtitle: "We’ll use your name to personalize your routine.",
            options: []
        ),
        QuizQuestion(prompt: "What are your\nmain goals?", options: [
            QuizOption(title: "Better focus", icon: .brain),
            QuizOption(title: "Move more", icon: .personSimpleRun),
            QuizOption(title: "Sleep better", icon: .moonStars),
            QuizOption(title: "Stay organized", icon: .listChecks)
        ]),
        QuizQuestion(prompt: "When do you feel\nmost productive?", options: [
            QuizOption(title: "Morning", icon: .sun),
            QuizOption(title: "Afternoon", icon: .sunHorizon),
            QuizOption(title: "Evening", icon: .moon),
            QuizOption(title: "It varies", icon: .arrowsClockwise)
        ]),
        QuizQuestion(prompt: "How much time can you\ndedicate each day?", options: [
            QuizOption(title: "5 minutes"),
            QuizOption(title: "15 minutes"),
            QuizOption(title: "30 minutes"),
            QuizOption(title: "An hour or more")
        ]),
        QuizQuestion(prompt: "What would help you\nstay consistent?", options: [
            QuizOption(title: "Gentle reminders", icon: .bell),
            QuizOption(title: "A clear plan", icon: .calendarCheck),
            QuizOption(title: "Progress insights", icon: .chartLineUp),
            QuizOption(title: "All of the above", icon: .star)
        ])
    ]

    var body: some View {
        RoutineScreenLayout {
            VStack(alignment: .leading, spacing: 0) {
                quizHeader
                    .padding(.top, RoutineSpacing.md)
                    .padding(.bottom, RoutineSpacing.huge)
                Group {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(currentQuestion.prompt)
                            .routineTitleStyle()
                            .padding(.bottom, currentQuestion.subtitle == nil ? RoutineSpacing.lg : RoutineSpacing.sm)
                        if let subtitle = currentQuestion.subtitle {
                            Text(subtitle)
                                .routineSubtitleStyle()
                                .padding(.bottom, RoutineSpacing.lg)
                        }
                        if questionIndex == 0 {
                            nameInput
                        } else {
                            optionList
                        }
                    }
                }
                .id(questionIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                Spacer()
            }
            .animation(.easeInOut(duration: 0.2), value: questionIndex)
        } bottom: {
            RoutinePrimaryButton(title: "Continue", action: continueTapped)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(swipeGesture)
        .sensoryFeedback(.impact(weight: .light), trigger: swipeHaptic)
    }

    private var currentQuestion: QuizQuestion { questions[questionIndex] }

    private var quizHeader: some View {
        HStack(spacing: RoutineSpacing.md) {
            Button(action: backTapped) {
                RoutineIcon(.arrowLeft, weight: .bold)
                    .frame(width: 17, height: 17)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
            RoutineProgressBar(progress: Double(questionIndex + 1) / 5, height: 5)
            Text("\(questionIndex + 1) / 5")
                .font(RoutineTypography.small)
                .frame(width: 38, alignment: .trailing)
        }
    }

    private var nameInput: some View {
        TextField("Your name", text: $name)
            .font(RoutineTypography.body)
            .textInputAutocapitalization(.words)
            .submitLabel(.continue)
            .padding(.horizontal, RoutineSpacing.md)
            .frame(height: 56)
            .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(RoutineColors.border, lineWidth: 1)
            }
            .onSubmit(continueTapped)
            .accessibilityLabel("Your name")
    }

    private var optionList: some View {
        VStack(spacing: RoutineSpacing.sm) {
            ForEach(currentQuestion.options) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        answers[questionIndex] = option.title
                    }
                } label: {
                    HStack(spacing: RoutineSpacing.md) {
                        if let icon = option.icon {
                            RoutineIcon(icon, color: RoutineColors.secondaryText)
                                .frame(width: 24, height: 24)
                        }
                        Text(option.title)
                            .font(RoutineTypography.body)
                        Spacer()
                    }
                    .padding(.horizontal, RoutineSpacing.md)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    .foregroundStyle(RoutineColors.primaryText)
                    .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        if answers[questionIndex] == option.title {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(RoutineColors.primaryText, lineWidth: 1.5)
                        }
                    }
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: answers[questionIndex])
                .accessibilityLabel(option.title)
                .accessibilityValue(answers[questionIndex] == option.title ? "Selected" : "Not selected")
            }
        }
    }

    private func backTapped() {
        if questionIndex == 0 {
            onBack()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                questionIndex -= 1
            }
        }
    }

    private func continueTapped() {
        if questionIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                questionIndex += 1
            }
        } else {
            onContinue()
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height),
                      abs(value.translation.width) > 50 else { return }
                swipeHaptic += 1
                if value.translation.width < 0, questionIndex < questions.count - 1 {
                    withAnimation(.easeInOut(duration: 0.2)) { questionIndex += 1 }
                } else if value.translation.width > 0, questionIndex > 0 {
                    withAnimation(.easeInOut(duration: 0.2)) { questionIndex -= 1 }
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
    let icon: RoutineIconName?

    var id: String { title }

    init(title: String, icon: RoutineIconName? = nil) {
        self.title = title
        self.icon = icon
    }
}

#Preview("Quiz") {
    @Previewable @State var name = "Matheus"
    @Previewable @State var answers = Array<String?>(repeating: nil, count: 5)
    QuizView(name: $name, answers: $answers, onBack: {}, onContinue: {})
}
