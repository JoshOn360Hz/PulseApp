import SwiftUI

struct SpeakerTestView: View {
    @ObservedObject var test: SpeakerTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PulseTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: PulseSpacing.xl) {
                    PulseTestHeader(
                        title: "Speaker test",
                        status: test.status,
                        onClose: { dismiss() },
                        onSkip: { test.markSkipped(reason: "User skipped test") }
                    )

                    hero

                    PulseTestPanel {
                        VStack(alignment: .leading, spacing: PulseSpacing.lg) {
                            VStack(alignment: .leading, spacing: PulseSpacing.xs) {
                                Text("Listen for a clear tone")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(PulseTheme.textPrimary)

                                Text("Turn your volume up, then play the 440 Hz reference tone. You should hear it evenly and without distortion.")
                                    .font(.subheadline)
                                    .foregroundStyle(PulseTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Button {
                                Task { try? await test.playTestTone() }
                            } label: {
                                PulseButtonLabel(
                                    title: test.isPlaying ? "Playing tone…" : "Play test tone",
                                    icon: test.isPlaying ? "waveform" : "play.fill"
                                )
                            }
                            .buttonStyle(PulsePrimaryButtonStyle())
                            .disabled(test.isPlaying)
                            .opacity(test.isPlaying ? 0.55 : 1)

                            if test.isPlaying {
                                HStack(spacing: PulseSpacing.xs) {
                                    ForEach(0..<18, id: \.self) { index in
                                        Capsule()
                                            .fill(index.isMultiple(of: 3) ? PulseTheme.accent : PulseTheme.accent.opacity(0.45))
                                            .frame(width: 3, height: CGFloat(12 + ((index * 11) % 28)))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .transition(.opacity)
                            }
                        }
                    }

                    PulseTestPanel {
                        HStack(alignment: .top, spacing: PulseSpacing.sm) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(PulseTheme.accent)
                                .frame(width: 32, height: 32)
                                .background(PulseTheme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            VStack(alignment: .leading, spacing: 3) {
                                Text("What to check")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(PulseTheme.textPrimary)
                                Text("Clarity, volume, balance, and any buzzing or crackling.")
                                    .font(.caption)
                                    .foregroundStyle(PulseTheme.textSecondary)
                            }
                        }
                    }

                    if test.status == .running && !test.isPlaying {
                        VStack(spacing: PulseSpacing.sm) {
                            PulseTestActionButton(
                                title: "I heard the tone",
                                icon: "checkmark.circle.fill",
                                role: .primary,
                                action: test.confirmSuccess
                            )

                            PulseTestActionButton(
                                title: "Report a speaker issue",
                                icon: "xmark.circle",
                                role: .destructive,
                                action: { test.markFailed(reason: "User reported failure") }
                            )
                        }
                        .padding(.horizontal, PulseSpacing.sm)
                    }
                }
                .padding(.bottom, PulseSpacing.xl)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onDisappear {
            test.stopPlaying()
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }

    private var hero: some View {
        VStack(spacing: PulseSpacing.md) {
            ZStack {
                Circle()
                    .fill(PulseTheme.accent.opacity(0.1))
                    .frame(width: 144, height: 144)

                Circle()
                    .stroke(PulseTheme.accent.opacity(0.25), lineWidth: 1)
                    .frame(width: 116, height: 116)

                Image(systemName: test.isPlaying ? "speaker.wave.3.fill" : "speaker.fill")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(PulseTheme.accent)
                    .symbolEffect(.pulse, isActive: test.isPlaying)
            }

            VStack(spacing: PulseSpacing.xs) {
                Text("Audio output")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(PulseTheme.textPrimary)

                Text("A short, calibrated tone makes speaker problems easy to spot.")
                    .font(.subheadline)
                    .foregroundStyle(PulseTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 310)
            }
        }
        .padding(.top, PulseSpacing.lg)
    }
}
