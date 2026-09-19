import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTaskFieldFocused: Bool
    @State private var taskTitle = ""
    @State private var hapticTrigger = 0
    let onAdd: (String) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: RoutineSpacing.sm) {
            HStack(spacing: RoutineSpacing.sm) {
                RoutineIcon(.plus, weight: .regular)
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
                TextField("Task name", text: $taskTitle)
                    .focused($isTaskFieldFocused)
                    .font(RoutineTypography.body)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .background(Color.clear)
                    .accessibilityLabel("Task name")
            }
            .background(Color.clear)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 52)
            .contentShape(Rectangle())
            .onSubmit(addTask)
            Button {
                hapticTrigger += 1
                addTask()
            } label: {
                RoutineIcon(.check, weight: .bold, color: RoutineColors.inverseText)
                    .frame(width: 20, height: 20)
                    .frame(width: 48, height: 48)
                    .background(RoutineColors.primaryText, in: Capsule())
                    .opacity(isTaskTitleEmpty ? 0.4 : 1)
            }
            .buttonStyle(.plain)
            .disabled(isTaskTitleEmpty)
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
            .accessibilityLabel("Add task")
        }
        .padding(.horizontal, RoutineSpacing.lg)
        .padding(.vertical, RoutineSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.clear.ignoresSafeArea())
        .presentationDetents([.height(96)])
        .presentationDragIndicator(.visible)
        .defaultFocus($isTaskFieldFocused, true)
        .task {
            isTaskFieldFocused = true
        }
    }

    private var isTaskTitleEmpty: Bool {
        taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addTask() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        onAdd(trimmedTitle)
        dismiss()
    }
}

#Preview("Add task") {
    AddTaskSheet { _ in }
}
