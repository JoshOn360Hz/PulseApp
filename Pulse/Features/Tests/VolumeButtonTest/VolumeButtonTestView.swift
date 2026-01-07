import SwiftUI

struct VolumeButtonTestView: View {
    @ObservedObject var test: VolumeButtonTest
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
                VStack(spacing: 0) {
                    // Header with icon
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 40)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text(test.title)
                                .font(.system(size: 32, weight: .bold))
                            
                            Text(test.description)
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(spacing: 20) {

                        // Button status cards
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "hand.point.up.left.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("Button Status")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            VStack(spacing: 14) {
                                ButtonStatusRow(
                                    icon: "plus.circle.fill",
                                    title: "Volume Up",
                                    isPressed: test.volumeUpPressed
                                )
                                
                                Divider()
                                
                                ButtonStatusRow(
                                    icon: "minus.circle.fill",
                                    title: "Volume Down",
                                    isPressed: test.volumeDownPressed
                                )
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            test.confirmSuccess()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Volume Buttons Work")
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
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Volume Buttons Don't Work")
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
            Task { try? await test.run() }
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}

struct ButtonStatusRow: View {
    let icon: String
    let title: String
    let isPressed: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isPressed ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: isPressed ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 18))
                    .foregroundColor(isPressed ? .green : .blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                
                HStack(spacing: 6) {
                    if isPressed {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Detected")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    } else {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 8, height: 8)
                        Text("Waiting...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Text(number)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}
