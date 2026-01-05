@preconcurrency import AVFoundation
import SwiftUI
import Combine

// MARK: - Camera Test
class CameraTest: BaseDiagnosticTest {
    @Published var currentCamera: AVCaptureDevice.Position = .back
    @Published var isFlashOn = false
    @Published var availableCameras: [AVCaptureDevice.Position] = []
    @Published var captureSession: AVCaptureSession?
    
    private var videoInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "com.pulse.camera.session")
    
    init() {
        super.init(
            id: "camera",
            title: "Camera",
            description: "Test front and rear cameras with flash",
            category: .cameraMedia,
            isSupported: true
        )
        checkAvailableCameras()
    }
    
    private func checkAvailableCameras() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        let positions = Set(discoverySession.devices.map { $0.position })
        availableCameras = Array(positions).filter { $0 != .unspecified }
    }
    
    override func run() async throws {
        await MainActor.run {
            status = .running
        }
        try await setupCamera(position: .back)
    }
    
    func setupCamera(position: AVCaptureDevice.Position) async throws {
        // Clean up existing session if any
        await cleanupSession()
        
        // Find the camera device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            throw CameraError.deviceNotFound
        }
        
        // Create input
        let input = try AVCaptureDeviceInput(device: device)
        
        // Create and configure session on dedicated queue
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: CameraError.deviceNotFound)
                    return
                }
                
                let session = AVCaptureSession()
                session.beginConfiguration()
                
                if session.canAddInput(input) {
                    session.addInput(input)
                } else {
                    continuation.resume(throwing: CameraError.deviceNotFound)
                    return
                }
                
                session.commitConfiguration()
                
                // Start session
                session.startRunning()
                
                // Update properties on main thread
                Task { @MainActor in
                    self.captureSession = session
                    self.videoInput = input
                    self.currentCamera = position
                    continuation.resume()
                }
            }
        }
    }
    
    private func cleanupSession() async {
        guard let session = captureSession else { return }
        
        return await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                // Turn off flash if needed
                if self.isFlashOn, let device = self.videoInput?.device {
                    try? device.lockForConfiguration()
                    device.torchMode = .off
                    device.unlockForConfiguration()
                }
                
                // Stop and clean session
                session.stopRunning()
                
                if let input = self.videoInput {
                    session.removeInput(input)
                }
                
                Task { @MainActor in
                    self.captureSession = nil
                    self.videoInput = nil
                    self.isFlashOn = false
                    continuation.resume()
                }
            }
        }
    }
    
    func switchCamera() async throws {
        let newPosition: AVCaptureDevice.Position = currentCamera == .back ? .front : .back
        try await setupCamera(position: newPosition)
    }
    
    func toggleFlash() throws {
        guard currentCamera == .back else { return }
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
    }
    
    func confirmSuccess() {
        markPassed(metadata: [
            "cameras_tested": "\(availableCameras.count)",
            "flash_tested": isFlashOn ? "yes" : "no"
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
        currentCamera = .back
    }
}

enum CameraError: Error {
    case deviceNotFound
    case torchNotAvailable
}
