import SwiftUI

struct HomeSceneView: View {
    @ObservedObject private var engine = DiagnosticEngine.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TestsTabView(engine: engine)
                .tabItem {
                    Label("Tests", systemImage: "testtube.2")
                }
                .tag(0)
            
            ResultsTabView(engine: engine)
                .tabItem {
                    Label("Results", systemImage: "chart.bar.doc.horizontal")
                }
                .tag(1)
        }
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


