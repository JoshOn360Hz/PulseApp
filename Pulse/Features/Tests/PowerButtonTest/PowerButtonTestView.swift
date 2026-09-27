import SwiftUI

struct PowerButtonTestView: View {
    @ObservedObject var test: PowerButtonTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(
            title: "Power Button",
            status: test.status,
            onClose: { dismiss() },
            onSkip: { test.markSkipped(reason: "User skipped test") }
        ) {
            PulseTestHero(icon: "power", tint: PulseTheme.accent, isActive: test.waitingForUserConfirmation)

            PulseTestPanel {
                VStack(alignment: .leading, spacing: PulseSpacing.md) {
                    PulseTestStatusRow(
                        icon: test.waitingForUserConfirmation ? "checkmark.circle" : "power",
                        title: "Test state",
                        value: test.waitingForUserConfirmation ? "Awaiting confirmation" : "Press the power button",
                        tint: test.waitingForUserConfirmation ? PulseTheme.success : PulseTheme.accent
                    )

                    Text(test.waitingForUserConfirmation ? "The app returned to the foreground. Confirm whether the device actually went to sleep." : "Press the physical power button once, then unlock or wake the device to continue.")
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if test.waitingForUserConfirmation {
                VStack(spacing: PulseSpacing.sm) {
                    PulseTestActionButton(title: "Yes, it went to sleep", icon: "checkmark.circle.fill", role: .primary, action: test.confirmDeviceSlept)
                    PulseTestActionButton(title: "No, it stayed awake", icon: "xmark.circle", role: .destructive, action: test.confirmDeviceDidNotSleep)
                }
                .padding(.horizontal, PulseSpacing.sm)
            }
        }
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }
}
