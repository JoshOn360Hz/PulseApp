import SwiftUI

struct MicrophoneTestView: View {
    @ObservedObject var test: MicrophoneTest
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
                                        colors: [Color.red.opacity(0.2), Color.orange.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: test.audioLevel > 0.1 ? "mic.fill" : "mic")
                                .font(.system(size: 60))
                                .foregroundColor(test.audioLevel > 0.1 ? .red : .gray)
                                .symbolEffect(.pulse, isActive: test.audioLevel > 0.3)
                        }
                        
                        Text("Microphone Test")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Speak or make sounds into the microphone")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 30)
                    
                    // Audio level visualization
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "waveform")
                                .foregroundColor(.red)
                            Text("Audio Level")
                                .font(.headline)
                            Spacer()
                        }
                        
                        // Visual level meter
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .frame(height: 60)
                            
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                test.audioLevel < 0.3 ? Color.green :
                                                test.audioLevel < 0.7 ? Color.orange : Color.red,
                                                (test.audioLevel < 0.3 ? Color.green :
                                                test.audioLevel < 0.7 ? Color.orange : Color.red).opacity(0.7)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(test.audioLevel))
                                    .animation(.spring(response: 0.2), value: test.audioLevel)
                            }
                            .frame(height: 60)
                        }
                        
                        HStack {
                            Text("Level:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(Int(test.audioLevel * 100))%")
                                .font(.system(size: 32, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(test.audioLevel > 0.1 ? .red : .secondary)
                            Spacer()
                        }
                        
                        if test.isRecording {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                Text("Recording...")
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
                    
                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("The bar should move when you speak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Action buttons
                    if test.isRecording && test.status == .running {
                        VStack(spacing: 12) {
                            Button(action: {
                                test.confirmSuccess()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Microphone Works")
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
                                    Text("Microphone Doesn't Work")
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
            test.stopRecording()
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}

