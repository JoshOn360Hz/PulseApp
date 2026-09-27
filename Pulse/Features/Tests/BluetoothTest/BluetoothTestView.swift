import SwiftUI
import CoreBluetooth

struct BluetoothTestView: View {
    @ObservedObject var test: BluetoothTest
    @Environment(\.dismiss) private var dismiss

    private var stateTint: Color {
        switch test.bluetoothState {
        case .poweredOn: return PulseTheme.success
        case .poweredOff, .unsupported, .unauthorized: return PulseTheme.failure
        default: return PulseTheme.warning
        }
    }

    var body: some View {
        PulseTestScrollScreen(
            title: "Bluetooth",
            status: test.status,
            onClose: { dismiss() },
            onSkip: { test.markSkipped(reason: "User skipped test") }
        ) {
            PulseTestHero(icon: "antenna.radiowaves.left.and.right", tint: stateTint, isActive: test.isScanning)

            PulseTestPanel {
                VStack(alignment: .leading, spacing: PulseSpacing.md) {
                    PulseTestStatusRow(
                        icon: "antenna.radiowaves.left.and.right",
                        title: "Bluetooth state",
                        value: test.bluetoothStateText(test.bluetoothState),
                        tint: stateTint
                    )

                    PulseTestStatusRow(
                        icon: "lock.shield",
                        title: "Permission",
                        value: test.authorizationStatusText(test.authorizationStatus),
                        tint: PulseTheme.accent
                    )

                    if test.bluetoothState == .poweredOn {
                        Button {
                            if test.isScanning { test.stopScanning() } else { test.startScanning() }
                        } label: {
                            PulseButtonLabel(
                                title: test.isScanning ? "Stop scanning" : "Scan for devices",
                                icon: test.isScanning ? "stop.fill" : "dot.radiowaves.left.and.right"
                            )
                        }
                        .buttonStyle(PulseSecondaryButtonStyle())
                    }
                }
            }

            if !test.discoveredDevices.isEmpty {
                PulseTestPanel {
                    VStack(alignment: .leading, spacing: PulseSpacing.sm) {
                        HStack {
                            Text("Nearby devices")
                                .font(.headline)
                                .foregroundStyle(PulseTheme.textPrimary)
                            Spacer()
                            Text("\(test.discoveredDevices.count)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(PulseTheme.accent)
                        }

                        ForEach(Array(test.discoveredDevices.prefix(4))) { device in
                            HStack(spacing: PulseSpacing.sm) {
                                Image(systemName: "dot.radiowaves.left.and.right")
                                    .foregroundStyle(PulseTheme.accent)
                                Text(device.displayName)
                                    .font(.subheadline)
                                    .foregroundStyle(PulseTheme.textPrimary)
                                Spacer()
                                Text("\(device.rssi) dBm")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(PulseTheme.textSecondary)
                            }
                            .padding(.vertical, PulseSpacing.xs)
                        }
                    }
                }
            }

            if test.status == .running {
                VStack(spacing: PulseSpacing.sm) {
                    PulseTestActionButton(
                        title: "Bluetooth works",
                        icon: "checkmark.circle.fill",
                        role: .primary,
                        action: test.confirmSuccess
                    )
                    PulseTestActionButton(
                        title: "Report a Bluetooth issue",
                        icon: "xmark.circle",
                        role: .destructive,
                        action: { test.markFailed(reason: "User reported failure") }
                    )
                }
                .padding(.horizontal, PulseSpacing.sm)
            }
        }
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onDisappear {
            test.stopScanning()
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }
}
