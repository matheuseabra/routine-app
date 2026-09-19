import SwiftUI

struct RoutineScreenLayout<Content: View, Bottom: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var scrolls = false
    var contentAlignment: Alignment = .center
    @ViewBuilder let content: Content
    @ViewBuilder let bottom: Bottom

    var body: some View {
        ZStack {
            RoutineColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                if scrolls || dynamicTypeSize.isAccessibilitySize {
                    ScrollView {
                        content
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 620 : 0)
                            .padding(.horizontal, RoutineSpacing.lg)
                    }
                    .scrollIndicators(.hidden)
                } else {
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: contentAlignment)
                        .padding(.horizontal, RoutineSpacing.lg)
                }
                bottom
                    .padding(.horizontal, RoutineSpacing.lg)
                    .padding(.top, RoutineSpacing.md)
            }
        }
    }
}

extension View {
    func routineTitleStyle() -> some View {
        font(RoutineTypography.screenTitle)
            .foregroundStyle(RoutineColors.primaryText)
            .tracking(-0.5)
    }

    func routineSubtitleStyle() -> some View {
        font(RoutineTypography.secondary)
            .foregroundStyle(RoutineColors.secondaryText)
    }
}
