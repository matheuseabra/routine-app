import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTaskFieldFocused: Bool
    @State private var taskTitle: String
    @State private var hapticTrigger = 0
    let isEditing: Bool
    let onSave: (String) -> Void

    init(initialTitle: String = "", isEditing: Bool = false, onSave: @escaping (String) -> Void) {
        _taskTitle = State(initialValue: initialTitle)
        self.isEditing = isEditing
        self.onSave = onSave
    }

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
                .onSubmit(saveTask)

            HStack {
                Spacer()
                Button {
                    saveTask()
                } label: {
                    RoutineIcon(.arrowUp, weight: .bold, color: RoutineColors.inverseText)
                        .frame(width: 16, height: 16)
                        .frame(width: 40, height: 40)
                        .background(RoutineColors.primaryText, in: Circle())
                        .opacity(isTaskTitleEmpty ? 0.4 : 1)
                }
                .buttonStyle(.plain)
                .disabled(isTaskTitleEmpty)
                .sensoryFeedback(.success, trigger: hapticTrigger)
                .accessibilityLabel(isEditing ? "Save task" : "Add task")
                .accessibilityIdentifier("task-editor-save")
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

    private func saveTask() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        hapticTrigger += 1
        onSave(trimmedTitle)
        dismiss()
    }
}

#Preview("Add task") {
    AddTaskSheet(onSave: { _ in })
}
