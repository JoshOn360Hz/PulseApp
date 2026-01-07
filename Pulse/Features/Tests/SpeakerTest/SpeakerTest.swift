import AVFoundation
import SwiftUI
import Combine

class SpeakerTest: BaseDiagnosticTest {
    @Published var isPlaying = false
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    init() {
        super.init(
            id: "speaker",
            title: "Speaker",
            description: "Play test tone",
            category: .cameraMedia,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
    }
    
    func playTestTone() async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        
        // Generate a 440Hz tone (A4)
        let sampleRate = 44100.0
        let duration = 2.0
        let frequency = 440.0
        
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: engine.mainMixerNode.outputFormat(forBus: 0),
                                           frameCapacity: frameCount) else {
            throw SpeakerError.bufferCreationFailed
        }
        
        buffer.frameLength = frameCount
        
        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
        for channel in 0..<Int(buffer.format.channelCount) {
            let channelData = channels[channel]
            for frame in 0..<Int(frameCount) {
                let value = sin(2.0 * .pi * frequency * Double(frame) / sampleRate)
                channelData[frame] = Float(value) * 0.5
            }
        }
        
        audioEngine = engine
        playerNode = player
        
        try engine.start()
        player.play()
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        
        isPlaying = true
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        isPlaying = false
    }
    
    func confirmSuccess() {
        markPassed(metadata: ["tone": "440Hz"])
    }
    
    func stopPlaying() {
        playerNode?.stop()
        audioEngine?.stop()
        isPlaying = false
    }
    
    override func reset() {
        super.reset()
        stopPlaying()
    }
}

enum SpeakerError: Error {
    case bufferCreationFailed
}
