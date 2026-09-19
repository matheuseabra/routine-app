import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void
    @State private var slideIndex: Int
    @State private var swipeHaptic = 0

    init(onContinue: @escaping () -> Void, arguments: [String] = ProcessInfo.processInfo.arguments) {
        self.onContinue = onContinue
        let requestedIndex = arguments.firstIndex(of: "-onboarding-slide")
            .flatMap { arguments.indices.contains($0 + 1) ? Int(arguments[$0 + 1]) : nil } ?? 0
        _slideIndex = State(initialValue: min(max(requestedIndex, 0), 2))
    }

    private let slides = [
        OnboardingSlide(
            headline: "Build better habits,\none day at a time.",
            subtitle: "Small changes today create\na brighter tomorrow.",
            icon: .brand
        ),
        OnboardingSlide(
            headline: "Make time for\nwhat matters.",
            subtitle: "A calm plan turns your intentions\ninto progress you can feel.",
            icon: .focus
        ),
        OnboardingSlide(
            headline: "Small habits,\nlasting change.",
            subtitle: "Stay consistent with gentle guidance\nthat fits your everyday life.",
            icon: .consistency
        )
    ]

    var body: some View {
        RoutineScreenLayout {
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                VStack(spacing: 0) {
                    VStack(spacing: slideIndex == 0 ? RoutineSpacing.sm : 0) {
                        RoutineOnboardingIcon(kind: slides[slideIndex].icon)
                        if slideIndex == 0 {
                        Text("Routine")
                                .font(RoutineTypography.compactTitle)
                                .foregroundStyle(RoutineColors.primaryText)
                        }
                    }
                        .padding(.bottom, RoutineSpacing.xl)
                    Text(slides[slideIndex].headline)
                        .routineTitleStyle()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, RoutineSpacing.md)
                    Text(slides[slideIndex].subtitle)
                        .routineSubtitleStyle()
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .id(slideIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                Spacer()
                RoutinePageIndicator(count: slides.count, selectedIndex: slideIndex)
                    .padding(.bottom, RoutineSpacing.sm)
            }
            .animation(.easeInOut(duration: 0.2), value: slideIndex)
        } bottom: {
            RoutinePrimaryButton(title: slideIndex == 0 ? "Get started" : "Continue", action: continueTapped)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(swipeGesture)
        .sensoryFeedback(.impact(weight: .light), trigger: swipeHaptic)
    }

    private func continueTapped() {
        if slideIndex < slides.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                slideIndex += 1
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
                if value.translation.width < 0, slideIndex < slides.count - 1 {
                    withAnimation(.easeInOut(duration: 0.2)) { slideIndex += 1 }
                } else if value.translation.width > 0, slideIndex > 0 {
                    withAnimation(.easeInOut(duration: 0.2)) { slideIndex -= 1 }
                }
            }
    }
}

private struct OnboardingSlide {
    let headline: String
    let subtitle: String
    let icon: RoutineOnboardingIcon.Kind
}

#Preview("Onboarding") {
    OnboardingView {}
}
