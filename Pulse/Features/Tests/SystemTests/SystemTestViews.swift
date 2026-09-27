import SwiftUI
import Network

struct BatteryTestView: View {
    @ObservedObject var test: BatteryTest
    @Environment(\.dismiss) private var dismiss

    private var tint: Color {
        if test.level < 0.2 { return PulseTheme.failure }
        if test.level < 0.5 { return PulseTheme.warning }
        return PulseTheme.success
    }

    var body: some View {
        PulseTestScrollScreen(title: "Battery", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: "battery.100", tint: tint, isActive: test.isMonitoring)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.md) {
                    HStack(spacing: PulseSpacing.sm) {
                        PulseTestValueCard(label: "Level", value: String(format: "%.0f%%", test.level * 100), icon: "battery.100", tint: tint)
                        PulseTestValueCard(label: "State", value: test.batteryStateString(test.state), icon: "bolt.fill", tint: PulseTheme.accent)
                    }
                    Text("Battery state is read directly from the device.")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            if test.status == .running {
                PulseTestActionButton(title: "Battery status verified", icon: "checkmark.circle.fill", role: .primary, action: test.confirmSuccess)
                    .padding(.horizontal, PulseSpacing.sm)
            }
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onDisappear { test.stopMonitoring() }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}

struct NetworkTestView: View {
    @ObservedObject var test: NetworkTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PulseTestScrollScreen(title: "Network", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: test.isConnected ? "wifi" : "wifi.slash", tint: test.isConnected ? PulseTheme.success : PulseTheme.warning, isActive: test.isConnected)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.md) {
                    PulseTestStatusRow(icon: test.isConnected ? "checkmark.circle.fill" : "wifi.slash", title: "Connection", value: test.isConnected ? "Connected" : "Offline", tint: test.isConnected ? PulseTheme.success : PulseTheme.warning)
                    PulseTestStatusRow(icon: "network", title: "Interface", value: test.connectionType?.description ?? "Waiting", tint: PulseTheme.accent)
                }
            }

            if test.status == .running {
                VStack(spacing: PulseSpacing.sm) {
                    PulseTestActionButton(title: "Network works", icon: "checkmark.circle.fill", role: .primary, action: test.confirmSuccess)
                    PulseTestActionButton(title: "Report a network issue", icon: "xmark.circle", role: .destructive, action: { test.markFailed(reason: "User reported failure") })
                }
                .padding(.horizontal, PulseSpacing.sm)
            }
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onDisappear { test.stopMonitoring() }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}

struct ThermalStateTestView: View {
    @ObservedObject var test: ThermalStateTest
    @Environment(\.dismiss) private var dismiss

    private var tint: Color {
        switch test.thermalState {
        case .nominal: return PulseTheme.success
        case .fair: return PulseTheme.warning
        case .serious, .critical: return PulseTheme.failure
        @unknown default: return PulseTheme.unsupported
        }
    }

    var body: some View {
        PulseTestScrollScreen(title: "Thermal State", status: test.status, onClose: { dismiss() }, onSkip: { test.markSkipped(reason: "User skipped test") }) {
            PulseTestHero(icon: "thermometer.medium", tint: tint)

            PulseTestPanel {
                VStack(spacing: PulseSpacing.md) {
                    PulseTestStatusRow(icon: "thermometer.medium", title: "Device state", value: test.thermalStateString(test.thermalState), tint: tint)
                    Text("This is the operating system’s current thermal assessment.")
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            if test.status == .running {
                VStack(spacing: PulseSpacing.sm) {
                    PulseTestActionButton(title: "Thermal state verified", icon: "checkmark.circle.fill", role: .primary, action: test.confirmSuccess)
                    PulseTestActionButton(title: "Report a thermal issue", icon: "xmark.circle", role: .destructive, action: { test.markFailed(reason: "User reported failure") })
                }
                .padding(.horizontal, PulseSpacing.sm)
            }
        }
        .onAppear { test.reset(); Task { try? await test.run() } }
        .onChange(of: test.status) { _, status in if status == .passed || status == .failed || status == .skipped { dismiss() } }
    }
}
