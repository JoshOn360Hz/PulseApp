import SwiftUI
import LocalAuthentication

struct BiometricTestView: View {
    @ObservedObject var test: BiometricTest
    @Environment(\.dismiss) private var dismiss

    private var biometricName: String {
        switch test.biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometrics"
        }
    }

    private var biometricIcon: String {
        switch test.biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.shield"
        }
    }

    var body: some View {
        PulseTestScrollScreen(
            title: biometricName,
            status: test.status,
            onClose: { dismiss() },
            onSkip: { test.markSkipped(reason: "User skipped test") }
        ) {
            PulseTestHero(icon: biometricIcon, tint: test.isAvailable ? PulseTheme.accent : PulseTheme.unsupported)

            PulseTestPanel {
                VStack(alignment: .leading, spacing: PulseSpacing.md) {
                    PulseTestStatusRow(
                        icon: biometricIcon,
                        title: "Availability",
                        value: test.isAvailable ? "Available" : "Unavailable",
                        tint: test.isAvailable ? PulseTheme.success : PulseTheme.warning
                    )

                    Text(test.isAvailable ? "Authenticate with the device owner’s biometric sensor." : "Biometric authentication is not available on this device.")
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if test.isAvailable {
                        PulseTestActionButton(
                            title: "Authenticate",
                            icon: biometricIcon,
                            role: .primary,
                            action: {
                                Task { try? await test.run() }
                            }
                        )
                    }
                }
            }
        }
        .onAppear {
            test.reset()
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }
}
