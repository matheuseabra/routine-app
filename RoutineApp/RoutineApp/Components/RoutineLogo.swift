import SwiftUI

private struct RoutineOrbit: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = min(rect.width, rect.height) * 0.12
        let orbitRect = rect.insetBy(dx: inset, dy: inset)
        var path = Path()
        path.addEllipse(in: orbitRect)
        return path
    }
}

struct RoutineLogo: View {
    enum Size {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: 28
            case .medium: 66
            case .large: 82
            }
        }
    }

    var size: Size = .medium

    var body: some View {
        RoutineOrbit()
            .stroke(RoutineColors.primaryText, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size.dimension, height: size.dimension)
            .accessibilityLabel("Routine")
    }

    private var lineWidth: CGFloat { size == .small ? 3 : 4 }
}

struct RoutineBranding: View {
    let title: String

    init(title: String = "Routine") {
        self.title = title
    }

    var body: some View {
        HStack(spacing: RoutineSpacing.xs) {
            RoutineLogo(size: .small)
            Text(title)
                .font(RoutineTypography.appName)
        }
        .accessibilityElement(children: .combine)
    }
}

struct RoutineOnboardingIcon: View {
    enum Kind {
        case brand
        case focus
        case consistency
    }

    let kind: Kind

    var body: some View {
        Group {
            switch kind {
            case .brand:
                RoutineLogo(size: .medium)
            case .focus:
                RoutineIcon(.clock, weight: .regular)
            case .consistency:
                RoutineIcon(.arrowsClockwise, weight: .regular)
            }
        }
        .foregroundStyle(RoutineColors.primaryText)
        .frame(width: 66, height: 66)
        .accessibilityHidden(true)
    }
}
