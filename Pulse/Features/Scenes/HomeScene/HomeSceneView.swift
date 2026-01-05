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
            // Input tests
            engine.addTest(TouchscreenTest())
            engine.addTest(MultiTouchTest())
            engine.addTest(HapticsTest())
            engine.addTest(VolumeButtonTest())
            engine.addTest(PowerButtonTest())
            
            // Display tests
            engine.addTest(DeadPixelTest())
            
            // Camera tests
            engine.addTest(CameraTest())
            engine.addTest(MicrophoneTest())
            engine.addTest(SpeakerTest())
            
            // Sensor tests
            engine.addTest(AccelerometerTest())
            engine.addTest(GyroscopeTest())
            engine.addTest(MagnetometerTest())
            engine.addTest(ProximityTest())
            engine.addTest(AmbientLightTest())
            
            // Biometric tests
            engine.addTest(BiometricTest())
            
            // System tests
            engine.addTest(BatteryTest())
            engine.addTest(NetworkTest())
            engine.addTest(ThermalStateTest())
            engine.addTest(GPSTest())
            engine.addTest(BluetoothTest())
        }
    }
}

// Tests Tab View
struct TestsTabView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var selectedCategory: TestCategory = .inputInteraction
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.cyan.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with gradient
                    VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pulse")
                                .font(.system(size: 34, weight: .bold))
                        }
                        Spacer()
                        
                        // Reset button
                        Button(action: {
                            engine.resetAllTests()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Reset")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        // Run all button
                        NavigationLink(destination: AutoRunTestsView(engine: engine)) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Run All")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Stats Cards
                    HStack(spacing: 12) {
                        CompactStatCard(
                            title: "Total",
                            value: engine.tests.count,
                            icon: "square.grid.2x2",
                            color: .blue
                        )
                        
                        CompactStatCard(
                            title: "Passed",
                            value: engine.tests.filter { $0.status == .passed }.count,
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        CompactStatCard(
                            title: "Failed",
                            value: engine.tests.filter { $0.status == .failed }.count,
                            icon: "xmark.circle.fill",
                            color: .red
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemBackground))
                
                // Category pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TestCategory.allCases, id: \.self) { category in
                            CategoryPill(
                                category: category,
                                isSelected: selectedCategory == category,
                                testCount: engine.testsByCategory(category).count
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemGray6).opacity(0.5))
                
                // Test Cards
                ScrollView {
                    LazyVStack(spacing: 12) {
                        let tests = engine.testsByCategory(selectedCategory)
                        
                        if tests.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No tests in this category")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(tests, id: \.id) { test in
                                NavigationLink(destination: TestDetailView(test: test)) {
                                    ModernTestCard(test: test, engine: engine)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
            }
        }
    }
}

// Results Tab View
struct ResultsTabView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var isGeneratingReport = false
    
    private var report: DiagnosticReport {
        engine.generateReport()
    }
    
    private var passRate: Double {
        let total = Double(report.results.count)
        guard total > 0 else { return 0 }
        return Double(report.passedTests.count) / total * 100
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Results")
                                    .font(.system(size: 34, weight: .bold))
                                Text(formattedDate(report.timestamp))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    
                    // Pass rate circle
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 12)
                                .frame(width: 140, height: 140)
                            
                            Circle()
                                .trim(from: 0, to: passRate / 100)
                                .stroke(
                                    LinearGradient(
                                        colors: passRate >= 80 ? [.green, .green.opacity(0.7)] :
                                                passRate >= 50 ? [.orange, .orange.opacity(0.7)] :
                                                [.red, .red.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text("\(Int(passRate))%")
                                    .font(.system(size: 36, weight: .bold))
                                Text("Pass Rate")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Summary stats
                        HStack(spacing: 20) {
                            ResultStat(
                                label: "Passed",
                                count: report.passedTests.count,
                                color: .green
                            )
                            
                            Divider()
                                .frame(height: 30)
                            
                            ResultStat(
                                label: "Failed",
                                count: report.failedTests.count,
                                color: .red
                            )
                            
                            Divider()
                                .frame(height: 30)
                            
                            ResultStat(
                                label: "Skipped",
                                count: report.skippedTests.count,
                                color: .orange
                            )
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // Device info card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "iphone")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("Device Information")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            DeviceInfoRow(
                                icon: "iphone",
                                label: "Model",
                                value: report.deviceInfo.model
                            )
                            DeviceInfoRow(
                                icon: "gear",
                                label: "System",
                                value: "\(report.deviceInfo.systemName) \(report.deviceInfo.systemVersion)"
                            )
                            DeviceInfoRow(
                                icon: "battery.75",
                                label: "Battery",
                                value: "\(Int(report.deviceInfo.batteryLevel * 100))%"
                            )
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // Test results by category
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("Test Results")
                                .font(.headline)
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(TestCategory.allCases, id: \.self) { category in
                            let categoryResults = report.results.filter { result in
                                engine.tests.first(where: { $0.id == result.testId })?.category == category
                            }
                            
                            if !categoryResults.isEmpty {
                                CategoryResultsCard(
                                    category: category,
                                    results: categoryResults,
                                    engine: engine
                                )
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Export buttons
                    VStack(spacing: 12) {
                        Button(action: exportPDF) {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Export as PDF")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        
                        Button(action: exportJSON) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Export as JSON")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingShareSheet) {
                ActivityViewController(activityItems: shareItems)
            }
            .onChange(of: showingShareSheet) {
                // Clean up when sheet is dismissed
                if !showingShareSheet {
                    shareItems = []
                }
            }
            .overlay {
                if isGeneratingReport {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.primary)
                            
                            Text("Generating Report...")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(40)
                        .background(Material.regular)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func exportPDF() {
        isGeneratingReport = true
        
        Task {
            let minimumDisplayTime = 0.8
            let currentReport = report
            
            // Run generation and minimum wait in parallel
            async let generationTask: (Data, URL)? = Task {
                guard let pdfData = await ReportExporter.generatePDF(from: currentReport) else { 
                    return nil
                }
                
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "Pulse_Report_\(Date().timeIntervalSince1970).pdf"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try pdfData.write(to: fileURL)
                    return (pdfData, fileURL)
                } catch {
                    print("Error saving PDF: \(error)")
                    return nil
                }
            }.value
            
            async let minimumWait: Void = {
                try? await Task.sleep(nanoseconds: UInt64(minimumDisplayTime * 1_000_000_000))
            }()
            
            // Wait for both to complete
            _ = await minimumWait
            let result = await generationTask
            
            await MainActor.run {
                isGeneratingReport = false
                
                if let (_, fileURL) = result {
                    // Clear previous items first
                    shareItems = []
                    // Small delay to ensure state is clean
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        shareItems = [fileURL]
                        showingShareSheet = true
                    }
                } else {
                    print("Failed to generate PDF")
                }
            }
        }
    }
    
    private func exportJSON() {
        isGeneratingReport = true
        
        Task {
            let minimumDisplayTime = 0.8
            let currentReport = report
            
            // Run generation and minimum wait in parallel
            async let generationTask: (Data, URL)? = Task {
                guard let jsonData = await ReportExporter.generateJSON(from: currentReport) else { 
                    return nil
                }
                
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "Pulse_Report_\(Date().timeIntervalSince1970).json"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try jsonData.write(to: fileURL)
                    return (jsonData, fileURL)
                } catch {
                    print("Error saving JSON: \(error)")
                    return nil
                }
            }.value
            
            async let minimumWait: Void = {
                try? await Task.sleep(nanoseconds: UInt64(minimumDisplayTime * 1_000_000_000))
            }()
            
            // Wait for both to complete
            _ = await minimumWait
            let result = await generationTask
            
            await MainActor.run {
                isGeneratingReport = false
                
                if let (_, fileURL) = result {
                    // Clear previous items first
                    shareItems = []
                    // Small delay to ensure state is clean
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        shareItems = [fileURL]
                        showingShareSheet = true
                    }
                } else {
                    print("Failed to generate JSON")
                }
            }
        }
    }
}

// Supporting Views

struct CompactStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct CategoryPill: View {
    let category: TestCategory
    let isSelected: Bool
    let testCount: Int
    
    var icon: String {
        switch category {
        case .inputInteraction: return "hand.tap"
        case .display: return "display"
        case .cameraMedia: return "camera"
        case .sensors: return "sensor"
        case .biometrics: return "faceid"
        case .systemConnectivity: return "cpu"
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
            Text(category.rawValue)
                .font(.system(size: 14, weight: .semibold))
            Text("\(testCount)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isSelected ? Color.white.opacity(0.2) : Color(.systemGray5))
                .cornerRadius(8)
        }
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            isSelected ?
            LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct ModernTestCard: View {
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
        HStack(spacing: 16) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 22))
                    .foregroundColor(statusColor)
            }
            
            // Test info
            VStack(alignment: .leading, spacing: 6) {
                Text(test.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(test.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct ResultStat: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DeviceInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct CategoryResultsCard: View {
    let category: TestCategory
    let results: [TestResult]
    let engine: DiagnosticEngine
    
    var passCount: Int {
        results.filter { $0.status == .passed }.count
    }
    
    var failCount: Int {
        results.filter { $0.status == .failed }.count
    }
    
    var icon: String {
        switch category {
        case .inputInteraction: return "hand.tap"
        case .display: return "display"
        case .cameraMedia: return "camera"
        case .sensors: return "sensor"
        case .biometrics: return "faceid"
        case .systemConnectivity: return "cpu"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                HStack(spacing: 12) {
                    if passCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                            Text("\(passCount)")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.green)
                    }
                    
                    if failCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                            Text("\(failCount)")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            
            Divider()
            
            VStack(spacing: 8) {
                ForEach(results) { result in
                    if let test = engine.tests.first(where: { $0.id == result.testId }) {
                        HStack(spacing: 12) {
                            Image(systemName: result.status == .passed ? "checkmark.circle.fill" :
                                               result.status == .failed ? "xmark.circle.fill" :
                                               "minus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(result.status == .passed ? .green :
                                               result.status == .failed ? .red : .orange)
                            
                            Text(test.title)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

// Activity View Controller
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
