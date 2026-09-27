import SwiftUI
import Charts

private struct SensorActions: View {
    let isEnabled: Bool
    let onPass: () -> Void
    let onFail: () -> Void

    var body: some View {
        if isEnabled {
            VStack(spacing: PulseSpacing.sm) {
                PulseTestActionButton(title: "Sensor works", icon: "checkmark.circle.fill", role: .primary, action: onPass)
                PulseTestActionButton(title: "Report a sensor issue", icon: "xmark.circle", role: .destructive, action: onFail)
            }
            .padding(.horizontal, PulseSpacing.sm)
        }
    }
}

struct AccelerometerTestView: View {
    @ObservedObject var test: AccelerometerTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(title: "Accelerometer", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: "iphone.radiowaves.left.and.right", tint: PulseTheme.accent, isActive: test.isMonitoring)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.sm) {
                    HStack {
                        Text("Live motion")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)
                        Spacer()
                        Text(test.isMonitoring ? "Monitoring" : "Idle")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(test.isMonitoring ? PulseTheme.success : PulseTheme.textSecondary)
                    }
                    HStack(spacing: PulseSpacing.sm) {
                        PulseTestValueCard(label: "X", value: String(format: "%.2f", test.x), icon: "arrow.left.and.right", tint: PulseTheme.accent)
                        PulseTestValueCard(label: "Y", value: String(format: "%.2f", test.y), icon: "arrow.up.and.down", tint: PulseTheme.success)
                        PulseTestValueCard(label: "Z", value: String(format: "%.2f", test.z), icon: "arrow.up", tint: PulseTheme.warning)
                    }
                    Text("Move the device to see the axes respond.")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            SensorActions(isEnabled: test.status == .running && test.isMonitoring, onPass: test.confirmSuccess, onFail: { test.markFailed(reason: "User reported failure") })
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onDisappear { test.stopMonitoring() }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}

struct GyroscopeTestView: View {
    @ObservedObject var test: GyroscopeTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(title: "Gyroscope", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: "gyroscope", tint: PulseTheme.accent, isActive: test.isMonitoring)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.sm) {
                    HStack {
                        Text("Orientation")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)
                        Spacer()
                        Text(test.isMonitoring ? "Monitoring" : "Idle")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(test.isMonitoring ? PulseTheme.success : PulseTheme.textSecondary)
                    }
                    HStack(spacing: PulseSpacing.sm) {
                        PulseTestValueCard(label: "Pitch", value: String(format: "%.1f°", test.pitch), icon: "arrow.up.left.and.arrow.down.right", tint: PulseTheme.accent)
                        PulseTestValueCard(label: "Roll", value: String(format: "%.1f°", test.roll), icon: "rotate.3d", tint: PulseTheme.success)
                        PulseTestValueCard(label: "Yaw", value: String(format: "%.1f°", test.yaw), icon: "arrow.triangle.2.circlepath", tint: PulseTheme.warning)
                    }
                    Text("Rotate the device slowly through each axis.")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            SensorActions(isEnabled: test.status == .running && test.isMonitoring, onPass: test.confirmSuccess, onFail: { test.markFailed(reason: "User reported failure") })
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onDisappear { test.stopMonitoring() }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}

struct MagnetometerTestView: View {
    @ObservedObject var test: MagnetometerTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(title: "Compass", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: "location.north.fill", tint: PulseTheme.accent, isActive: test.isMonitoring)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.md) {
                    HStack(spacing: PulseSpacing.sm) {
                        PulseTestValueCard(label: "Heading", value: String(format: "%.1f°", test.heading), icon: "location.north.fill", tint: PulseTheme.accent)
                        PulseTestValueCard(label: "Accuracy", value: String(format: "%.0f", test.accuracy), icon: "scope", tint: PulseTheme.success)
                    }
                    Text("Rotate the device and confirm the heading changes smoothly.")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            SensorActions(isEnabled: test.status == .running && test.isMonitoring, onPass: test.confirmSuccess, onFail: { test.markFailed(reason: "User reported failure") })
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onDisappear { test.stopMonitoring() }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}

struct ProximityTestView: View {
    @ObservedObject var test: ProximityTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(title: "Proximity Sensor", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: test.isNear ? "sensor.fill" : "sensor", tint: test.isNear ? PulseTheme.success : PulseTheme.accent, isActive: test.isNear)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.md) {
                    PulseTestStatusRow(icon: "sensor", title: "Sensor state", value: test.isNear ? "Near" : "Far", tint: test.isNear ? PulseTheme.success : PulseTheme.accent)
                    Text("Cover the proximity sensor near the front camera, then uncover it.")
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            SensorActions(isEnabled: test.status == .running && test.isMonitoring, onPass: test.confirmSuccess, onFail: { test.markFailed(reason: "User reported failure") })
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onDisappear { test.stopMonitoring() }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}

struct AmbientLightTestView: View {
    @ObservedObject var test: AmbientLightTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(title: "Ambient Light", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: "sun.max.fill", tint: PulseTheme.warning, isActive: test.isMonitoring)

            PulseTestPanel {
                VStack(alignment: .leading, spacing: PulseSpacing.md) {
                    HStack {
                        Text("Screen brightness")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)
                        Spacer()
                        Text(String(format: "%.0f%%", test.brightnessLevel * 100))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(PulseTheme.warning)
                    }
                    ProgressView(value: Double(test.brightnessLevel))
                        .tint(PulseTheme.warning)
                    Text("Cover and uncover the device to observe the light response.")
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            SensorActions(isEnabled: test.status == .running && test.isMonitoring, onPass: test.confirmSuccess, onFail: { test.markFailed(reason: "User reported failure") })
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onDisappear { test.stopMonitoring() }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}
