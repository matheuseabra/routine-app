import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTaskFieldFocused: Bool
    @State private var taskTitle = ""
    @State private var hapticTrigger = 0
    let onAdd: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.sm) {
            TextField("Task name", text: $taskTitle)
                .focused($isTaskFieldFocused)
                .font(RoutineTypography.body)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .frame(height: 44)
                .accessibilityLabel("Task name")
                .onSubmit(addTask)

            HStack {
                Spacer()
                Button {
                    hapticTrigger += 1
                    addTask()
                } label: {
                    RoutineIcon(.arrowUp, weight: .bold, color: RoutineColors.inverseText)
                        .frame(width: 16, height: 16)
                        .frame(width: 40, height: 40)
                        .background(RoutineColors.primaryText, in: Circle())
                        .opacity(isTaskTitleEmpty ? 0.4 : 1)
                }
                .buttonStyle(.plain)
                .disabled(isTaskTitleEmpty)
                .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
                .accessibilityLabel("Add task")
            }
        }
        .padding(.horizontal, RoutineSpacing.lg)
        .padding(.bottom, RoutineSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear.ignoresSafeArea())
        .presentationDetents([.height(132)])
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
