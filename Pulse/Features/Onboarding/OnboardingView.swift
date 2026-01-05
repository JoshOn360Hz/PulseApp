import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            
            TabView(selection: $currentPage) {
                // Welcome Page
                WelcomePage()
                    .tag(0)
                
                // How to Use Page
                HowToUsePage()
                    .tag(1)
                
                // Permissions Page
                PermissionsPage(isPresented: $isPresented)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon
            Image("icon-onboarding")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Text("Welcome to Pulse")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Complete Device Diagnostics")
                    .font(.title3)
                    .foregroundColor(.primary.opacity(0.9))
            }
            
            VStack(spacing: 12) {
                FeatureRow(icon: "testtube.2", text: "Test all hardware components")
                FeatureRow(icon: "chart.bar.doc.horizontal", text: "Get detailed diagnostic reports")
                FeatureRow(icon: "square.and.arrow.up", text: "Export results as PDF or JSON")
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
            
            Text("Swipe to continue")
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.7))
                .padding(.bottom, 50)
        }
    }
}

struct HowToUsePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)
                
                Text("How to Use Pulse")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 24) {
                InstructionStep(
                    number: "1",
                    title: "Browse Tests",
                    description: "Select from categories like Input, Display, Camera, Sensors, and more"
                )
                
                InstructionStep(
                    number: "2",
                    title: "Run Diagnostics",
                    description: "Follow on-screen instructions for each test or use 'Run All' for automatic testing"
                )
                
                InstructionStep(
                    number: "3",
                    title: "Review Results",
                    description: "Check the Results tab for detailed reports and export your findings"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Text("Swipe to continue")
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.7))
                .padding(.bottom, 50)
        }
    }
}

struct PermissionsPage: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)
                
                Text("Permissions Required")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                PermissionRow(
                    icon: "camera.fill",
                    title: "Camera",
                    description: "Test front and rear cameras with flash"
                )
                
                PermissionRow(
                    icon: "mic.fill",
                    title: "Microphone",
                    description: "Test audio recording capabilities"
                )
                
                PermissionRow(
                    icon: "location.fill",
                    title: "Motion & Sensors",
                    description: "Test accelerometer, gyroscope, and other sensors"
                )
                
                PermissionRow(
                    icon: "faceid",
                    title: "Biometrics",
                    description: "Test Face ID or Touch ID functionality"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    completeOnboarding()
                }) {
                    HStack {
                        Text("Get Started")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                }
                .buttonStyle(.borderedProminent)
                
                Text("Permissions will be requested as needed during tests")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct InstructionStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(16)
    }
}
