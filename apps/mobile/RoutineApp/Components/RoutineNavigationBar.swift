import SwiftUI

struct RoutineNavItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void
    @State private var hapticTrigger = 0
    var body: some View {
        Button {
            guard !isSelected else { return }
            hapticTrigger += 1
            action()
        } label: {
            RoutineIcon(
                tab.icon,
                weight: isSelected ? .bold : .regular,
                color: isSelected ? RoutineColors.primaryText : RoutineColors.secondaryText
            )
            .frame(width: 22, height: 22)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
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
        HStack(alignment: .center, spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                if tab == .add {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .accessibilityHidden(true)
                } else {
                    RoutineNavItem(tab: tab, isSelected: selectedTab == tab) {
                        if reduceMotion {
                            selectedTab = tab
                        } else {
                            withAnimation(.easeInOut(duration: 0.14)) { selectedTab = tab }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, RoutineSpacing.xs)
        .background(RoutineColors.background)
        .overlay(alignment: .top) {
            Button {
                hapticTrigger += 1
                onAdd()
            } label: {
                RoutineIcon(.plus, weight: .bold, color: RoutineColors.inverseText)
                    .frame(width: 24, height: 24)
                    .frame(width: 54, height: 54)
                    .background(RoutineColors.primaryText, in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
            .accessibilityLabel("Add task")
            .offset(y: -27)
        }
    }

    @State private var hapticTrigger = 0
}
