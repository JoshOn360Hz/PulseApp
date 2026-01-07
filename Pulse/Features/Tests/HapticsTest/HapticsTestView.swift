import SwiftUI

struct HapticsTestView: View {
    @ObservedObject var test: HapticsTest
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
                                        colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "waveform")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .symbolEffect(.variableColor.iterative, isActive: test.isPlaying)
                        }
                        
                        Text("Haptic Feedback")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tap the button to feel a haptic vibration pattern")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 30)
                    
                    if test.isSupported {
                        // Play button card
                        VStack(spacing: 20) {
                            Button(action: {
                                Task {
                                    await test.playPattern()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: test.isPlaying ? "waveform.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 24))
                                        .symbolEffect(.pulse, isActive: test.isPlaying)
                                    
                                    Text(test.isPlaying ? "Playing..." : "Play Haptic Pattern")
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
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .tint(.blue)
                                    Text("Vibration in progress...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
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
                                        Text("I Felt the Vibration")
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
                                        Text("Haptics Don't Work")
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
                    } else {
                        // Not available message
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Haptic feedback is not available on this device")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        Spacer()
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
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
