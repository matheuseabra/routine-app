import SwiftUI

enum RoutineIconName: Hashable {
    case arrowUp
    case arrowLeft
    case arrowsClockwise
    case bell
    case brain
    case calendarCheck
    case chartBar
    case chartLineUp
    case check
    case clock
    case creditCard
    case crown
    case fileText
    case house
    case magnifyingGlass
    case moon
    case moonStars
    case user
    case plus
    case question
    case shieldCheck
    case sliders
    case star
    case sun
    case sunHorizon
    case target
    case trash
    case caretRight
    case x
    case clipboardText
    case cloudCheck
    case gear
    case listChecks
    case personSimpleRun

    var systemName: String {
        switch self {
        case .arrowUp: "arrow.up"
        case .arrowLeft: "arrow.left"
        case .arrowsClockwise: "arrow.clockwise"
        case .bell: "bell"
        case .brain: "brain"
        case .calendarCheck: "calendar.badge.checkmark"
        case .chartBar: "chart.bar"
        case .chartLineUp: "chart.line.uptrend.xyaxis"
        case .check: "checkmark"
        case .clock: "clock"
        case .creditCard: "creditcard"
        case .crown: "crown"
        case .fileText: "doc.text"
        case .house: "house"
        case .magnifyingGlass: "magnifyingglass"
        case .moon: "moon"
        case .moonStars: "moon.stars"
        case .user: "person"
        case .plus: "plus"
        case .question: "questionmark"
        case .shieldCheck: "checkmark.shield"
        case .sliders: "slider.horizontal.3"
        case .star: "star"
        case .sun: "sun.max"
        case .sunHorizon: "sun.horizon"
        case .target: "target"
        case .trash: "trash"
        case .caretRight: "chevron.right"
        case .x: "xmark"
        case .clipboardText: "list.clipboard"
        case .cloudCheck: "checkmark.icloud"
        case .gear: "gearshape"
        case .listChecks: "checklist"
        case .personSimpleRun: "figure.run"
        }
    }
}

enum RoutineIconWeight {
    case regular
    case thin
    case light
    case bold
    case fill
    case duotone

    var fontWeight: Font.Weight {
        switch self {
        case .thin: .thin
        case .light: .light
        case .bold: .bold
        case .regular, .fill, .duotone: .regular
        }
    }
}

struct RoutineIcon: View {
    let name: RoutineIconName
    var weight: RoutineIconWeight = .regular
    var color: Color = RoutineColors.primaryText
    var pointSize: CGFloat?

    init(
        _ name: RoutineIconName,
        weight: RoutineIconWeight = .regular,
        color: Color = RoutineColors.primaryText,
        pointSize: CGFloat? = nil
    ) {
        self.name = name
        self.weight = weight
        self.color = color
        self.pointSize = pointSize
    }

    @ViewBuilder
    var body: some View {
        switch weight {
        case .fill:
            symbol
                .symbolVariant(.fill)
        case .duotone:
            symbol
                .symbolRenderingMode(.hierarchical)
        default:
            symbol
        }
    }

    private var symbol: some View {
        Image(systemName: name.systemName)
            .font(pointSize.map { .system(size: $0, weight: weight.fontWeight) })
            .fontWeight(weight.fontWeight)
            .foregroundStyle(color)
            .aspectRatio(contentMode: .fit)
    }
}
