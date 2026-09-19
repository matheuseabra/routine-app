import Observation
import SwiftUI

enum RoutineScreen: String, CaseIterable, Hashable {
    case launch
    case onboarding
    case quiz
    case plan
    case authentication
    case paywall2
    case reminder
    case paywall
    case main

    var next: RoutineScreen? {
        guard let index = Self.allCases.firstIndex(of: self), index + 1 < Self.allCases.count else {
            return nil
        }
        return Self.allCases[index + 1]
    }
}

@Observable
final class AppRouter {
    var screen: RoutineScreen
    var name = ""
    var quizAnswers = Array<String?>(repeating: nil, count: 5)

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        if let screenIndex = arguments.firstIndex(of: "-screen"),
           arguments.indices.contains(screenIndex + 1),
           let requestedScreen = RoutineScreen(rawValue: arguments[screenIndex + 1]) {
            screen = requestedScreen
        } else {
            screen = .launch
        }
    }

    func advance() {
        guard let nextScreen = screen.next else { return }
        screen = nextScreen
    }

    func goBack() {
        guard let index = RoutineScreen.allCases.firstIndex(of: screen), index > 0 else { return }
        screen = RoutineScreen.allCases[index - 1]
    }
}

struct RoutineRootView: View {
    @State private var router = AppRouter()
    @State private var swipeHaptic = 0
    @State private var transitionDirection: Edge = .trailing

    var body: some View {
        @Bindable var router = router

        NavigationStack {
            ZStack {
                Group {
                    switch router.screen {
                    case .launch:
                        LaunchView { advanceScreen() }
                    case .onboarding:
                        OnboardingView(onContinue: advanceScreen)
                    case .quiz:
                        QuizView(name: $router.name, answers: $router.quizAnswers, onBack: goBackScreen, onContinue: advanceScreen)
                    case .plan:
                        PlanView(onContinue: advanceScreen)
                    case .authentication:
                        AuthenticationView(onContinue: advanceScreen)
                    case .paywall2:
                        PaywallTrialReminderView(onContinue: advanceScreen)
                    case .reminder:
                        ReminderView(onContinue: advanceScreen)
                    case .paywall:
                        PaywallView(onContinue: advanceScreen)
                    case .main:
                        MainAppView()
                    }
                }
                .id(router.screen)
                .transition(.asymmetric(
                    insertion: .move(edge: transitionDirection).combined(with: .opacity),
                    removal: .move(edge: transitionDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                ))
            }
            .animation(.easeInOut(duration: 0.2), value: router.screen)
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(RoutineColors.primaryText)
        .contentShape(Rectangle())
        .highPriorityGesture(rootSwipeGesture)
        .sensoryFeedback(.impact(weight: .light), trigger: swipeHaptic)
    }

    private var rootSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                guard router.screen != .main, router.screen != .launch,
                      router.screen != .onboarding, router.screen != .quiz,
                      abs(value.translation.width) > abs(value.translation.height),
                      abs(value.translation.width) > 50 else { return }
                swipeHaptic += 1
                if value.translation.width < 0 {
                    advanceScreen()
                } else {
                    goBackScreen()
                }
            }
    }

    private func advanceScreen() {
        withAnimation(.easeInOut(duration: 0.2)) {
            transitionDirection = .trailing
            router.advance()
        }
    }

    private func goBackScreen() {
        withAnimation(.easeInOut(duration: 0.2)) {
            transitionDirection = .leading
            router.goBack()
        }
    }
}
