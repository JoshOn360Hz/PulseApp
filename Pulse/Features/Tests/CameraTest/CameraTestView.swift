import SwiftUI
import AVFoundation

struct CameraTestView: View {
    @ObservedObject var test: CameraTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Camera preview
            if let session = test.captureSession {
                CameraPreviewView(session: session)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            
            // UI Overlay
            VStack(spacing: 0) {
                // Top bar with background
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.6)))
                    }
                    
                    Spacer()
                    
                    Text(test.currentCamera == .back ? "Rear Camera" : "Front Camera")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                    
                    Spacer()
                    
                    Button(action: {
                        test.markSkipped(reason: "User skipped test")
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color.black.opacity(0.6)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.5), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.top, 0)
                
                Spacer()
                
                // Control panel
                VStack(spacing: 20) {
                    // Camera controls in a card
                    HStack(spacing: 30) {
                        if test.availableCameras.count > 1 {
                            Button(action: {
                                Task {
                                    try? await test.switchCamera()
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                    Text("Switch")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 70, height: 70)
                                .background(Circle().fill(Color.white.opacity(0.25)))
                            }
                        }
                        
                        if test.currentCamera == .back {
                            Button(action: {
                                try? test.toggleFlash()
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: test.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(test.isFlashOn ? .yellow : .white)
                                    Text(test.isFlashOn ? "Flash On" : "Flash Off")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 70, height: 70)
                                .background(Circle().fill(test.isFlashOn ? Color.yellow.opacity(0.35) : Color.white.opacity(0.25)))
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.5))
                    )
                    
                    // Action buttons
                    if test.status == .running {
                        VStack(spacing: 12) {
                            Button(action: {
                                test.confirmSuccess()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Camera Works")
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
                                    Text("Camera Doesn't Work")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear {
            test.reset()
            Task {
                try? await test.run()
            }
        }
        .onDisappear {
            test.stopCamera()
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
