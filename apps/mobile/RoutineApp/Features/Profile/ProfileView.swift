import SwiftUI

struct ProfileView: View {
    let userName: String
    let tasks: [RoutineTask]
    let checkIns: [RoutineCheckIn]
    let onOpenHabits: () -> Void

    @State private var isSettingsPresented = false
    @State private var settingsHapticTrigger = 0

    init(userName: String = "", tasks: [RoutineTask] = [], checkIns: [RoutineCheckIn] = [], onOpenHabits: @escaping () -> Void = {}) {
        self.userName = userName
        self.tasks = tasks
        self.checkIns = checkIns
        self.onOpenHabits = onOpenHabits
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.xl)
                profileCard
                RoutineSectionHeader(title: "Your activity")
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.sm)
                activityCard
                RoutineSectionHeader(title: "Recent history")
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.sm)
                recentHistoryCard
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.huge)
        }
        .scrollIndicators(.hidden)
        .background(RoutineColors.background)
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var summary: InsightSummary {
        InsightSummary.make(checkIns: checkIns)
    }

    private var header: some View {
        RoutinePageHeader(title: "Profile") {
            Button {
                settingsHapticTrigger += 1
                isSettingsPresented = true
            } label: {
                RoutineIcon(.gear)
                    .frame(width: 20, height: 20)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: settingsHapticTrigger)
            .accessibilityLabel("Settings")
        }
    }

    private var profileCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: RoutineSpacing.md) {
                Circle()
                    .fill(RoutineColors.primaryText.opacity(0.14))
                    .frame(width: 72, height: 72)
                    .overlay {
                        RoutineIcon(.user, weight: .regular, color: RoutineColors.secondaryText)
                            .frame(width: 38, height: 38)
                    }
                    .accessibilityHidden(true)

                Text(userName.isEmpty ? "Your routine" : userName)
                    .font(RoutineTypography.compactTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(RoutineSpacing.lg)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Profile for \(userName.isEmpty ? "your routine" : userName)")
    }

    private var activityCard: some View {
        HStack(spacing: 0) {
            profileStat(value: "\(tasks.count)", label: "Tasks")
            profileStat(value: "\(checkIns.count)", label: "Check-ins")
            profileStat(value: "\(summary.currentStreak)", label: "Day streak")
        }
        .padding(.vertical, RoutineSpacing.lg)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var recentHistoryCard: some View {
        Group {
            if checkIns.isEmpty {
                RoutineEmptyState(
                    icon: .check,
                    title: "No check-ins yet",
                    message: "Finish a task and your first entry will appear here.",
                    actionTitle: "View your habits",
                    action: onOpenHabits
                )
            } else {
                VStack(spacing: RoutineSpacing.sm) {
                    ForEach(checkIns.prefix(4)) { checkIn in
                        HStack {
                            RoutineIcon(.check, color: RoutineColors.secondaryText)
                                .frame(width: 18, height: 18)
                            Text(checkIn.completedAt, format: .dateTime.month().day().hour().minute())
                                .font(RoutineTypography.secondary)
                            Spacer()
                        }
                    }
                }
                .padding(RoutineSpacing.md)
                .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: RoutineSpacing.xxs) {
            Text(value)
                .font(RoutineTypography.metric)
            Text(label)
                .font(RoutineTypography.small)
                .foregroundStyle(RoutineColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Profile") {
    ProfileView()
}
