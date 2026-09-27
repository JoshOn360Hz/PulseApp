import SwiftUI

struct HomeSceneView: View {
    @StateObject private var engine = DiagnosticEngine.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TestsTabView(engine: engine)
                .tabItem {
                    Label("Pulse", systemImage: "testtube.2")
                }
                .accessibilityIdentifier("testsTab")
                .tag(0)
            
            ResultsTabView(engine: engine)
                .tabItem {
                    Label("Results", systemImage: "chart.bar.doc.horizontal")
                }
                .accessibilityIdentifier("resultsTab")
                .tag(1)
        }
        .tint(PulseTheme.accent)
        .preferredColorScheme(.dark)
        .onAppear {
            setupTests()
        }
    }
    
    private func setupTests() {
        if engine.tests.isEmpty {
            engine.addTest(TouchscreenTest())
            engine.addTest(MultiTouchTest())
            engine.addTest(HapticsTest())
            engine.addTest(VolumeButtonTest())
            engine.addTest(PowerButtonTest())
            engine.addTest(DeadPixelTest())
            engine.addTest(CameraTest())
            engine.addTest(MicrophoneTest())
            engine.addTest(SpeakerTest())
            engine.addTest(AccelerometerTest())
            engine.addTest(GyroscopeTest())
            engine.addTest(MagnetometerTest())
            engine.addTest(ProximityTest())
            engine.addTest(AmbientLightTest())
            engine.addTest(BiometricTest())
            engine.addTest(BatteryTest())
            engine.addTest(NetworkTest())
            engine.addTest(ThermalStateTest())
            engine.addTest(GPSTest())
            engine.addTest(BluetoothTest())
        }
    }
}
