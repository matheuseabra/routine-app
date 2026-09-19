import SwiftUI

struct ProfileView: View {
    let tasks: [RoutineTask]
    let checkIns: [RoutineCheckIn]

    @State private var isSettingsPresented = false
    @State private var settingsHapticTrigger = 0

    init(tasks: [RoutineTask] = [], checkIns: [RoutineCheckIn] = []) {
        self.tasks = tasks
        self.checkIns = checkIns
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, RoutineSpacing.lg)
                    .padding(.bottom, RoutineSpacing.xl)
                profileCard
                RoutineSectionHeader(title: "ROUTINES")
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.sm)
                routinesCard
                RoutineSectionHeader(title: "RECENT HISTORY")
                    .padding(.top, RoutineSpacing.xxl)
                    .padding(.bottom, RoutineSpacing.sm)
                recentHistoryCard
            }
            .padding(.horizontal, RoutineSpacing.lg)
            .padding(.bottom, RoutineSpacing.lg)
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
        RoutinePageHeader(
            title: "Profile",
            subtitle: "Your progress and preferences in one place."
        ) {
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

                VStack(alignment: .leading, spacing: RoutineSpacing.xs) {
                    Text("Routine ID")
                        .font(RoutineTypography.compactTitle)
                    HStack(alignment: .top, spacing: RoutineSpacing.lg) {
                        profileDetail(label: "NAME", value: "Your name")
                        Spacer(minLength: 0)
                        profileDetail(label: "JOINED", value: "Local", alignment: .trailing)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .overlay(RoutineColors.border)
                .padding(.vertical, RoutineSpacing.md)

            HStack(spacing: 0) {
                profileStat(value: "\(tasks.count)", label: "TASKS")
                profileStat(value: "\(checkIns.count)", label: "CHECK-INS")
                profileStat(value: "\(summary.currentStreak)", label: "DAY STREAK")
            }
        }
        .padding(RoutineSpacing.lg)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Routine profile")
    }

    private var routinesCard: some View {
        VStack(alignment: .leading, spacing: RoutineSpacing.lg) {
            Text("Routines are the habits that work for you.")
                .font(RoutineTypography.body)
            HStack(spacing: RoutineSpacing.md) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(RoutineColors.track)
                        .frame(width: 64, height: 64)
                        .overlay {
                            RoutineIcon(.question, weight: .regular, color: RoutineColors.secondaryText)
                                .frame(width: 30, height: 30)
                        }
                }
            }
        }
        .padding(RoutineSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var recentHistoryCard: some View {
        Group {
            if checkIns.isEmpty {
                Text("No entries yet")
                    .font(RoutineTypography.compactTitle)
                    .frame(maxWidth: .infinity, minHeight: 88)
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
            }
        }
        .background(RoutineColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func profileDetail(
        label: String,
        value: String,
        alignment: HorizontalAlignment = .leading
    ) -> some View {
        VStack(alignment: alignment, spacing: RoutineSpacing.xxs) {
            Text(label)
                .font(RoutineTypography.small)
                .foregroundStyle(RoutineColors.secondaryText)
                .tracking(0.5)
            Text(value)
                .font(RoutineTypography.body)
                .foregroundStyle(RoutineColors.secondaryText)
                .lineLimit(1)
        }
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: RoutineSpacing.xxs) {
            Text(value)
                .font(RoutineTypography.metric)
            Text(label)
                .font(RoutineTypography.small)
                .foregroundStyle(RoutineColors.secondaryText)
                .tracking(0.4)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Profile") {
    ProfileView()
}
