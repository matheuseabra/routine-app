import SwiftUI
import PhosphorSwift

enum RoutineIconName: Hashable {
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

    var phosphor: Ph {
        switch self {
        case .arrowLeft: .arrowLeft
        case .arrowsClockwise: .arrowsClockwise
        case .bell: .bell
        case .brain: .brain
        case .calendarCheck: .calendarCheck
        case .chartBar: .chartBar
        case .chartLineUp: .chartLineUp
        case .check: .check
        case .clock: .clock
        case .creditCard: .creditCard
        case .crown: .crown
        case .fileText: .fileText
        case .house: .house
        case .magnifyingGlass: .magnifyingGlass
        case .moon: .moon
        case .moonStars: .moonStars
        case .user: .user
        case .plus: .plus
        case .question: .question
        case .shieldCheck: .shieldCheck
        case .sliders: .sliders
        case .star: .star
        case .sun: .sun
        case .sunHorizon: .sunHorizon
        case .target: .target
        case .trash: .trash
        case .caretRight: .caretRight
        case .x: .x
        case .clipboardText: .clipboardText
        case .cloudCheck: .cloudCheck
        case .gear: .gear
        case .listChecks: .listChecks
        case .personSimpleRun: .personSimpleRun
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

    var phosphor: Ph.IconWeight {
        switch self {
        case .regular: .regular
        case .thin: .thin
        case .light: .light
        case .bold: .bold
        case .fill: .fill
        case .duotone: .duotone
        }
    }
}

struct RoutineIcon: View {
    let name: RoutineIconName
    var weight: RoutineIconWeight = .regular
    var color: Color = RoutineColors.primaryText

    init(_ name: RoutineIconName, weight: RoutineIconWeight = .regular, color: Color = RoutineColors.primaryText) {
        self.name = name
        self.weight = weight
        self.color = color
    }

    var body: some View {
        name.phosphor
            .weight(weight.phosphor)
            .color(color)
            .aspectRatio(contentMode: .fit)
    }
}
