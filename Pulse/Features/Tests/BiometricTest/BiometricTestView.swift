import SwiftUI
import LocalAuthentication

struct BiometricTestView: View {
    @ObservedObject var test: BiometricTest
    @Environment(\.dismiss) var dismiss
    
    var biometricName: String {
        switch test.biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometric"
        }
    }
    
    var biometricIcon: String {
        switch test.biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.shield"
        }
    }
    
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
                    Spacer()
                        .frame(height: 40)
                    
                    // Icon and title
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            test.isAvailable ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2),
                                            test.isAvailable ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 150, height: 150)
                            
                            Image(systemName: biometricIcon)
                                .font(.system(size: 70))
                                .foregroundColor(test.isAvailable ? .blue : .gray)
                        }
                        
                        VStack(spacing: 8) {
                            Text(biometricName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(test.isAvailable ? "Tap to authenticate" : "Not available on this device")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    if test.isAvailable {
                        // Status card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: biometricIcon)
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("\(biometricName) Status")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            HStack {
                                Text("Availability:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Available")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // Authenticate button
                        Button(action: {
                            Task {
                                try? await test.run()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: biometricIcon)
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Authenticate")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    } else {
                        // Not available message
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Biometric authentication is not available on this device")
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
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
