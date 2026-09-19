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
}

@Observable
final class AppRouter {
    var screen: RoutineScreen
    var name = ""
    var quizAnswers = Array<String?>(repeating: nil, count: 5)

    let usesScreenOverride: Bool

    init(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        hasCompletedOnboarding: Bool = false
    ) {
        if let screenIndex = arguments.firstIndex(of: "-screen"),
           arguments.indices.contains(screenIndex + 1),
           let requestedScreen = RoutineScreen(rawValue: arguments[screenIndex + 1]) {
            screen = requestedScreen
            usesScreenOverride = true
        } else {
            screen = hasCompletedOnboarding ? .paywall : .launch
            usesScreenOverride = false
        }
    }

    func advance(authEnabled: Bool = AppConfig.authenticationEnabled) {
        switch screen {
        case .launch: screen = .onboarding
        case .onboarding: screen = .quiz
        case .quiz: screen = .plan
        case .plan: screen = authEnabled ? .authentication : .paywall2
        case .authentication: screen = .paywall2
        case .paywall2: screen = .reminder
        case .reminder: screen = .paywall
        case .paywall: screen = .main
        case .main: break
        }
    }

    func goBack(authEnabled: Bool = AppConfig.authenticationEnabled) {
        switch screen {
        case .launch: break
        case .onboarding: screen = .launch
        case .quiz: screen = .onboarding
        case .plan: screen = .quiz
        case .authentication: screen = .plan
        case .paywall2: screen = authEnabled ? .authentication : .plan
        case .reminder: screen = .paywall2
        case .paywall: screen = .reminder
        case .main: screen = .paywall
        }
    }

    func resolveReturningSession(hasActiveEntitlement: Bool) {
        guard !usesScreenOverride else { return }
        screen = hasActiveEntitlement ? .main : .paywall
    }
}

struct RoutineRootView: View {
    @Environment(AppServices.self) private var services

    @State private var appState: AppState
    @State private var router: AppRouter
    @State private var swipeHaptic = 0
    @State private var transitionDirection: Edge = .trailing

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        let appState = AppState()
        _appState = State(initialValue: appState)
        _router = State(initialValue: AppRouter(
            arguments: arguments,
            hasCompletedOnboarding: appState.hasCompletedOnboarding
        ))
    }

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
                        QuizView(
                            name: $router.name,
                            answers: $router.quizAnswers,
                            onBack: goBackScreen,
                            onContinue: advanceScreen
                        )
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
        .task {
            await resolveReturningSession()
        }
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
            let previousScreen = router.screen
            router.advance(authEnabled: AppConfig.authenticationEnabled)

            if previousScreen == .paywall, router.screen == .main {
                appState.completeOnboarding()
            }
        }
    }

    private func goBackScreen() {
        withAnimation(.easeInOut(duration: 0.2)) {
            transitionDirection = .leading
            router.goBack(authEnabled: AppConfig.authenticationEnabled)
        }
    }

    private func resolveReturningSession() async {
        guard appState.hasCompletedOnboarding, !router.usesScreenOverride else { return }
        let hasActiveEntitlement = await services.subscriptions.hasActiveEntitlement()

        withAnimation(.easeInOut(duration: 0.2)) {
            router.resolveReturningSession(hasActiveEntitlement: hasActiveEntitlement)
        }
    }
}
