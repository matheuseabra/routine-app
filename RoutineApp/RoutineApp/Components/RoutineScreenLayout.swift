import UIKit
import SwiftUI

struct RoutineScreenLayout<Content: View, Bottom: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var scrolls = false
    var contentAlignment: Alignment = .center
    var minimumBottomSafeArea: CGFloat = 0
    @ViewBuilder let content: Content
    @ViewBuilder let bottom: Bottom

    var body: some View {
        ZStack {
            RoutineColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                if scrolls || dynamicTypeSize.isAccessibilitySize {
                    GeometryReader { geometry in
                        ScrollView {
                            content
                                .frame(maxWidth: .infinity)
                                .frame(
                                    minHeight: dynamicTypeSize.isAccessibilitySize
                                        ? max(620, geometry.size.height)
                                        : geometry.size.height,
                                    alignment: contentAlignment
                                )
                                .padding(.horizontal, RoutineSpacing.lg)
                        }
                        .scrollIndicators(.hidden)
                    }
                } else {
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: contentAlignment)
                        .padding(.horizontal, RoutineSpacing.lg)
                }
                bottom
                    .padding(.horizontal, RoutineSpacing.lg)
                    .padding(.top, RoutineSpacing.md)
                    .padding(.bottom, bottomSafeAreaPadding)
            }
        }
    }

    private var bottomSafeAreaPadding: CGFloat {
        guard minimumBottomSafeArea > 0 else { return 0 }
        let safeAreaBottom = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 0
        return max(0, minimumBottomSafeArea - safeAreaBottom)
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
