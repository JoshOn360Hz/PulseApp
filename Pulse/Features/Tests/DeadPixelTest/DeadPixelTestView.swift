import SwiftUI

struct DeadPixelTestView: View {
    @ObservedObject var test: DeadPixelTest
    @Environment(\.dismiss) var dismiss
    @State private var showInstructions = true
    
    var body: some View {
        ZStack {
            // Full screen color
            test.currentColor.color
                .ignoresSafeArea()
            
            // Instructions overlay
            if showInstructions && !test.hasCompletedAllColors {
                VStack {
                    Spacer()
                    
                    instructionsCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Confirmation dialog when all colors viewed
            if test.hasCompletedAllColors {
                confirmationDialog
            }
            
            // Top controls
            VStack(spacing: 0) {
                HStack {
                    // Color indicator
                    HStack(spacing: 10) {
                        Circle()
                            .fill(test.currentColor.color)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(test.currentColor == .white || test.currentColor == .black ? Color.gray : Color.clear, lineWidth: 1)
                            )
                        
                        Text(test.currentColor.name)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("(\(test.currentColorIndex + 1)/\(test.totalColors))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Material.ultraThin))
                    
                    Spacer()
                    
                    // Toggle instructions
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showInstructions.toggle()
                        }
                    }) {
                        Image(systemName: showInstructions ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Material.ultraThin))
                    }
                    
                    // Skip button
                    Button(action: {
                        test.markSkipped(reason: "User skipped test")
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Material.ultraThin))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if !test.hasCompletedAllColors {
                        if value.translation.width < 0 {
                            // Swipe left - next color
                            test.nextColor()
                        } else if value.translation.width > 0 && test.currentColorIndex > 0 {
                            // Swipe right - previous color
                            test.previousColor()
                        }
                    }
                }
        )
    }
    
    var instructionsCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                NavigationButton(
                    icon: "chevron.left",
                    text: "Back",
                    isDisabled: test.currentColorIndex == 0
                ) {
                    test.previousColor()
                }
                
                NavigationButton(
                    icon: "chevron.right",
                    text: "Next",
                    isDisabled: false
                ) {
                    test.nextColor()
                }
            }
            
            Text("Swipe left/right to change colors")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Material.regular)
        )
    }
    
    var confirmationDialog: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("Test Complete")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Did you notice any dead or stuck pixels?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                Button(action: {
                    test.confirmNoDeadPixels()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("No Issues Found")
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
                    test.confirmDeadPixelsFound()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Issues Detected")
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
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Material.regular)
        )
        .padding(.horizontal, 30)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .bold))
            
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct NavigationButton: View {
    let icon: String
    let text: String
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if icon == "chevron.left" {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text(text)
                    .font(.system(size: 16, weight: .semibold))
                
                if icon == "chevron.right" {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundColor(isDisabled ? .secondary : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isDisabled ? Color(.systemGray5) : Color(.systemGray6))
            .cornerRadius(14)
        }
        .disabled(isDisabled)
    }
}
