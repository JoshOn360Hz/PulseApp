@preconcurrency import AVFoundation
import SwiftUI
import Combine

struct CameraOption: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbolName: String
    let position: AVCaptureDevice.Position
    let hasTorch: Bool
    let isTrueDepth: Bool
}

// MARK: - Camera Test
final class CameraTest: BaseDiagnosticTest {
    @Published var currentCamera: AVCaptureDevice.Position = .back
    @Published var isFlashOn = false
    @Published private(set) var availableCameras: [AVCaptureDevice.Position] = []
    @Published private(set) var availableCameraOptions: [CameraOption] = []
    @Published private(set) var checkedCameraIDs: Set<String> = []
    @Published var captureSession: AVCaptureSession?
    @Published private(set) var isSessionRunning = false
    @Published private(set) var hasCameraPermission = false
    @Published var cameraErrorMessage: String?
    @Published private(set) var hasTestedFlash = false

    private var videoInput: AVCaptureDeviceInput?
    private var cameraDevices: [String: AVCaptureDevice] = [:]
    private let sessionQueue = DispatchQueue(label: "com.pulse.camera.session")

    @Published private(set) var selectedCameraID: String?

    var selectedCameraOption: CameraOption? {
        guard let selectedCameraID else { return nil }
        return availableCameraOptions.first { $0.id == selectedCameraID }
    }

    var checkedCameraCount: Int {
        checkedCameraIDs.intersection(availableCameraOptions.map(\.id)).count
    }

    var allAvailableCamerasChecked: Bool {
        !availableCameraOptions.isEmpty && checkedCameraCount == availableCameraOptions.count
    }

    init() {
        super.init(
            id: "camera",
            title: "Camera",
            description: "Inspect every available front and rear lens",
            category: .cameraMedia,
            isSupported: true
        )
        refreshAvailableCameras()
    }

    func refreshAvailableCameras() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            // Composite devices are intentionally excluded here. The test should
            // show each physical lens rather than a single auto-switching camera.
            deviceTypes: [
                .builtInUltraWideCamera,
                .builtInWideAngleCamera,
                .builtInTelephotoCamera,
                .builtInTrueDepthCamera
            ],
            mediaType: .video,
            position: .unspecified
        )

        let devices = discoverySession.devices
        let discoveredOptions = devices.compactMap(makeOption(for:))

        // TrueDepth is the front-facing capture device that provides both the
        // visible YUV preview and the infrared depth stream. If iOS also reports
        // a generic front wide-angle device, prefer TrueDepth so the user sees
        // one front-camera check rather than two identical previews.
        let preferredFrontID = discoveredOptions.first(where: { $0.isTrueDepth })?.id
            ?? discoveredOptions.first(where: { $0.position == .front })?.id

        let options = discoveredOptions.filter { option in
            option.position != .front || option.id == preferredFrontID
        }
            .sorted { lhs, rhs in
                cameraSortOrder(lhs) < cameraSortOrder(rhs)
            }

        cameraDevices = Dictionary(uniqueKeysWithValues: devices.compactMap { device in
            guard let option = makeOption(for: device) else { return nil }
            guard options.contains(where: { $0.id == option.id }) else { return nil }
            return (option.id, device)
        })
        availableCameraOptions = options
        availableCameras = Array(Set(options.map(\.position)))
            .filter { $0 != .unspecified }
            .sorted { $0.rawValue < $1.rawValue }
        isSupported = !options.isEmpty
    }

    override func run() async throws {
        await MainActor.run {
            status = .running
            cameraErrorMessage = nil
        }

        guard !availableCameraOptions.isEmpty else {
            throw CameraError.noCamerasAvailable
        }

        let granted = await AVCaptureDevice.requestAccess(for: .video)
        guard granted else {
            await MainActor.run {
                hasCameraPermission = false
                cameraErrorMessage = CameraError.permissionDenied.localizedDescription
            }
            throw CameraError.permissionDenied
        }

        await MainActor.run {
            hasCameraPermission = true
        }

        let preferredOption = availableCameraOptions.first(where: {
            $0.position == .back && $0.title == "Wide"
        }) ?? availableCameraOptions.first

        guard let preferredOption else {
            throw CameraError.noCamerasAvailable
        }

        do {
            try await setupCamera(optionID: preferredOption.id)
        } catch {
            await MainActor.run {
                cameraErrorMessage = error.localizedDescription
            }
            throw error
        }
    }

    func setupCamera(optionID: String) async throws {
        guard let option = availableCameraOptions.first(where: { $0.id == optionID }),
              let device = cameraDevices[optionID] else {
            throw CameraError.deviceNotFound
        }

        await cleanupSession()
        let input = try AVCaptureDeviceInput(device: device)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: CameraError.deviceNotFound)
                    return
                }

                let session = AVCaptureSession()
                session.beginConfiguration()

                if session.canSetSessionPreset(.high) {
                    session.sessionPreset = .high
                }

                guard session.canAddInput(input) else {
                    session.commitConfiguration()
                    continuation.resume(throwing: CameraError.inputUnavailable)
                    return
                }

                session.addInput(input)
                session.commitConfiguration()
                session.startRunning()

                Task { @MainActor in
                    self.captureSession = session
                    self.videoInput = input
                    self.selectedCameraID = option.id
                    self.currentCamera = option.position
                    self.isFlashOn = false
                    self.isSessionRunning = session.isRunning
                    self.cameraErrorMessage = nil
                    continuation.resume()
                }
            }
        }
    }

    // Kept as a compatibility shim for older callers. New UI uses optionID so
    // it can address every physical rear lens.
    func setupCamera(position: AVCaptureDevice.Position) async throws {
        guard let option = availableCameraOptions.first(where: { $0.position == position }) else {
            throw CameraError.deviceNotFound
        }
        try await setupCamera(optionID: option.id)
    }

    private func cleanupSession() async {
        let session = captureSession
        let input = videoInput

        guard let session else {
            await MainActor.run {
                self.captureSession = nil
                self.videoInput = nil
                self.isSessionRunning = false
                self.isFlashOn = false
            }
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                if self.isFlashOn, let device = input?.device {
                    try? device.lockForConfiguration()
                    device.torchMode = .off
                    device.unlockForConfiguration()
                }

                session.stopRunning()
                if let input, session.inputs.contains(where: { $0 === input }) {
                    session.removeInput(input)
                }

                Task { @MainActor in
                    self.captureSession = nil
                    self.videoInput = nil
                    self.isSessionRunning = false
                    self.isFlashOn = false
                    continuation.resume()
                }
            }
        }
    }

    func switchCamera() async throws {
        guard let currentIndex = availableCameraOptions.firstIndex(where: { $0.id == selectedCameraID }) else {
            guard let first = availableCameraOptions.first else { throw CameraError.deviceNotFound }
            try await setupCamera(optionID: first.id)
            return
        }

        let nextIndex = (currentIndex + 1) % availableCameraOptions.count
        try await setupCamera(optionID: availableCameraOptions[nextIndex].id)
    }

    func toggleFlash() throws {
        guard let option = selectedCameraOption, option.position == .back else {
            throw CameraError.torchNotAvailable
        }
        guard let device = videoInput?.device, device.hasTorch else {
            throw CameraError.torchNotAvailable
        }

        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }

        if device.torchMode == .off {
            try device.setTorchModeOn(level: 1.0)
            isFlashOn = true
        } else {
            device.torchMode = .off
            isFlashOn = false
        }
        hasTestedFlash = true
    }

    func markCurrentCameraChecked() {
        guard let selectedCameraID else { return }
        checkedCameraIDs.insert(selectedCameraID)
    }

    func confirmSuccess() {
        guard allAvailableCamerasChecked else { return }

        let checkedNames = availableCameraOptions
            .filter { checkedCameraIDs.contains($0.id) }
            .map(\.title)
            .joined(separator: ", ")

        markPassed(metadata: [
            "cameras_available": "\(availableCameraOptions.count)",
            "cameras_tested": "\(checkedCameraCount)",
            "camera_lenses": checkedNames,
            "flash_tested": hasTestedFlash ? "yes" : "no"
        ])
    }

    func stopCamera() {
        Task {
            await cleanupSession()
        }
    }

    override func reset() {
        super.reset()
        stopCamera()
        checkedCameraIDs = []
        selectedCameraID = nil
        currentCamera = .back
        hasTestedFlash = false
        cameraErrorMessage = nil
    }

    private func makeOption(for device: AVCaptureDevice) -> CameraOption? {
        let title: String
        let detail: String
        let symbolName: String

        switch device.deviceType {
        case .builtInUltraWideCamera:
            guard device.position == .back else { return nil }
            title = "Ultra Wide"
            detail = "Rear lens · 0.5×"
            symbolName = "camera.aperture"
        case .builtInTelephotoCamera:
            guard device.position == .back else { return nil }
            title = "Telephoto"
            detail = "Rear lens · 3×"
            symbolName = "camera.metering.center.weighted"
        case .builtInTrueDepthCamera:
            guard device.position == .front else { return nil }
            title = "Front"
            detail = "Front camera · TrueDepth"
            symbolName = "faceid"
        case .builtInWideAngleCamera:
            if device.position == .back {
                title = "Wide"
                detail = "Rear lens · 1×"
                symbolName = "camera"
            } else if device.position == .front {
                title = "Front"
                detail = "Front lens"
                symbolName = "person.crop.rectangle"
            } else {
                return nil
            }
        default:
            return nil
        }

        return CameraOption(
            id: device.uniqueID,
            title: title,
            detail: detail,
            symbolName: symbolName,
            position: device.position,
            hasTorch: device.hasTorch,
            isTrueDepth: device.deviceType == .builtInTrueDepthCamera
        )
    }

    private func cameraSortOrder(_ option: CameraOption) -> Int {
        switch (option.position, option.title) {
        case (.back, "Ultra Wide"): return 0
        case (.back, "Wide"): return 1
        case (.back, "Telephoto"): return 2
        case (.front, "TrueDepth"): return 3
        case (.front, "Front"): return 4
        default: return 99
        }
    }
}

enum CameraError: LocalizedError {
    case noCamerasAvailable
    case deviceNotFound
    case inputUnavailable
    case permissionDenied
    case torchNotAvailable

    var errorDescription: String? {
        switch self {
        case .noCamerasAvailable:
            return "No compatible cameras were found on this device."
        case .deviceNotFound:
            return "That camera is no longer available."
        case .inputUnavailable:
            return "Pulse could not start the selected camera."
        case .permissionDenied:
            return "Camera access is off. Enable it in Settings to run this test."
        case .torchNotAvailable:
            return "This camera does not have a torch."
        }
    }
}
