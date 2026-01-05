import SwiftUI

struct SpeakerTestView: View {
    @ObservedObject var test: SpeakerTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.cyan.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Instruction card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: test.isPlaying ? "speaker.wave.3.fill" : "speaker.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                                .symbolEffect(.variableColor.iterative, isActive: test.isPlaying)
                                .symbolEffect(.pulse, isActive: test.isPlaying)
                        }
                        
                        Text("Speaker Test")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Listen for a clear tone from the speaker")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 30)
                    
                    // Play button card
                    VStack(spacing: 20) {
                        Button(action: {
                            Task {
                                try? await test.playTestTone()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: test.isPlaying ? "waveform.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 24))
                                    .symbolEffect(.pulse, isActive: test.isPlaying)
                                
                                Text(test.isPlaying ? "Playing Tone..." : "Play Test Tone")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: test.isPlaying ? 
                                        [Color.gray, Color.gray.opacity(0.8)] :
                                        [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: test.isPlaying ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(test.isPlaying)
                        
                        if test.isPlaying {
                            HStack(spacing: 12) {
                                ForEach(0..<3) { index in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.blue)
                                        .frame(width: 4)
                                        .frame(height: CGFloat.random(in: 20...50))
                                        .animation(
                                            .easeInOut(duration: 0.4)
                                            .repeatForever()
                                            .delay(Double(index) * 0.1),
                                            value: test.isPlaying
                                        )
                                }
                            }
                            .frame(height: 50)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Make sure your volume is turned up")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Action buttons
                    if test.status == .running && !test.isPlaying {
                        VStack(spacing: 12) {
                            Button(action: {
                                test.confirmSuccess()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("I Heard the Tone")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            
                            Button(action: {
                                test.markFailed(reason: "User reported failure")
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Speaker Doesn't Work")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle(test.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    test.markSkipped(reason: "User skipped test")
                }) {
                    Text("Skip")
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            test.reset()
            Task {
                try? await test.run()
            }
        }
        .onDisappear {
            test.stopPlaying()
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
