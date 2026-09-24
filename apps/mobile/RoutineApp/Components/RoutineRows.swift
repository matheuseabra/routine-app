import SwiftUI

struct RoutinePricingCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    @State private var hapticTrigger = 0

    var body: some View {
        Button {
            hapticTrigger += 1
            action()
        } label: {
            HStack(spacing: RoutineSpacing.sm) {
                Text(plan.displayName)
                    .font(RoutineTypography.button)
                Text(plan.priceDescription)
                    .font(RoutineTypography.price)
                    .foregroundStyle(RoutineColors.secondaryText)
                Spacer()
                RoutineRadioButton(isSelected: isSelected)
            }
            .padding(.horizontal, RoutineSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .foregroundStyle(RoutineColors.primaryText)
            .background(
                isSelected ? RoutineColors.funnelSelection : RoutineColors.surface,
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .accessibilityLabel("\(plan.displayName), \(plan.priceDescription)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

struct RoutineTimelineStep: Identifiable {
    let id: String
    let icon: RoutineIconName
    let title: String
    let subtitle: String
    let trailingIcon: RoutineIconName?

    init(icon: RoutineIconName, title: String, subtitle: String, trailingIcon: RoutineIconName? = nil) {
        self.id = title
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailingIcon = trailingIcon
    }
}

struct RoutineTimeline: View {
    let steps: [RoutineTimelineStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: RoutineSpacing.md) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(RoutineColors.primaryText)
                            RoutineIcon(step.icon, weight: .regular, color: RoutineColors.inverseText)
                                .frame(width: 14, height: 14)
                        }
                        .frame(width: 32, height: 32)
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(RoutineColors.primaryText)
                                .frame(width: 2, height: 48)
                        }
                    }
                    VStack(alignment: .leading, spacing: RoutineSpacing.xxs) {
                        HStack(spacing: RoutineSpacing.xs) {
                            Text(step.title)
                                .font(RoutineTypography.timelineTitle)
                            if let trailingIcon = step.trailingIcon {
                                RoutineIcon(trailingIcon)
                                    .frame(width: 13, height: 13)
                            }
                        }
                        Text(step.subtitle)
                            .font(RoutineTypography.secondary)
                            .foregroundStyle(RoutineColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, index < steps.count - 1 ? RoutineSpacing.md : 0)
                    Spacer(minLength: 0)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct RoutineTaskRow: View {
    let task: RoutineTask
    let onEdit: () -> Void
    let onDelete: () -> Void
    let action: () -> Void
    @State private var isCompleting = false

    var body: some View {
        HStack(spacing: RoutineSpacing.xs) {
            Button {
                guard !task.isCompleted else {
                    action()
                    return
                }

                isCompleting = true
                Task {
                    do {
                        try await Task.sleep(for: .milliseconds(350))
                    } catch {
                        isCompleting = false
                        return
                    }
                    withAnimation(.easeOut(duration: 0.3)) {
                        action()
                        isCompleting = false
                    }
                }
            } label: {
                HStack(spacing: RoutineSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(task.isCompleted ? RoutineColors.primaryText : .clear)
                        Circle()
                            .stroke(task.isCompleted ? RoutineColors.primaryText : RoutineColors.tertiaryText, lineWidth: 1.3)
                        if task.isCompleted {
                            RoutineIcon(.check, color: RoutineColors.inverseText)
                                .frame(width: 9, height: 9)
                        }
                    }
                    .frame(width: 22, height: 22)
                    Text(task.title)
                        .font(RoutineTypography.body)
                        .foregroundStyle(task.isCompleted ? RoutineColors.secondaryText : RoutineColors.primaryText)
                    Spacer()
                }
                .frame(minHeight: 52)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(
                task.isCompleted ? .success : .impact(weight: .light),
                trigger: task.isCompleted
            )
            .disabled(isCompleting)
            .accessibilityLabel(task.title)
            .accessibilityValue(isCompleting ? "Completing" : (task.isCompleted ? "Completed" : "Not completed"))

            Menu {
                Button("Edit", systemImage: "pencil", action: onEdit)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                RoutineIcon(.ellipsis, color: RoutineColors.secondaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Actions for \(task.title)")
        }
        .transition(.opacity)
    }
}

struct RoutineSettingRow: View {
    let icon: RoutineIconName
    let title: String
    let textFont: Font
    let action: () -> Void
    @State private var hapticTrigger = 0

    init(
        icon: RoutineIconName,
        title: String,
        textFont: Font = RoutineTypography.body,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.textFont = textFont
        self.action = action
    }

    var body: some View {
        Button {
            hapticTrigger += 1
            action()
        } label: {
            HStack(spacing: RoutineSpacing.md) {
                RoutineIcon(icon)
                    .frame(width: 24)
                Text(title)
                    .font(textFont)
                Spacer()
                RoutineIcon(.caretRight, color: RoutineColors.tertiaryText)
                    .frame(width: 13, height: 13)
            }
            .frame(minHeight: 52)
            .foregroundStyle(RoutineColors.primaryText)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .accessibilityLabel(title)
    }
}
