import SwiftUI
import AVFoundation

struct CameraTestView: View {
    @ObservedObject var test: CameraTest
    let isAutoRunning: Bool
    @Binding var isPaused: Bool
    @Environment(\.dismiss) private var dismiss

    init(
        test: CameraTest,
        isAutoRunning: Bool = false,
        isPaused: Binding<Bool> = .constant(false)
    ) {
        self.test = test
        self.isAutoRunning = isAutoRunning
        self._isPaused = isPaused
    }

    var body: some View {
        ZStack {
            previewLayer
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.64),
                    .clear,
                    Color.black.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer(minLength: PulseSpacing.lg)
                controlPanel
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            test.reset()
            startCamera()
        }
        .onDisappear {
            test.stopCamera()
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var previewLayer: some View {
        if let session = test.captureSession {
            CameraPreviewView(session: session)
                .background(Color.black)
        } else {
            Color.black
                .overlay {
                    VStack(spacing: PulseSpacing.md) {
                        Image(systemName: test.cameraErrorMessage == nil ? "camera.viewfinder" : "camera.slash")
                            .font(.system(size: 42, weight: .medium))
                            .foregroundStyle(test.cameraErrorMessage == nil ? PulseTheme.accent : PulseTheme.failure)

                        Text(test.cameraErrorMessage == nil ? "Starting camera…" : "Camera unavailable")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)

                        if let message = test.cameraErrorMessage {
                            Text(message)
                                .font(.subheadline)
                                .foregroundStyle(PulseTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 280)
                        }

                        if test.cameraErrorMessage != nil {
                            Button("Try Again", action: startCamera)
                                .buttonStyle(PulseSecondaryButtonStyle())
                                .frame(width: 140)
                        }
                    }
                    .padding(PulseSpacing.xl)
                }
        }
    }

    private var header: some View {
        HStack(spacing: PulseSpacing.sm) {
            Button(action: close) {
                Image(systemName: isAutoRunning ? "pause.fill" : "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(PulseTheme.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(PulseTheme.surface.opacity(0.88))
                    .clipShape(Circle())
            }
            .accessibilityLabel(isAutoRunning ? "Pause test run" : "Close camera test")

            Text("Camera inspection")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(PulseTheme.textPrimary)

            Spacer(minLength: PulseSpacing.sm)

            PulseStatusBadge(status: test.status)

            Button(action: { test.markSkipped(reason: "User skipped test") }) {
                Text("Skip")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(PulseTheme.warning)
                    .padding(.horizontal, PulseSpacing.sm)
                    .padding(.vertical, PulseSpacing.xs)
                    .background(PulseTheme.warning.opacity(0.14))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, PulseSpacing.lg)
        .padding(.top, PulseSpacing.sm)
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: PulseSpacing.lg) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Camera lenses")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseTheme.textPrimary)

                    Text("Tap each lens to check the preview")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                }

                Spacer()

                Text("\(test.checkedCameraCount)/\(test.availableCameraOptions.count) checked")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(test.allAvailableCamerasChecked ? PulseTheme.success : PulseTheme.accent)
            }

            lensPicker

            actionControls
        }
        .padding(.horizontal, PulseSpacing.md)
        .padding(.vertical, PulseSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(PulseTheme.surface.opacity(0.94))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(PulseTheme.divider, lineWidth: 1)
                }
        )
        .padding(.horizontal, PulseSpacing.sm)
        .padding(.bottom, PulseSpacing.sm)
    }

    private var lensPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PulseSpacing.xs) {
                ForEach(test.availableCameraOptions) { option in
                    let isSelected = test.selectedCameraID == option.id
                    let isChecked = test.checkedCameraIDs.contains(option.id)

                    Button {
                        Task {
                            try? await test.setupCamera(optionID: option.id)
                        }
                    } label: {
                        HStack(spacing: PulseSpacing.xs) {
                            Image(systemName: option.symbolName)
                                .font(.system(size: 13, weight: .bold))

                            Text(option.title)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)

                            if isChecked {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(PulseTheme.success)
                            }
                        }
                        .foregroundStyle(isSelected ? PulseTheme.background : PulseTheme.textPrimary)
                        .padding(.horizontal, PulseSpacing.sm)
                        .padding(.vertical, 9)
                        .background(isSelected ? PulseTheme.accent : PulseTheme.surfaceRaised)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(option.title) camera\(isChecked ? ", checked" : "")")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private var actionControls: some View {
        VStack(spacing: PulseSpacing.sm) {
            HStack(spacing: PulseSpacing.xs) {
                Button {
                    test.markCurrentCameraChecked()
                } label: {
                    PulseButtonLabel(
                        title: test.checkedCameraIDs.contains(test.selectedCameraID ?? "") ? "Checked" : "Mark lens checked",
                        icon: test.checkedCameraIDs.contains(test.selectedCameraID ?? "") ? "checkmark" : "checkmark.circle"
                    )
                }
                .buttonStyle(PulseSecondaryButtonStyle())
                .disabled(test.selectedCameraID == nil || !test.isSessionRunning)

                if test.selectedCameraOption?.hasTorch == true {
                    Button {
                        try? test.toggleFlash()
                    } label: {
                        Image(systemName: test.isFlashOn ? "bolt.fill" : "bolt.slash")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(test.isFlashOn ? PulseTheme.warning : PulseTheme.textPrimary)
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(PulseSecondaryButtonStyle())
                    .accessibilityLabel(test.isFlashOn ? "Turn flash off" : "Test flash")
                }
            }

            Button {
                test.confirmSuccess()
            } label: {
                PulseButtonLabel(
                    title: test.allAvailableCamerasChecked ? "Camera test passed" : "Check every lens to finish",
                    icon: test.allAvailableCamerasChecked ? "checkmark.circle.fill" : "arrow.right"
                )
            }
            .buttonStyle(PulsePrimaryButtonStyle())
            .disabled(!test.allAvailableCamerasChecked)
            .opacity(test.allAvailableCamerasChecked ? 1 : 0.48)

            Button("Report a problem") {
                test.markFailed(reason: "User reported a camera failure")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(PulseTheme.failure)
            .frame(maxWidth: .infinity)
        }
    }

    private func startCamera() {
        guard !test.isSessionRunning else { return }

        Task {
            do {
                try await test.run()
            } catch {
                // CameraTest publishes a user-facing error state. The preview
                // remains in place so the user can retry without losing context.
            }
        }
    }

    private func close() {
        if isAutoRunning {
            isPaused = true
        }
        dismiss()
    }
}
