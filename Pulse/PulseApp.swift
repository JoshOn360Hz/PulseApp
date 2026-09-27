import SwiftUI

@main
struct PulseApp: App {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        && !ProcessInfo.processInfo.arguments.contains("-skipOnboarding")
    
    var body: some Scene {
        WindowGroup {
            HomeSceneView()
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(isPresented: $showOnboarding)
                }
                .preferredColorScheme(.dark)
        }
    }
}
