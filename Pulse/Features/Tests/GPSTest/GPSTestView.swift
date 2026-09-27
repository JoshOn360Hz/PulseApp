import SwiftUI
import CoreLocation

struct GPSTestView: View {
    @ObservedObject var test: GPSTest
    @Environment(\.dismiss) private var dismiss

    private var authorizationText: String {
        switch test.authorizationStatus {
        case .notDetermined: return "Not requested"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always allowed"
        case .authorizedWhenInUse: return "When in use"
        @unknown default: return "Unknown"
        }
    }

    private var authorizationTint: Color {
        switch test.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return PulseTheme.success
        case .denied, .restricted: return PulseTheme.failure
        default: return PulseTheme.warning
        }
    }

    var body: some View {
        PulseTestScrollScreen(
            title: "GPS",
            status: test.status,
            onClose: { dismiss() },
            onSkip: { test.markSkipped(reason: "User skipped test") }
        ) {
            PulseTestHero(icon: "location.fill", tint: authorizationTint, isActive: test.isUpdatingLocation)

            PulseTestPanel {
                VStack(alignment: .leading, spacing: PulseSpacing.md) {
                    PulseTestStatusRow(
                        icon: "location.fill",
                        title: "Permission",
                        value: authorizationText,
                        tint: authorizationTint
                    )

                    PulseTestStatusRow(
                        icon: "scope",
                        title: "Accuracy",
                        value: test.accuracy.map { String(format: "%.1f m", $0) } ?? "Waiting",
                        tint: PulseTheme.accent
                    )

                    if test.authorizationStatus == .authorizedWhenInUse || test.authorizationStatus == .authorizedAlways {
                        Button {
                            if test.isUpdatingLocation { test.stopLocationUpdates() } else { test.startLocationUpdates() }
                        } label: {
                            PulseButtonLabel(
                                title: test.isUpdatingLocation ? "Stop location updates" : "Start location updates",
                                icon: test.isUpdatingLocation ? "stop.fill" : "location.fill"
                            )
                        }
                        .buttonStyle(PulseSecondaryButtonStyle())
                    } else {
                        Text("Location permission is required to read a live position.")
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.textSecondary)
                    }
                }
            }

            if let location = test.currentLocation {
                PulseTestPanel {
                    VStack(alignment: .leading, spacing: PulseSpacing.sm) {
                        Text("Current position")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)
                        PulseTestStatusRow(icon: "globe", title: "Latitude", value: String(format: "%.5f", location.coordinate.latitude), tint: PulseTheme.accent)
                        PulseTestStatusRow(icon: "globe", title: "Longitude", value: String(format: "%.5f", location.coordinate.longitude), tint: PulseTheme.accent)
                    }
                }
            }

            if test.currentLocation != nil && test.status == .running {
                VStack(spacing: PulseSpacing.sm) {
                    PulseTestActionButton(title: "GPS works", icon: "checkmark.circle.fill", role: .primary, action: test.confirmSuccess)
                    PulseTestActionButton(title: "Report a GPS issue", icon: "xmark.circle", role: .destructive, action: { test.markFailed(reason: "User reported failure") })
                }
                .padding(.horizontal, PulseSpacing.sm)
            }
        }
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onDisappear {
            test.stopLocationUpdates()
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }
}
