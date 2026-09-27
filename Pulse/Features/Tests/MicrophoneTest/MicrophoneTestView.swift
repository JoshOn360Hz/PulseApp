import SwiftUI

struct MicrophoneTestView: View {
    @ObservedObject var test: MicrophoneTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(
            title: "Microphone",
            status: test.status,
            onClose: { dismiss() },
            onSkip: { test.markSkipped(reason: "User skipped test") }
        ) {
            PulseTestHero(icon: test.audioLevel > 0.1 ? "mic.fill" : "mic", tint: test.audioLevel > 0.1 ? PulseTheme.success : PulseTheme.accent, isActive: test.audioLevel > 0.3)

            PulseTestPanel {
                VStack(alignment: .leading, spacing: PulseSpacing.md) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Live input level")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)
                        Spacer()
                        Text(String(format: "%.0f%%", test.audioLevel * 100))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(test.audioLevel > 0.1 ? PulseTheme.success : PulseTheme.accent)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(PulseTheme.surfaceRaised)
                            Capsule()
                                .fill(LinearGradient(colors: [PulseTheme.accent, PulseTheme.success], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * CGFloat(min(max(test.audioLevel, 0), 1)))
                        }
                    }
                    .frame(height: 14)

                    Text("Speak or tap near the microphone. The level should respond in real time.")
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            if test.isRecording && test.status == .running {
                VStack(spacing: PulseSpacing.sm) {
                    PulseTestActionButton(title: "Microphone works", icon: "checkmark.circle.fill", role: .primary, action: test.confirmSuccess)
                    PulseTestActionButton(title: "Report a microphone issue", icon: "xmark.circle", role: .destructive, action: { test.markFailed(reason: "User reported failure") })
                }
                .padding(.horizontal, PulseSpacing.sm)
            }
        }
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onDisappear {
            test.stopRecording()
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }
}
