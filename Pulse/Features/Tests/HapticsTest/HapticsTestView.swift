import SwiftUI

struct HapticsTestView: View {
    @ObservedObject var test: HapticsTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(
            title: "Haptics",
            status: test.status,
            onClose: { dismiss() },
            onSkip: { test.markSkipped(reason: "User skipped test") }
        ) {
            PulseTestHero(icon: "waveform", tint: PulseTheme.accent, isActive: test.isPlaying)

            PulseTestPanel {
                VStack(alignment: .leading, spacing: PulseSpacing.lg) {
                    VStack(alignment: .leading, spacing: PulseSpacing.xs) {
                        Text("Feel the pattern")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(PulseTheme.textPrimary)
                        Text("Play a short sequence of taps and a sustained vibration, then confirm what you felt.")
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.textSecondary)
                    }

                    if test.isSupported {
                        Button {
                            Task { await test.playPattern() }
                        } label: {
                            PulseButtonLabel(
                                title: test.isPlaying ? "Playing pattern…" : "Play haptic pattern",
                                icon: test.isPlaying ? "waveform" : "play.fill"
                            )
                        }
                        .buttonStyle(PulsePrimaryButtonStyle())
                        .disabled(test.isPlaying)
                        .opacity(test.isPlaying ? 0.55 : 1)
                    } else {
                        Text("Haptic feedback is not available on this device.")
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.warning)
                    }
                }
            }

            if test.status == .running && !test.isPlaying && test.isSupported {
                VStack(spacing: PulseSpacing.sm) {
                    PulseTestActionButton(title: "I felt the vibration", icon: "checkmark.circle.fill", role: .primary, action: test.confirmSuccess)
                    PulseTestActionButton(title: "Report a haptics issue", icon: "xmark.circle", role: .destructive, action: { test.markFailed(reason: "User reported failure") })
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
