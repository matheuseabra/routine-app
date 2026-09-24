import SwiftUI

struct LaunchView: View {
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            RoutineColors.background.ignoresSafeArea()
            RoutineLogo(size: .large)
        }
        .task {
            guard !ProcessInfo.processInfo.arguments.contains("-screen") else { return }
            try? await Task.sleep(for: .seconds(1.1))
            onFinished()
        }
    }
}

#Preview("Launch") {
    LaunchView {}
}
