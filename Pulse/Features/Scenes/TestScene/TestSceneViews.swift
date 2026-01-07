import SwiftUI
import Combine

struct CategoryTestsView: View {
    @ObservedObject var engine: DiagnosticEngine
    let category: TestCategory
    
    var categoryTests: [any DiagnosticTest] {
        engine.testsByCategory(category)
    }
    
    var body: some View {
        List {
            ForEach(categoryTests, id: \.id) { test in
                NavigationLink(destination: TestDetailView(test: test)) {
                    TestRowView(test: test, engine: engine)
                }
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AllTestsView: View {
    @ObservedObject var engine: DiagnosticEngine
    
    var body: some View {
        List {
            ForEach(TestCategory.allCases, id: \.self) { category in
                Section(header: Text(category.rawValue)) {
                    ForEach(engine.testsByCategory(category), id: \.id) { test in
                        NavigationLink(destination: TestDetailView(test: test)) {
                            TestRowView(test: test, engine: engine)
                        }
                    }
                }
            }
        }
        .navigationTitle("All Tests")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Run All") {
                    Task {
                        await engine.runAllTests()
                    }
                }
            }
        }
    }
}

struct TestRowView: View {
    let test: any DiagnosticTest
    @ObservedObject var engine: DiagnosticEngine
    
    var statusColor: Color {
        switch test.status {
        case .passed: return .green
        case .failed: return .red
        case .skipped: return .orange
        case .running: return .blue
        case .notStarted: return .gray
        }
    }
    
    var statusIcon: String {
        switch test.status {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        case .running: return "arrow.clockwise.circle.fill"
        case .notStarted: return "circle"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(test.title)
                    .font(.headline)
                
                Text(test.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct TestDetailView: View {
    let test: any DiagnosticTest
    var isAutoRunning: Bool = false
    @Binding var isPaused: Bool
    @Environment(\.dismiss) var dismiss
    
    init(test: any DiagnosticTest, isAutoRunning: Bool = false, isPaused: Binding<Bool> = .constant(false)) {
        self.test = test
        self.isAutoRunning = isAutoRunning
        self._isPaused = isPaused
    }
    
    var body: some View {
        Group {
            // Route to specific test view based on test type
            if let touchTest = test as? TouchscreenTest {
                TouchscreenTestView(test: touchTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let multiTouchTest = test as? MultiTouchTest {
                MultiTouchTestView(test: multiTouchTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let hapticsTest = test as? HapticsTest {
                HapticsTestView(test: hapticsTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let volumeTest = test as? VolumeButtonTest {
                VolumeButtonTestView(test: volumeTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let powerTest = test as? PowerButtonTest {
                PowerButtonTestView(test: powerTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let pixelTest = test as? DeadPixelTest {
                DeadPixelTestView(test: pixelTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let cameraTest = test as? CameraTest {
                CameraTestView(test: cameraTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let micTest = test as? MicrophoneTest {
                MicrophoneTestView(test: micTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let speakerTest = test as? SpeakerTest {
                SpeakerTestView(test: speakerTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let accelTest = test as? AccelerometerTest {
                AccelerometerTestView(test: accelTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let gyroTest = test as? GyroscopeTest {
                GyroscopeTestView(test: gyroTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let magTest = test as? MagnetometerTest {
                MagnetometerTestView(test: magTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let proxTest = test as? ProximityTest {
                ProximityTestView(test: proxTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let ambientTest = test as? AmbientLightTest {
                AmbientLightTestView(test: ambientTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let bioTest = test as? BiometricTest {
                BiometricTestView(test: bioTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let batteryTest = test as? BatteryTest {
                BatteryTestView(test: batteryTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let networkTest = test as? NetworkTest {
                NetworkTestView(test: networkTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let gpsTest = test as? GPSTest {
                GPSTestView(test: gpsTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let thermalTest = test as? ThermalStateTest {
                ThermalStateTestView(test: thermalTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else if let bluetoothTest = test as? BluetoothTest {
                BluetoothTestView(test: bluetoothTest)
                    .navigationBarBackButtonHidden(isAutoRunning)
                    .toolbar {
                        if isAutoRunning {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { 
                                    isPaused = true
                                    dismiss() 
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Pause")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                    }
            } else {
                Text("Test view not implemented")
            }
        }
    }
}

struct AutoRunTestsView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var currentTestIndex = 0
    @State private var isNavigatingToTest = false
    @State private var isPaused = false
    @Environment(\.dismiss) var dismiss
    
    var currentTest: (any DiagnosticTest)? {
        guard currentTestIndex < engine.tests.count else { return nil }
        return engine.tests[currentTestIndex]
    }
    
    var progress: Double {
        guard !engine.tests.isEmpty else { return 0 }
        return Double(currentTestIndex) / Double(engine.tests.count)
    }
    
    var completedTests: Int {
        engine.tests.filter { $0.status == .passed || $0.status == .failed || $0.status == .skipped }.count
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                if let test = currentTest {
                    // Progress section
                    VStack(spacing: 20) {
                        // Circular progress
                        ZStack {
                            Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .blue.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text("\(Int(progress * 100))%")
                                    .font(.system(size: 28, weight: .bold))
                                Text("\(currentTestIndex + 1)/\(engine.tests.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Running Diagnostics")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 40)
                    
                    // Current test card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "testtube.2")
                                .font(.title3)
                                .foregroundColor(.blue)
                            
                            Text("Current Test")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(test.title)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text(test.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // Stats
                    HStack(spacing: 16) {
                        StatBox(
                            label: "Completed",
                            value: completedTests,
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatBox(
                            label: "Remaining",
                            value: engine.tests.count - completedTests,
                            icon: "clock.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                } else {
                    // All tests complete
                    VStack(spacing: 30) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 160, height: 160)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 12) {
                            Text("All Tests Complete!")
                                .font(.system(size: 28, weight: .bold))
                            
                            Text("\(completedTests) of \(engine.tests.count) tests finished")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("View Results")
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
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle("Auto Run")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isPaused {
                    Button(action: { 
                        isPaused = false
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 14))
                            Text("Continue")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.green)
                    }
                }
            }
        }
        .background(
            NavigationLink(
                destination: currentTest.map { TestDetailView(test: $0, isAutoRunning: true, isPaused: $isPaused) },
                isActive: $isNavigatingToTest,
                label: { EmptyView() }
            )
            .hidden()
        )
        .onAppear {
            startNextTest()
        }
        .onChange(of: currentTest?.status) {
            // When test completes (passed, failed, or skipped), move to next
            if let status = currentTest?.status, status != .notStarted && status != .running {
                isNavigatingToTest = false
                if !isPaused {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !isPaused {
                            moveToNextTest()
                        }
                    }
                }
            }
        }
        .onChange(of: isPaused) {
            // When unpausing, check if we should continue to next test
            if !isPaused {
                if let status = currentTest?.status, status != .notStarted && status != .running {
                    // Current test is already complete, move to next
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if !isPaused {
                            moveToNextTest()
                        }
                    }
                }
            }
        }
    }
    
    private func startNextTest() {
        guard currentTestIndex < engine.tests.count else { return }
        isNavigatingToTest = true
    }
    
    private func moveToNextTest() {
        currentTestIndex += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentTestIndex < engine.tests.count && !isPaused {
                startNextTest()
            }
        }
    }
}

struct StatBox: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
