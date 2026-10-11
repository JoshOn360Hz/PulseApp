import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            PulseTheme.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                WelcomePage().tag(0)
                HowToUsePage().tag(1)
                PermissionsPage(isPresented: $isPresented).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.dark)
    }
}

private struct OnboardingPage<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .frame(maxWidth: 560)
                    .frame(minHeight: geometry.size.height, alignment: .top)
                    .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        }
        // Keep scrollable content above the native page indicator.
        .padding(.bottom, 48)
        .background(PulseTheme.background)
    }
}

struct WelcomePage: View {
    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: PulseSpacing.xl) {
                Spacer()

                Image("icon-onboarding")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                VStack(alignment: .leading, spacing: PulseSpacing.sm) {
                    Text("Know your device.")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Pulse puts a complete hardware check in your hands.")
                        .font(.title3)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PulseCard {
                    VStack(spacing: PulseSpacing.md) {
                        FeatureRow(icon: "testtube.2", text: "Run guided checks across your hardware")
                        Divider().overlay(PulseTheme.divider)
                        FeatureRow(icon: "chart.bar.doc.horizontal", text: "Understand what passed and what needs attention")
                        Divider().overlay(PulseTheme.divider)
                        FeatureRow(icon: "lock.shield", text: "Keep diagnostics local to your device")
                    }
                }

                Spacer()
                onboardingHint("Swipe to see how it works")
            }
            .padding(.horizontal, PulseSpacing.xl)
            .padding(.vertical, PulseSpacing.xxl)
        }
    }
}

struct HowToUsePage: View {
    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: PulseSpacing.xl) {
                Spacer()

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(PulseTheme.accent)
                    .frame(width: 92, height: 92)
                    .background(PulseTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                VStack(alignment: .leading, spacing: PulseSpacing.sm) {
                    Text("A clear path to a healthy device.")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Each diagnostic explains what to do, shows live feedback, and records a result.")
                        .font(.body)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: PulseSpacing.md) {
                    InstructionStep(number: "01", title: "Choose a check", description: "Browse by hardware area or start the full sweep.")
                    InstructionStep(number: "02", title: "Follow the signal", description: "Use the live surface to test touch, sensors, audio, camera, and more.")
                    InstructionStep(number: "03", title: "Review the result", description: "See a concise report you can keep or share with support.")
                }

                Spacer()
                onboardingHint("Swipe to continue")
            }
            .padding(.horizontal, PulseSpacing.xl)
            .padding(.vertical, PulseSpacing.xxl)
        }
    }
}

struct PermissionsPage: View {
    @Binding var isPresented: Bool

    var body: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: PulseSpacing.xl) {
                Spacer()

                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(PulseTheme.success)
                    .frame(width: 92, height: 92)
                    .background(PulseTheme.success.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                VStack(alignment: .leading, spacing: PulseSpacing.sm) {
                    Text("Permission, when it matters.")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Pulse asks only when a diagnostic needs access, with no account or cloud upload required.")
                        .font(.body)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: PulseSpacing.sm) {
                    PermissionRow(icon: "camera.fill", title: "Camera", description: "Front, rear, and flash checks")
                    PermissionRow(icon: "mic.fill", title: "Microphone", description: "Audio input and recording checks")
                    PermissionRow(icon: "location.fill", title: "Sensors & location", description: "Motion, GPS, and environmental checks")
                    PermissionRow(icon: "faceid", title: "Biometrics", description: "Face ID or Touch ID response")
                }

                Spacer()

                VStack(spacing: PulseSpacing.sm) {
                    Button(action: completeOnboarding) {
                        PulseButtonLabel(title: "Start diagnostics", icon: "arrow.right")
                    }
                    .buttonStyle(PulsePrimaryButtonStyle())
                    .accessibilityIdentifier("startDiagnosticsButton")

                    Text("You can change permissions later in Settings.")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, PulseSpacing.xl)
            .padding(.vertical, PulseSpacing.xxl)
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }
}

private func onboardingHint(_ text: String) -> some View {
    HStack(spacing: PulseSpacing.xs) {
        Image(systemName: "hand.draw")
        Text(text)
    }
    .font(.caption.weight(.semibold))
    .foregroundStyle(PulseTheme.textSecondary)
    .fixedSize(horizontal: false, vertical: true)
    .frame(maxWidth: .infinity, alignment: .center)
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: PulseSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PulseTheme.accent)
                .frame(width: 32, height: 32)
                .background(PulseTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(PulseTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

struct InstructionStep: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: PulseSpacing.md) {
            Text(number)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(PulseTheme.background)
                .frame(width: 34, height: 34)
                .background(PulseTheme.accent)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: PulseSpacing.xs) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PulseTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(PulseTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: PulseSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PulseTheme.warning)
                .frame(width: 32, height: 32)
                .background(PulseTheme.warning.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(PulseTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(PulseTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(PulseSpacing.md)
        .background(PulseTheme.surface)
        .overlay {
            RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous)
                .stroke(PulseTheme.divider, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous))
    }
}
