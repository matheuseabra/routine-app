import SwiftUI

struct RoutinePrimaryButton: View {
    enum VisualStyle: Equatable {
        case standard
        case funnel
    }

    let title: String
    let action: () -> Void
    var visualStyle: VisualStyle = .standard
    var isEnabled = true
    @State private var hapticTrigger = 0

    var body: some View {
        Button {
            hapticTrigger += 1
            action()
        } label: {
            Text(title)
                .font(visualStyle == .funnel ? RoutineTypography.funnelButton : RoutineTypography.button)
                .frame(maxWidth: .infinity)
                .frame(height: visualStyle == .funnel ? 48 : 54)
                .foregroundStyle(isEnabled ? RoutineColors.inverseText : RoutineColors.primaryText)
                .background {
                    if visualStyle == .funnel {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(isEnabled ? RoutineColors.primaryText : RoutineColors.track)
                    } else {
                        RoundedRectangle(cornerRadius: 12).fill(isEnabled ? RoutineColors.primaryText : RoutineColors.track)
                    }
                }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: visualStyle == .funnel ? 10 : 12, style: .continuous))
        .disabled(!isEnabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
        .accessibilityLabel(title)
    }
}

struct RoutineSecondaryButton: View {
    enum Style: Equatable {
        case outlined
        case filled
    }

    let title: String
    var icon: RoutineIconName?
    var assetImage: String?
    var style: Style
    let action: () -> Void
    @State private var hapticTrigger = 0

    init(
        title: String,
        icon: RoutineIconName? = nil,
        assetImage: String? = nil,
        style: Style = .outlined,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.assetImage = assetImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button {
            hapticTrigger += 1
            action()
        } label: {
            HStack(spacing: RoutineSpacing.sm) {
                if let assetImage {
                    Image(assetImage)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                } else if let icon {
                    RoutineIcon(icon, weight: .bold, color: foregroundColor)
                        .frame(width: 19, height: 19)
                }
                Text(title)
                    .font(RoutineTypography.button)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                if style == .outlined {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RoutineColors.primaryText.opacity(0.35), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTrigger)
        .accessibilityLabel(title)
    }

    private var foregroundColor: Color {
        style == .filled ? RoutineColors.inverseText : RoutineColors.primaryText
    }

    private var backgroundColor: Color {
        style == .filled ? RoutineColors.primaryText : RoutineColors.surface
    }
}

struct RoutineCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(RoutineSpacing.md)
            .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct RoutineProgressBar: View {
    let progress: Double
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(RoutineColors.track)
                Capsule()
                    .fill(RoutineColors.primaryText)
                    .frame(width: max(0, geometry.size.width * min(max(progress, 0), 1)))
                    .animation(.easeInOut(duration: 0.25), value: progress)
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

struct RoutinePageIndicator: View {
    let count: Int
    let selectedIndex: Int

    var body: some View {
        HStack(spacing: RoutineSpacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == selectedIndex ? RoutineColors.primaryText : RoutineColors.primaryText.opacity(0.16))
                    .frame(width: index == selectedIndex ? 24 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        .accessibilityLabel("Page \(selectedIndex + 1) of \(count)")
    }
}

struct RoutineRadioButton: View {
    let isSelected: Bool

    var body: some View {
        Circle()
            .stroke(isSelected ? RoutineColors.primaryText : RoutineColors.tertiaryText, lineWidth: 1.4)
            .background {
                if isSelected {
                    Circle()
                        .fill(RoutineColors.primaryText)
                        .padding(4)
                }
            }
            .frame(width: 22, height: 22)
            .accessibilityHidden(true)
    }
}
