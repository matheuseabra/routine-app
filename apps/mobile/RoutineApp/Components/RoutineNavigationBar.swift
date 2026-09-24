import SwiftUI

struct RoutineNavItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void
    @State private var hapticTrigger = 0

    var body: some View {
        Button {
            hapticTrigger += 1
            action()
        } label: {
            RoutineIcon(
                tab.icon,
                weight: .bold,
                color: isSelected ? RoutineColors.primaryText : RoutineColors.tertiaryText
            )
            .frame(width: 21, height: 21)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

}

struct RoutineNavigationBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var selectedTab: AppTab
    let onAdd: () -> Void

    init(selectedTab: Binding<AppTab>, onAdd: @escaping () -> Void = {}) {
        _selectedTab = selectedTab
        self.onAdd = onAdd
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                if tab == .add {
                    Button {
                        hapticTrigger += 1
                        onAdd()
                    } label: {
                        RoutineIcon(.plus, weight: .bold, color: RoutineColors.inverseText)
                            .frame(width: 23, height: 23)
                            .frame(width: 52, height: 52)
                            .background(RoutineColors.primaryText, in: Circle())
                            .offset(y: -38)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
                    .accessibilityLabel("Add")
                } else {
                    RoutineNavItem(tab: tab, isSelected: selectedTab == tab) {
                        if reduceMotion {
                            selectedTab = tab
                        } else {
                            withAnimation(.easeInOut(duration: 0.18)) { selectedTab = tab }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, RoutineSpacing.xs)
        .padding(.top, RoutineSpacing.xs)
        .background(RoutineColors.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(RoutineColors.border)
                .frame(height: 1)
        }
    }

    @State private var hapticTrigger = 0
}
