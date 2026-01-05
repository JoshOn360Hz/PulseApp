import Foundation
import AVFoundation
import MediaPlayer
import Combine

class VolumeButtonTest: BaseDiagnosticTest {
    @Published var volumeUpPressed = false
    @Published var volumeDownPressed = false
    
    private var volumeView: MPVolumeView?
    private var initialVolume: Float = 0.0
    private var cancellable: AnyCancellable?
    
    init() {
        super.init(
            id: "volume-buttons",
            title: "Volume Buttons",
            description: "Test volume up and down buttons",
            category: .inputInteraction,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        
        // Setup volume monitoring
        await MainActor.run {
            setupVolumeMonitoring()
        }
        
        // Wait for both buttons to be pressed or timeout
        let startTime = Date()
        while (!volumeUpPressed || !volumeDownPressed) && Date().timeIntervalSince(startTime) < 30 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        await MainActor.run {
            cleanup()
        }
        
        if volumeUpPressed && volumeDownPressed {
            markPassed(metadata: [:])
        } else {
            var reason = "Not all buttons detected. "
            if !volumeUpPressed { reason += "Volume Up not pressed. " }
            if !volumeDownPressed { reason += "Volume Down not pressed." }
            markFailed(reason: reason, metadata: [:])
        }
    }
    
    private func setupVolumeMonitoring() {
        // Get initial volume
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            initialVolume = audioSession.outputVolume
        } catch {
            print("Failed to activate audio session: \(error)")
        }
        
        // Create volume view (hidden) to enable volume monitoring
        volumeView = MPVolumeView(frame: .zero)
        
        // Monitor volume changes using Combine
        cancellable = audioSession.publisher(for: \.outputVolume)
            .sink { [weak self] newVolume in
                guard let self = self else { return }
                if newVolume > self.initialVolume {
                    self.volumeUpPressed = true
                } else if newVolume < self.initialVolume {
                    self.volumeDownPressed = true
                }
                self.initialVolume = newVolume
            }
    }
    
    private func cleanup() {
        cancellable?.cancel()
        cancellable = nil
        volumeView = nil
        
        // Restore audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func confirmSuccess() {
        cleanup()
        markPassed(metadata: [
            "volumeUpPressed": "\(volumeUpPressed)",
            "volumeDownPressed": "\(volumeDownPressed)"
        ])
    }
    
    override func reset() {
        super.reset()
        volumeUpPressed = false
        volumeDownPressed = false
    }
}
