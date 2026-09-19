import SwiftUI

enum RoutineTypography {
    private static let regular = "Geist-Regular"
    private static let medium = "Geist-Medium"
    private static let bold = "Geist-Bold"

    static let screenTitle = Font.custom(bold, size: 28, relativeTo: .title)
    static let compactTitle = Font.custom(bold, size: 22, relativeTo: .title2)
    static let sectionTitle = Font.custom(medium, size: 20, relativeTo: .title3)
    static let body = Font.custom(regular, size: 17, relativeTo: .body)
    static let bodyMedium = Font.custom(medium, size: 17, relativeTo: .body)
    static let secondary = Font.custom(regular, size: 15, relativeTo: .subheadline)
    static let small = Font.custom(medium, size: 12, relativeTo: .caption)
    static let smallRegular = Font.custom(regular, size: 12, relativeTo: .caption)
    static let button = Font.custom(medium, size: 17, relativeTo: .body)
    static let appName = Font.custom(medium, size: 17, relativeTo: .body)
    static let price = Font.custom(regular, size: 16, relativeTo: .body)
    static let timelineTitle = Font.custom(medium, size: 16, relativeTo: .body)
    static let timelineIndex = Font.custom(bold, size: 13, relativeTo: .caption)
    static let metric = Font.custom(bold, size: 22, relativeTo: .title2)
    static let chartLabel = Font.custom(regular, size: 10, relativeTo: .caption)
    static let settingsTitle = Font.custom(medium, size: 24, relativeTo: .title2)
    static let settingsRow = Font.custom(regular, size: 15, relativeTo: .body)
}
