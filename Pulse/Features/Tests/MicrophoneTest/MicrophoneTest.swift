import AVFoundation
import SwiftUI
import Combine

// MARK: - Microphone Test
class MicrophoneTest: BaseDiagnosticTest {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    init() {
        super.init(
            id: "microphone",
            title: "Microphone",
            description: "Speak to see audio waveform",
            category: .cameraMedia,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        try await setupAudio()
    }
    
    func setupAudio() async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement)
        try session.setActive(true)
        
        let engine = AVAudioEngine()
        let input = engine.inputNode
        let bus = 0
        
        input.installTap(onBus: bus, bufferSize: 512, format: input.inputFormat(forBus: bus)) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }
        
        audioEngine = engine
        inputNode = input
        
        try engine.start()
        isRecording = true
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let channelDataValue = channelData.pointee
        let channelDataArray = Array(UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength)))
        
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        
        DispatchQueue.main.async {
            self.audioLevel = min(rms * 10, 1.0)
        }
    }
    
    func confirmSuccess() {
        markPassed(metadata: ["max_level": String(format: "%.2f", audioLevel)])
    }
    
    func stopRecording() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        isRecording = false
    }
    
    override func reset() {
        super.reset()
        stopRecording()
        audioLevel = 0
    }
}
