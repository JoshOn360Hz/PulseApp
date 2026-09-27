import SwiftUI

struct VolumeButtonTestView: View {
    @ObservedObject var test: VolumeButtonTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(
            title: "Volume Buttons",
            status: test.status,
            onClose: { dismiss() },
            onSkip: { test.markSkipped(reason: "User skipped test") }
        ) {
            PulseTestHero(icon: "speaker.wave.3.fill", tint: PulseTheme.accent)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.sm) {
                    volumeRow(title: "Volume Up", icon: "speaker.wave.2.fill", isPressed: test.volumeUpPressed)
                    Divider().overlay(PulseTheme.divider)
                    volumeRow(title: "Volume Down", icon: "speaker.wave.1.fill", isPressed: test.volumeDownPressed)
                }
            }

            Text("Press both physical volume buttons. Pulse listens for a change in the system output level.")
                .font(.subheadline)
                .foregroundStyle(PulseTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PulseSpacing.xl)

            if test.status == .running && test.volumeUpPressed && test.volumeDownPressed {
                PulseTestActionButton(title: "Volume buttons work", icon: "checkmark.circle.fill", role: .primary, action: test.confirmSuccess)
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

    private func volumeRow(title: String, icon: String, isPressed: Bool) -> some View {
        HStack(spacing: PulseSpacing.sm) {
            Image(systemName: isPressed ? "checkmark.circle.fill" : icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isPressed ? PulseTheme.success : PulseTheme.accent)
                .frame(width: 36, height: 36)
                .background((isPressed ? PulseTheme.success : PulseTheme.accent).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PulseTheme.textPrimary)

            Spacer()

            Text(isPressed ? "Detected" : "Waiting")
                .font(.caption.weight(.bold))
                .foregroundStyle(isPressed ? PulseTheme.success : PulseTheme.textSecondary)
        }
    }
}
