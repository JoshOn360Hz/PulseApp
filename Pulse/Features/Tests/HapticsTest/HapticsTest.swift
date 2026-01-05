import SwiftUI
import CoreHaptics
import Combine

// MARK: - Haptics Test
class HapticsTest: BaseDiagnosticTest {
    private var engine: CHHapticEngine?
    @Published var isPlaying = false
    
    init() {
        let supported = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        super.init(
            id: "haptics",
            title: "Haptics",
            description: "Feel vibration patterns",
            category: .inputInteraction,
            isSupported: supported
        )
        
        if supported {
            setupHapticEngine()
        }
    }
    
    private func setupHapticEngine() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }
    
    override func run() async throws {
        status = .running
        // Test runs when user triggers haptic patterns
    }
    
    func playPattern() async {
        guard let engine = engine else { return }
        
        isPlaying = true
        
        do {
            // Restart engine to ensure it's ready
            try await engine.start()
            
            let events: [CHHapticEvent] = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2),
                CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: 0.6, duration: 0.5)
            ]
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
            try await Task.sleep(nanoseconds: 1_500_000_000)
            isPlaying = false
        } catch {
            isPlaying = false
            markFailed(reason: "Haptic playback failed: \(error.localizedDescription)")
        }
    }
    
    func confirmSuccess() {
        markPassed(metadata: ["patterns_played": "1"])
    }
    
    override func reset() {
        super.reset()
        isPlaying = false
        // Stop engine to prevent errors on restart
        engine?.stop()
    }
}
